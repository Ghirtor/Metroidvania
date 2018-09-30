type background;;

val create_null_background : unit -> background;;
val create : int -> int -> int -> int -> int -> string -> background;;
val store_texture : background -> Tsdl.Sdl.renderer -> unit;;
val set_texture : Tsdl.Sdl.renderer -> unit;;
val to_box : background -> Tsdl.Sdl.rect;;
val free : unit -> unit;;
val get_x : background -> int;;
val get_y : background -> int;;
val get_w : background -> int;;
val get_h : background -> int;;
val get_zoom : background -> int;;
val get_texture : background -> Object_texture.t;;
val get_sprite : background -> Tsdl.Sdl.rect;;
val get_id : background -> int;;

