type t;;

val create : string -> t;; 

val get_path : t -> string;;

val set_texture : t -> t -> unit;;

val set_texture_from_png : t -> Tsdl.Sdl.renderer -> unit;;

val set_texture_from_bmp : t -> Tsdl.Sdl.renderer -> unit;;

val get_texture : t -> Tsdl.Sdl.texture;;

val store_in_collection : t -> Tsdl.Sdl.rect -> Tsdl.Sdl.renderer -> int -> unit;;

val render_from_collection : t -> int -> int -> Tsdl.Sdl.rect -> Tsdl.Sdl.renderer -> int -> unit;;

val render : t -> int -> int -> Tsdl.Sdl.rect -> Tsdl.Sdl.renderer -> int -> unit;;
