type t;;

val create : Object.movable -> Camera.t -> Tsdl.Sdl.color -> t;;
val modify_life : t -> Object.movable -> t;;
val modify_location : t -> Camera.t -> t;;
val modify_color : t -> Tsdl.Sdl.color -> t;;
val get_max : t -> int;;
val get_life : t -> int;;
val get_xy : t -> int * int;;
val get_color : t -> Tsdl.Sdl.color;;
val get_max_height : t -> int;;
val get_max_width : t -> int;;