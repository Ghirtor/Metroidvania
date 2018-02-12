type movable;;
type fixed;;
type collision;;
type t;;

val null_collision : collision;;

val move : movable -> float -> movable;;
val applyGravity : movable -> movable;;
val change_direction : movable -> movable;;
val jump : movable -> movable;;
val collide : t -> t -> collision;;
val get_damage : movable -> int -> movable;;
val health : movable -> int -> movable;;
val compare : t -> t -> bool;;
val create_movable : int -> int -> int -> int -> int -> int -> int -> int -> int -> movable;;
val create_fixed : int -> int -> int -> int -> fixed;;
val create_null_movable : unit -> movable;;
val create_null_fixed : unit -> fixed;;
val get_id : t -> int;;
val get_positionX : t -> int;;
val get_positionY : t -> int;;
val get_speedX : t -> int;;
val get_speedY : t -> int;;
val get_width : t -> int;;
val get_height : t -> int;;
val get_mass : movable -> int;;
val get_life : movable -> int;;

val get_first_id : collision -> int;;
val get_second_id : collision -> int;;
val get_time : collision -> float;;
val get_damagesA : collision -> int;;
val get_damagesB : collision -> int;;
