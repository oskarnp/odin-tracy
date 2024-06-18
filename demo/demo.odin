package demo

TRACY_ENABLE :: #config(TRACY_ENABLE, false)

when !TRACY_ENABLE {
	#panic("TRACY_ENABLE need to be set to true for this demo to be useful.")
}

import "core:fmt"
import "core:time"
import "core:thread"
import "core:mem"
import "core:sync"
import "core:strings"
import "core:math/rand"
import "base:runtime"
import tracy ".."

/*
	Dummy example to show using multiple threads with Tracy.

	Build with:   odin build . -define:TRACY_ENABLE=true
*/

random_generator_using_user_index_as_seed :: proc() -> runtime.Random_Generator {
	@thread_local random_state: runtime.Default_Random_State
	random_state = rand.create(u64(1 + context.user_index)) // 0 value means "use random seed", hence the +1
	return runtime.default_random_generator(&random_state)
}

main :: proc() {
	// For demo purposes, use a known seed for each thread
	context.user_index = 0
	context.random_generator = random_generator_using_user_index_as_seed()

	tracy.SetThreadName("main");

	NUM_WORKERS :: 3;

	sync.barrier_init(&bar, 1 + NUM_WORKERS);

	for i in 1..=NUM_WORKERS {
		context.user_index = i;
		thread.run(worker, context);
	}

	// Profile heap allocations with Tracy for this context.
	context.allocator = tracy.MakeProfiledAllocator(
		self              = &tracy.ProfiledAllocatorData{},
		callstack_size    = 5,
		backing_allocator = context.allocator,
		secure            = true
	)

	for {
		// Marks the end of the frame. This is optional. Useful for
		// applications which has a concept of a frame.
		defer tracy.FrameMark();

		{
			// No name given receives the name of the calling procedure
			tracy.Zone();

			ptr, _ := random_alloc();
			random_sleep();
			free(ptr);

			// Do some deliberate leaking
			_, err := new(int);
	 	}

	 	// Sync all workers to current frame.
	 	sync.barrier_wait(&bar);
	}
}

worker :: proc() {
	context.random_generator = random_generator_using_user_index_as_seed()

	thread_name := strings.clone_to_cstring(fmt.tprintf("worker%i", context.user_index));
	defer delete(thread_name);

	tracy.SetThreadName(thread_name);

	for {
		{
			// No name given receives the name of the calling procedure
			tracy.Zone();
			random_sleep();
		}
		{
			tracy.ZoneN("worker doing stuff");
			random_sleep();
		}
		{
			// Name + Color. Colors in 0xRRGGBB format. 0 means "no color" (use a value
			// close to 0 for black).
			tracy.ZoneNC("worker doing stuff", 0xff0000);
			random_sleep();
		}

		// sync with main thread for next frame
		sync.barrier_wait(&bar);
	}
}

bar : sync.Barrier;

random_sleep :: proc() {
	time.sleep(time.Duration(rand.int_max(25)) * time.Millisecond);
}

random_alloc :: proc() -> (rawptr, mem.Allocator_Error) {
	return mem.alloc(1 + rand.int_max(1024));
}

