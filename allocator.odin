package tracy

import "core:c"
import "core:mem"

ProfiledAllocatorData :: struct {
	name:               Maybe(cstring),
	backing_allocator:  mem.Allocator,
	profiled_allocator: mem.Allocator,
	callstack_size:     i32,
	secure:             b32,
	allocations:        map[rawptr]int,
}

DestroyProfiledAllocator :: proc(self: ^ProfiledAllocatorData) {
	delete(self.allocations)
}

MakeProfiledAllocator :: proc(
	self: ^ProfiledAllocatorData,
	name: Maybe(cstring),
	callstack_size: i32 = TRACY_CALLSTACK,
	secure: b32 = false,
	backing_allocator := context.allocator,
) -> mem.Allocator {
	self.name = name
	self.callstack_size = callstack_size
	self.secure = secure
	self.backing_allocator = backing_allocator
	self.allocations = make(map[rawptr]int)
	self.profiled_allocator = mem.Allocator {
		data = self,
		procedure = proc(
			allocator_data: rawptr,
			mode: mem.Allocator_Mode,
			size, alignment: int,
			old_memory: rawptr,
			old_size: int,
			location := #caller_location,
		) -> (
			[]byte,
			mem.Allocator_Error,
		) {
			using self := cast(^ProfiledAllocatorData)allocator_data
			new_memory, error := self.backing_allocator.procedure(
				self.backing_allocator.data,
				mode,
				size,
				alignment,
				old_memory,
				old_size,
				location,
			)
			if error == .None {
				switch mode {
				case .Alloc, .Alloc_Non_Zeroed:
					self.allocations[raw_data(new_memory)] = size
					EmitAlloc(new_memory, size, callstack_size, secure, name)
				case .Free:
					delete_key(&self.allocations, old_memory)
					EmitFree(old_memory, callstack_size, secure, name)
				case .Free_All:
					for ptr in self.allocations {
						EmitFree(ptr, callstack_size, secure, name)
					}
					clear(&self.allocations)
				case .Resize, .Resize_Non_Zeroed:
					delete_key(&self.allocations, old_memory)
					EmitFree(old_memory, callstack_size, secure, name)
					self.allocations[raw_data(new_memory)] = size
					EmitAlloc(new_memory, size, callstack_size, secure, name)
				case .Query_Info:
				// TODO
				case .Query_Features:
				// TODO
				}
			}
			return new_memory, error
		},
	}
	return self.profiled_allocator
}

@(private = "file")
EmitAlloc :: #force_inline proc(
	new_memory: []byte,
	size: int,
	callstack_size: i32,
	secure: b32,
	maybeName: Maybe(cstring),
) {
	if name, present := maybeName.?; present {
		when TRACY_HAS_CALLSTACK {
			if callstack_size > 0 {
				___tracy_emit_memory_alloc_callstack_named(
					raw_data(new_memory),
					c.size_t(size),
					callstack_size,
					secure,
					name,
				)
			} else {
				___tracy_emit_memory_alloc_named(
					raw_data(new_memory),
					c.size_t(size),
					secure,
					name,
				)
			}
		} else {
			___tracy_emit_memory_alloc_named(raw_data(new_memory), c.size_t(size), secure, name)
		}
		return
	}
	when TRACY_HAS_CALLSTACK {
		if callstack_size > 0 {
			___tracy_emit_memory_alloc_callstack(
				raw_data(new_memory),
				c.size_t(size),
				callstack_size,
				secure,
			)
		} else {
			___tracy_emit_memory_alloc(raw_data(new_memory), c.size_t(size), secure)
		}
	} else {
		___tracy_emit_memory_alloc(raw_data(new_memory), c.size_t(size), secure)
	}
}

@(private = "file")
EmitFree :: #force_inline proc(
	old_memory: rawptr,
	callstack_size: i32,
	secure: b32,
	maybeName: Maybe(cstring),
) {
	if old_memory == nil {return}
	if name, present := maybeName.?; present {
		when TRACY_HAS_CALLSTACK {
			if callstack_size > 0 {
				___tracy_emit_memory_free_callstack_named(old_memory, callstack_size, secure, name)
			} else {
				___tracy_emit_memory_free_named(old_memory, secure, name)
			}
		} else {
			___tracy_emit_memory_free_named(old_memory, secure, name)
		}
		return
	}
	when TRACY_HAS_CALLSTACK {
		if callstack_size > 0 {
			___tracy_emit_memory_free_callstack(old_memory, callstack_size, secure)
		} else {
			___tracy_emit_memory_free(old_memory, secure)
		}
	} else {
		___tracy_emit_memory_free(old_memory, secure)
	}
}
