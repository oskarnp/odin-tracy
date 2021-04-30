package tracy

import "core:c"
import "core:mem"

TrackedAllocatorData :: struct {
	backing_allocator : mem.Allocator,
	tracked_allocator : mem.Allocator,
	callstack_enable  : bool,
	callstack_size    : i32,
}

TrackedAllocator :: proc(
	self : ^TrackedAllocatorData,
	callstack_enable : bool = false,
	callstack_size : i32 = 5,
	backing_allocator := context.allocator) -> mem.Allocator {

	self.callstack_enable = callstack_enable;
	self.callstack_size = callstack_size;
	self.backing_allocator = backing_allocator;
	self.tracked_allocator = mem.Allocator{
		data = self,
		procedure = proc(allocator_data : rawptr, mode : mem.Allocator_Mode, size, alignment : int, old_memory :
		rawptr, old_size : int, location := #caller_location) -> ([]byte, mem.Allocator_Error) {
			self := cast(^TrackedAllocatorData) allocator_data;
			new_memory, error := self.backing_allocator.procedure(self.backing_allocator.data, mode, size, alignment, old_memory, old_size, location);
			if error == .None {
				switch mode {
				case .Alloc:
					if new_memory != nil {
						if self.callstack_enable {
							___tracy_emit_memory_alloc_callstack(raw_data(new_memory), c.size_t(size), self.callstack_size, 1);
						} else {
							___tracy_emit_memory_alloc(raw_data(new_memory), c.size_t(size), 1);
						}
					}
				case .Free:
					if old_memory != nil {
						___tracy_emit_memory_free(old_memory, 1);
					}
				case .Free_All:
					// NOTE: Free_All not supported by this allocator
				case .Resize:
					if old_memory != nil {
						___tracy_emit_memory_free(old_memory, 1);
					}
					if new_memory != nil {
						if self.callstack_enable {
							___tracy_emit_memory_alloc_callstack(raw_data(new_memory), c.size_t(size), self.callstack_size, 1);
						}
						else {
							___tracy_emit_memory_alloc(raw_data(new_memory), c.size_t(size), 1);
						}
					}
				case .Query_Info:
					// TODO
				case .Query_Features:
					// TODO
				}
			}
			return new_memory, error;
		},
	};
	return self.tracked_allocator;
}
