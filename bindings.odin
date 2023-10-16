package tracy

import "core:c"

when ODIN_OS == .Darwin  do foreign import tracy "tracy.dylib"
when ODIN_OS == .Windows do foreign import tracy "tracy.lib"
when ODIN_OS == .Linux   do foreign import tracy "tracy.so"

TracyPlotFormatEnum :: enum i32
{
    TracyPlotFormatNumber,
    TracyPlotFormatMemory,
    TracyPlotFormatPercentage,
    TracyPlotFormatWatt
}

___tracy_source_location_data :: struct {
	name:     cstring,
	function: cstring,
	file:     cstring,
	line:     u32,
	color:    u32,
}

___tracy_c_zone_context :: struct {
	id:     u32,
	active: b32,
}

___tracy_gpu_time_data :: struct {
	gpuTime:  i64,
	queryId:  u16,
	_context: u8,
}

___tracy_gpu_zone_begin_data :: struct {
	srcloc:   u64,
	queryId:  u16,
	_context: u8,
}

___tracy_gpu_zone_begin_callstack_data :: struct {
	srcloc:   u64,
	depth:    i32,
	queryId:  u16,
	_context: u8,
}

___tracy_gpu_zone_end_data :: struct {
	queryId:  u16,
	_context: u8,
}

___tracy_gpu_new_context_data :: struct {
	gpuTime:  i64,
	period:   f32,
	_context: u8,
	flags:    u8,
	type:     u8,
}

___tracy_gpu_context_name_data :: struct {
	_context: u8,
	name:     cstring,
	len:      u16,
}

___tracy_gpu_calibration_data :: struct {
	gpuTime:   i64,
	cpuDelta:  i64,
	_context:  u8,
}

when #config(TRACY_MANUAL_LIFETIME, false) {
	@(default_calling_convention="c")
	foreign tracy {
		___tracy_startup_profiler  :: proc() ---
		___tracy_shutdown_profiler :: proc() ---
	}
}

