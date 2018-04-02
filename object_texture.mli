type t;;

val create : string -> t;; 

val get_path : t -> string;;

val set_texture : t -> Tsdl.Sdl.renderer -> unit;;

val get_texture : t -> Tsdl.Sdl.texture;;

val render : t -> int -> int -> Tsdl.Sdl.rect -> Tsdl.Sdl.renderer -> int -> unit;;
