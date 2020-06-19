package demo

import "core:fmt"
import "core:time"
import "core:thread"
import "core:mem"
import "core:sync"
import "core:strings"
import "core:math/rand"
import tracy ".."

/*
	Dummy example to show using multiple threads with Tracy.

	Build with:   odin build . -define:TRACY_ENABLE=true

	N.B! the strings passed to Zone* procs need to be globally unique as they
	identify a particular source code location.
*/

main :: proc() {
	r : rand.Rand;
	rand.init(&r, u64(context.user_index));

	tracy.SetThreadName("main");

	NUM_WORKERS :: 3;

	sync.barrier_init(&bar, 1 + NUM_WORKERS);
	defer sync.barrier_destroy(&bar);

	for i in 1..NUM_WORKERS {
		context.user_index = i;
		thread.run(worker, context);
	}

	// Track heap allocations with Tracy for this context.
	context.allocator = tracy.TrackedAllocator(
		self              = &tracy.TrackedAllocatorData{},
		callstack_enable  = true,
		callstack_size    = 5,
		backing_allocator = context.allocator
	);

	for {
		// Marks the end of the frame. This is optional. Useful for applications
		// which has a concept of a frame.
		defer tracy.FrameMark();

		{
			// No name given receives the name of the calling procedure
			tracy.Zone();

			ptr := random_alloc(&r);
			random_sleep(&r);
			free(ptr);

			// Do some deliberate leaking
			new(int);
	 	}

	 	// Sync all workers to current frame.
	 	sync.barrier_wait(&bar);
	}
}

worker :: proc() {
	r : rand.Rand;
	rand.init(&r, u64(context.user_index));

	thread_name := strings.clone_to_cstring(fmt.tprintf("worker%i", context.user_index));
	defer delete(thread_name);

	tracy.SetThreadName(thread_name);

	for {
		{
			// No name given receives the name of the calling procedure
			tracy.Zone();
			random_sleep(&r);
		}
		{
			tracy.ZoneN("worker doing stuff");
			random_sleep(&r);
		}
		{
			// Name + Color. Colors in 0xRRGGBB format. 0 means "no color" (use a value
			// close to 0 for black).
			tracy.ZoneNC("worker doing stuff", 0xff0000);
			random_sleep(&r);
		}

		// sync with main thread for next frame
		sync.barrier_wait(&bar);
	}
}

bar : sync.Barrier;

random_sleep :: proc (r : ^rand.Rand) {
	time.sleep(time.Duration(rand.int_max(25, r)) * time.Millisecond);
}

random_alloc :: proc (r : ^rand.Rand) -> rawptr {
	return mem.alloc(1 + rand.int_max(1024, r));
}