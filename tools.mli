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
