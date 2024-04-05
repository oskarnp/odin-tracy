package tracy

import "core:c"
import "core:mem"

ProfiledAllocatorData :: struct {
	backing_allocator:  mem.Allocator,
	profiled_allocator: mem.Allocator,
	callstack_size:     i32,
	secure:             b32,
}

MakeProfiledAllocator :: proc(
	self: ^ProfiledAllocatorData,
	callstack_size: i32 = TRACY_CALLSTACK,
	secure: b32 = false,
	backing_allocator := context.allocator) -> mem.Allocator {

	self.callstack_size = callstack_size
	self.secure = secure
	self.backing_allocator = backing_allocator
	self.profiled_allocator = mem.Allocator{
		data = self,
		procedure = proc(allocator_data: rawptr, mode: mem.Allocator_Mode, size, alignment: int, old_memory: rawptr, old_size: int, location := #caller_location) -> ([]byte, mem.Allocator_Error) {
			using self := cast(^ProfiledAllocatorData) allocator_data
			new_memory, error := self.backing_allocator.procedure(self.backing_allocator.data, mode, size, alignment, old_memory, old_size, location)
			if error == .None {
				switch mode {
				case .Alloc, .Alloc_Non_Zeroed:
					EmitAlloc(new_memory, size, callstack_size, secure)
				case .Free:
					EmitFree(old_memory, callstack_size, secure)
				case .Free_All:
					// NOTE: Free_All not supported by this allocator
				case .Resize, .Resize_Non_Zeroed:
					EmitFree(old_memory, callstack_size, secure)
					EmitAlloc(new_memory, size, callstack_size, secure)
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

@(private="file")
EmitAlloc :: #force_inline proc(new_memory: []byte, size: int, callstack_size: i32, secure: b32) {
	when TRACY_HAS_CALLSTACK {
		if callstack_size > 0 {
			___tracy_emit_memory_alloc_callstack(raw_data(new_memory), c.size_t(size), callstack_size, secure)
		} else {
			___tracy_emit_memory_alloc(raw_data(new_memory), c.size_t(size), secure)
		}
	} else {
		___tracy_emit_memory_alloc(raw_data(new_memory), c.size_t(size), secure)
	}
}

@(private="file")
EmitFree :: #force_inline proc(old_memory: rawptr, callstack_size: i32, secure: b32) {
	if old_memory == nil { return }
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