@(default_calling_convention="c")
foreign tracy {
	___tracy_set_thread_name                            :: proc( name: cstring ) ---

	___tracy_alloc_srcloc                               :: proc( line: u32, source: cstring, sourceSz: c.size_t, function: cstring, functionSz: c.size_t ) -> u64 ---
	___tracy_alloc_srcloc_name                          :: proc( line: u32, source: cstring, sourceSz: c.size_t, function: cstring, functionSz: c.size_t, name: cstring, nameSz: c.size_t ) -> u64 ---

	___tracy_emit_zone_begin                            :: proc( srcloc: ^___tracy_source_location_data, active: b32 ) -> ___tracy_c_zone_context ---
	___tracy_emit_zone_begin_callstack                  :: proc( srcloc: ^___tracy_source_location_data, depth: i32, active: b32 ) -> ___tracy_c_zone_context ---
	___tracy_emit_zone_begin_alloc                      :: proc( srcloc: u64, active: b32 ) -> ___tracy_c_zone_context ---
	___tracy_emit_zone_begin_alloc_callstack            :: proc( srcloc: u64, depth: i32, active: b32 ) -> ___tracy_c_zone_context ---
	___tracy_emit_zone_end                              :: proc( ctx: ___tracy_c_zone_context ) ---
	___tracy_emit_zone_text                             :: proc( ctx: ___tracy_c_zone_context, txt: cstring, size: c.size_t ) ---
	___tracy_emit_zone_name                             :: proc( ctx: ___tracy_c_zone_context, txt: cstring, size: c.size_t ) ---
	___tracy_emit_zone_color                            :: proc( ctx: ___tracy_c_zone_context, color: u32 ) ---
	___tracy_emit_zone_value                            :: proc( ctx: ___tracy_c_zone_context, value: u64 ) ---

	___tracy_emit_gpu_zone_begin                        :: proc( ___tracy_gpu_zone_begin_data ) ---
	___tracy_emit_gpu_zone_begin_callstack              :: proc( ___tracy_gpu_zone_begin_callstack_data ) ---
	___tracy_emit_gpu_zone_begin_alloc                  :: proc( ___tracy_gpu_zone_begin_data ) ---
	___tracy_emit_gpu_zone_begin_alloc_callstack        :: proc( ___tracy_gpu_zone_begin_callstack_data ) ---
	___tracy_emit_gpu_zone_end                          :: proc( ___tracy_gpu_zone_end_data ) ---
	___tracy_emit_gpu_time                              :: proc( ___tracy_gpu_time_data ) ---
	___tracy_emit_gpu_new_context                       :: proc( ___tracy_gpu_new_context_data ) ---
	___tracy_emit_gpu_context_name                      :: proc( ___tracy_gpu_context_name_data ) ---
	___tracy_emit_gpu_calibration                       :: proc( ___tracy_gpu_calibration_data ) ---

	___tracy_emit_gpu_zone_begin_serial                 :: proc( ___tracy_gpu_zone_begin_data ) ---
	___tracy_emit_gpu_zone_begin_callstack_serial       :: proc( ___tracy_gpu_zone_begin_callstack_data ) ---
	___tracy_emit_gpu_zone_begin_alloc_serial           :: proc( ___tracy_gpu_zone_begin_data ) ---
	___tracy_emit_gpu_zone_begin_alloc_callstack_serial :: proc( ___tracy_gpu_zone_begin_callstack_data ) ---
	___tracy_emit_gpu_zone_end_serial                   :: proc( ___tracy_gpu_zone_end_data ) ---
	___tracy_emit_gpu_time_serial                       :: proc( ___tracy_gpu_time_data ) ---
	___tracy_emit_gpu_new_context_serial                :: proc( ___tracy_gpu_new_context_data ) ---
	___tracy_emit_gpu_context_name_serial               :: proc( ___tracy_gpu_context_name_data ) ---
	___tracy_emit_gpu_calibration_serial                :: proc( ___tracy_gpu_calibration_data ) ---

	___tracy_connected                                  :: proc() -> b32 ---

	___tracy_emit_memory_alloc                          :: proc( ptr: rawptr, size: c.size_t, secure: b32 ) ---
	___tracy_emit_memory_alloc_callstack                :: proc( ptr: rawptr, size: c.size_t, depth: i32, secure: b32 ) ---
	___tracy_emit_memory_free                           :: proc( ptr: rawptr, secure: b32 ) ---
	___tracy_emit_memory_free_callstack                 :: proc( ptr: rawptr, depth: i32, secure: b32 ) ---
	___tracy_emit_memory_alloc_named                    :: proc( ptr: rawptr, size: c.size_t, secure: b32, name: cstring ) ---
	___tracy_emit_memory_alloc_callstack_named          :: proc( ptr: rawptr, size: c.size_t, depth: i32, secure: b32, name: cstring ) ---
	___tracy_emit_memory_free_named                     :: proc( ptr: rawptr, secure: b32, name: cstring ) ---
	___tracy_emit_memory_free_callstack_named           :: proc( ptr: rawptr, depth: i32, secure: b32, name: cstring ) ---

	___tracy_emit_message                               :: proc( txt: cstring, size: c.size_t, callstack: i32 ) ---
	___tracy_emit_messageL                              :: proc( txt: cstring, callstack: i32 ) ---
	___tracy_emit_messageC                              :: proc( txt: cstring, size: c.size_t, color: u32, callstack: i32 ) ---
	___tracy_emit_messageLC                             :: proc( txt: cstring, color: u32, callstack: i32 ) ---

	___tracy_emit_frame_mark                            :: proc( name: cstring ) ---
	___tracy_emit_frame_mark_start                      :: proc( name: cstring ) ---
	___tracy_emit_frame_mark_end                        :: proc( name: cstring ) ---
	___tracy_emit_frame_image                           :: proc( image: rawptr, w, h: u16, offset: u8, flip: i32 ) ---

	___tracy_emit_plot                                  :: proc( name: cstring, val: f64 ) ---
	___tracy_emit_plot_float                            :: proc( name: cstring, val: f32 ) ---
	___tracy_emit_plot_int                              :: proc( name: cstring, val: i64 ) ---
	___tracy_emit_plot_config                           :: proc( name: cstring, type: TracyPlotFormatEnum, step, fill: b32, color: u32 ) ---
	___tracy_emit_message_appinfo                       :: proc( txt: cstring, size: c.size_t ) ---

	___tracy_fiber_enter                                :: proc( fiber: cstring ) ---
	___tracy_fiber_leave                                :: proc() ---
}
