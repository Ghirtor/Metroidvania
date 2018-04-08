type t;;

val get_x : t -> int;;
val get_y : t -> int;;
val get_h : t -> int;;
val get_w : t -> int;;

val to_box : t -> Tsdl.Sdl.rect;;
val create_camera : int -> int -> int -> int -> t;;
(* x -> y -> height -> width -> new camera*)
val modify_camera : t -> int -> int -> t;;
(* camera -> x -> y -> new camera *)
val modify_size : t -> int -> int -> t;;
(* camera -> height -> width -> new camera *)
(*val move_camera : t -> int -> int -> int -> int -> int -> int -> t;;*)
val move_camera : t -> float -> float -> int -> int -> int -> int -> t;;
