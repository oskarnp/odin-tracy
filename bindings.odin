package tracy

import "core:c"
import "core:os"

when os.OS == "darwin"  do foreign import tracy "tracy.dylib"
when os.OS == "windows" do foreign import tracy "tracy.lib"
when os.OS == "linux"   do foreign import tracy "tracy.o"

___tracy_source_location_data :: struct {
	name     : cstring,
	function : cstring,
	file     : cstring,
	line     : u32,
	color    : u32,
}

___tracy_c_zone_context :: struct {
	id       : u32,
	active   : c.int,
}

TracyCZoneCtx :: ___tracy_c_zone_context;

@(default_calling_convention="c")
foreign tracy {
	___tracy_set_thread_name                 :: proc ( name : cstring ) --- ;
	___tracy_init_thread                     :: proc () --- ;
	___tracy_alloc_srcloc                    :: proc ( line : u32, source : cstring, sourceSz : c.size_t, function : cstring, functionSz : c.size_t ) -> u64 --- ;
	___tracy_alloc_srcloc_name               :: proc ( line : u32, source : cstring, sourceSz : c.size_t, function : cstring, functionSz : c.size_t, name : cstring, nameSz : c.size_t ) -> u64 --- ;
	___tracy_emit_zone_begin                 :: proc ( srcloc : ^___tracy_source_location_data, active : c.int ) -> TracyCZoneCtx --- ;
	___tracy_emit_zone_begin_callstack       :: proc ( srcloc : ^___tracy_source_location_data, depth : c.int, active : c.int ) -> TracyCZoneCtx --- ;
	___tracy_emit_zone_begin_alloc           :: proc ( srcloc : u64, active : c.int ) -> TracyCZoneCtx --- ;
	___tracy_emit_zone_begin_alloc_callstack :: proc ( srcloc : u64, depth : c.int, active : c.int ) -> TracyCZoneCtx --- ;
	___tracy_emit_zone_end                   :: proc ( ctx : TracyCZoneCtx ) --- ;
	___tracy_emit_zone_text                  :: proc ( ctx : TracyCZoneCtx, txt : cstring, size : c.size_t ) --- ;
	___tracy_emit_zone_name                  :: proc ( ctx : TracyCZoneCtx, txt : cstring, size : c.size_t ) --- ;
	___tracy_emit_zone_color                 :: proc ( ctx : TracyCZoneCtx, color : u32 ) --- ;
	___tracy_emit_zone_value                 :: proc ( ctx : TracyCZoneCtx, value : u64 ) --- ;
	___tracy_emit_memory_alloc               :: proc ( ptr : rawptr, size : c.size_t, secure : c.int ) --- ;
	___tracy_emit_memory_alloc_callstack     :: proc ( ptr : rawptr, size : c.size_t, depth : c.int, secure : c.int ) --- ;
	___tracy_emit_memory_free                :: proc ( ptr : rawptr, secure : c.int ) --- ;
	___tracy_emit_memory_free_callstack      :: proc ( ptr : rawptr, depth : c.int, secure : c.int ) --- ;
	___tracy_emit_message                    :: proc ( txt : cstring, size : c.size_t, callstack : c.int ) --- ;
	___tracy_emit_messageL                   :: proc ( txt : cstring, callstack : c.int ) --- ;
	___tracy_emit_messageC                   :: proc ( txt : cstring, size : c.size_t, color : u32, callstack : c.int ) --- ;
	___tracy_emit_messageLC                  :: proc ( txt : cstring, color : u32, callstack : c.int ) --- ;
	___tracy_emit_frame_mark                 :: proc ( name : cstring ) --- ;
	___tracy_emit_frame_mark_start           :: proc ( name : cstring ) --- ;
	___tracy_emit_frame_mark_end             :: proc ( name : cstring ) --- ;
	___tracy_emit_frame_image                :: proc ( image : cstring, w : u16, h : u16, offset : u8, flip : c.int ) --- ;
	___tracy_emit_plot                       :: proc ( name : cstring, val : f64 ) --- ;
	___tracy_emit_message_appinfo            :: proc ( txt : cstring, size : c.size_t ) --- ;
}
