val epsilon : float;;

val sdl_initialize : unit -> unit;;
val create_window : string -> int -> int -> Tsdl.Sdl.Window.flags -> Tsdl.Sdl.window;;
val get_window_surface : Tsdl.Sdl.window -> Tsdl.Sdl.surface;;
val create_renderer : Tsdl.Sdl.window -> Tsdl.Sdl.Renderer.flags -> Tsdl.Sdl.renderer;;
val create_texture : Tsdl.Sdl.renderer -> Tsdl.Sdl.Pixel.format_enum -> Tsdl.Sdl.Texture.access -> int -> int -> Tsdl.Sdl.texture;;
val set_render_target : Tsdl.Sdl.renderer -> Tsdl.Sdl.texture -> unit;;
val render_copy : Tsdl.Sdl.rect -> Tsdl.Sdl.rect -> Tsdl.Sdl.renderer -> Tsdl.Sdl.texture -> unit;;
val load_bmp : string -> Tsdl.Sdl.surface;;
val load_png : string -> Tsdl.Sdl.surface;;
val create_texture_from_surface : Tsdl.Sdl.renderer -> Tsdl.Sdl.surface -> Tsdl.Sdl.texture;;
val query_texture : Tsdl.Sdl.texture -> (Tsdl.Sdl.Pixel.format_enum * Tsdl.Sdl.Texture.access * (int * int));;
val render_clear : Tsdl.Sdl.renderer -> unit;;
val close : unit -> unit;;
val font : Tsdl_ttf.Ttf.font;;
val create_surface_from_font : Tsdl_ttf.Ttf.font -> string -> Tsdl.Sdl.color -> Tsdl.Sdl.surface;;
val render_fill_rect : Tsdl.Sdl.renderer -> Tsdl.Sdl.rect -> unit;;
val render_draw_rect : Tsdl.Sdl.renderer -> Tsdl.Sdl.rect -> unit;;
val set_render_draw_color : Tsdl.Sdl.renderer -> int -> int -> int -> int -> unit;;
val set_render_draw_blend_mode : Tsdl.Sdl.renderer -> Tsdl.Sdl.Blend.mode -> unit;;
val render_copy_ex : Tsdl.Sdl.rect -> Tsdl.Sdl.rect ->Tsdl.Sdl.renderer -> Tsdl.Sdl.texture -> float -> Tsdl.Sdl.point -> Tsdl.Sdl.flip -> unit;;
val get_levels : unit -> string array;;
val get_next_level : string -> int;;
val get_arenas : unit -> string array;;
val get_arena_rank : string -> int;;
val create_texture_from_font : Tsdl.Sdl.renderer -> string -> Tsdl.Sdl.color -> Tsdl_ttf.Ttf.font -> Tsdl.Sdl.texture;;
val create_background : string -> Tsdl.Sdl.renderer -> Tsdl.Sdl.texture;;
val free_arr : Tsdl.Sdl.texture array -> unit;;
