(*
val size : int;;
val players : Object.Player.t array;;
val monsters : Object.Monster.t;;
val traps : Object.Trap.t;;
val collection : Object.t array;;
val width : int;;
val height : int;;
 *)
type scene;;

val get_enemy_display : unit -> bool;;

val win : int;;
val continue : int;;
(* max heroes, max enemies, max elements, width, height, camera*)
val create : Object.movable array -> Object.movable array -> Object.movable array -> Object.fixed array -> Object.fixed array -> Object.fixed array -> Object.fixed array -> Background.background array -> int -> int -> Camera.t -> scene;;
(* Array of heroes * number of heroes in the array *)
val get_friendly_bullets : scene -> Bullet.bullet array;;
val get_enemy_bullets : scene -> Bullet.bullet array;;
val get_characters :scene -> Object.movable array;;
val nb_characters : scene -> int;;
val get_enemies : scene -> Object.movable array;;
val nb_enemies : scene -> int;;
val get_monsters : scene -> Object.movable array;;
val nb_monsters : scene -> int;;
val get_decoration : scene -> Object.fixed array;;
val nb_decoration : scene -> int;;
val get_tiles : scene -> Object.fixed array;;
val nb_tiles : scene -> int;;
val get_traps : scene -> Object.fixed array;;
val nb_traps : scene -> int;;
val get_endlevels : scene -> Object.fixed array;;
val get_backgrounds : scene -> Background.background array;;
val get_width : scene -> int;;
val get_height : scene -> int;;
val get_camera : scene -> Camera.t;;
val change_camera : Camera.t -> scene -> unit;;
val remove_character : Object.movable -> scene -> unit;;
val remove_enemy : Object.movable -> scene -> unit;;
val remove_monster : Object.movable -> scene -> unit;;
val remove_decoration : Object.fixed -> scene -> unit;;
val remove_tile : Object.fixed -> scene -> unit;;
val remove_trap : Object.fixed -> scene -> unit;;
val set_textures : scene -> Tsdl.Sdl.renderer -> unit;;
val get_backgrounds_in_areas : scene -> Tsdl.Sdl.rect -> Background.background array;;
val get_tiles_in_areas : scene -> Tsdl.Sdl.rect -> Object.fixed array;;
val update : scene -> bool -> string -> int;;
val free : scene -> unit;;
val add_friendly_bullet : scene -> Bullet.bullet -> bool -> bool -> unit;;
val add_enemy_bullet : scene -> Bullet.bullet -> unit;;
