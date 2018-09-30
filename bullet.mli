type bullet;;

val max_travel_dist : float;;

val create : float -> float -> int -> bullet;;
val create_null_bullet : unit -> bullet;;

val store_texture : Tsdl.Sdl.renderer -> unit;;
val move : bullet -> bullet;;
val collide : bullet -> bullet;;
val to_box : bullet -> Tsdl.Sdl.rect;;

val get_x : bullet -> float;;
val get_y : bullet -> float;;
val get_collided : bullet -> bool;;
val get_total_dist : bullet -> float;;
val get_zoom : bullet -> int;;
val get_h : bullet -> int;;
val get_w : bullet -> int;;
val get_texture : unit -> Object_texture.t;;
val get_current_sprite : bullet -> Tsdl.Sdl.rect;;

val free : unit -> unit;;
