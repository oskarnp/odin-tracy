package tracy;

import "core:c";
import "core:strings";

Enabled            :: #config(TRACY_ENABLE, false);
SourceLocationData :: ___tracy_source_location_data;
ZoneCtx            :: ___tracy_c_zone_context;

@(deferred_out=ZoneEnd)
Zone :: #force_inline proc (loc := #caller_location) -> (ctx : ZoneCtx) {
	when Enabled {
		ctx = ZoneBegin(loc);
	}
	return;
};

@(deferred_out=ZoneEnd)
ZoneN :: #force_inline proc(name : string, loc := #caller_location) -> (ctx : ZoneCtx) {
	when Enabled {
		ctx = ZoneBegin(loc);
		___tracy_emit_zone_name(ctx, _sl(name));
	}
	return;
};

@(deferred_out=ZoneEnd)
ZoneC :: #force_inline proc (color : u32, loc := #caller_location) -> (ctx : ZoneCtx) {
	when Enabled {
		ctx = ZoneBegin(loc);
		___tracy_emit_zone_color(ctx, color);
	}
	return;
};

@(deferred_out=ZoneEnd)
ZoneNC :: #force_inline proc (name : string, color : u32, loc := #caller_location) -> (ctx : ZoneCtx) {
	when Enabled {
		ctx = ZoneBegin(loc);
		___tracy_emit_zone_name(ctx, _sl(name));
		___tracy_emit_zone_color(ctx, color);
	}
	return;
};

@(disabled=!Enabled)
ZoneText :: #force_inline proc (ctx: ZoneCtx, text: string) {
	___tracy_emit_zone_text(ctx, _sl(text));
};

@(disabled=!Enabled)
ZoneEnd :: proc (ctx : ZoneCtx) {
	___tracy_emit_zone_end(ctx);
};

ZoneBegin :: proc (loc := #caller_location) -> (ctx: ZoneCtx) {
	when Enabled {
		/* From manual, page 40:
		     Before the ___tracy_alloc_* functions are called on a non-main thread for the
		     first time, care should be taken to ensure that ___tracy_init_thread has been
		     called first. The ___tracy_init_thread function initializes per-thread
		     structures Tracy uses and can be safely called multiple times.
		*/
		// NOTE(Oskar): We could do @thread_local here and avoid the function call. But probably not worth the trouble?
		___tracy_init_thread();

		/* From manual, page 41:
		     The variable representing an allocated source location is of an opaque type.
		     After it is passed to one of the zone begin functions, its value cannot be
		     reused (the variable is consumed). You must allocate a new source location for
		     each zone begin event, even if the location data would be the same as in the
		     previous instance.
		*/
		id := ___tracy_alloc_srcloc(u32(loc.line), _sl(loc.file_path), _sl(loc.procedure));
		ctx = ___tracy_emit_zone_begin_alloc_callstack(id, 2, 1);
	}
	return;
};

// Important: String passed to FrameMarkStart must be pooled (interned) and
// identical to the one passed to FrameMarkEnd.  Odin's string literals
// satisfies this requirement, but remember we need this to also be
// 0-terminated.
@(disabled=!Enabled)
FrameMarkStart :: #force_inline proc (name : cstring) {
	___tracy_emit_frame_mark_start(name);
};

@(disabled=!Enabled)
FrameMarkEnd :: #force_inline proc (name: cstring) {
	___tracy_emit_frame_mark_end(name);
};

@(disabled=!Enabled)
FrameMark :: #force_inline proc (name : cstring = nil) {
	___tracy_emit_frame_mark(name);
};

@(disabled=!Enabled)
SetThreadName :: #force_inline proc (name: cstring) {
	___tracy_set_thread_name(name);
}

// Helper for passing cstring+length to Tracy functions.
@private _sl :: proc (s : string) -> (cstring, c.size_t) {
	return cstring(raw_data(s)), c.size_t(len(s));
};
