type t;;

val create: string -> Tsdl.Sdl.renderer -> t;; 

val get_path: t -> string;;

val get_texture: t -> Tsdl.Sdl.texture;;

val render: t -> int -> int -> Tsdl.Sdl.rect -> Tsdl.Sdl.renderer -> unit;;
