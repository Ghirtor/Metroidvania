type t;;

val create: string -> int -> int -> Tsdl.Sdl.renderer -> t;; 

val get_path: t -> string;;

val get_width: t -> int;;

val get_height: t -> int;;

val get_texture: t -> Tsdl.Sdl.texture;;

val render: t -> int -> int -> Tsdl.Sdl.rect -> Tsdl.Sdl.render -> unit;;
