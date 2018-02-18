(*
val size : int;;
val players : Object.Player.t array;;
val monsters : Object.Monster.t;;
val traps : Object.Trap.t;;
val collection : Object.t array;;
val width : int;;
val height : int;;
 *)

val players : Object.movable array;;
val enemies : Object.movable array;;
val elements : Object.fixed array;;
val create_movables : int -> Object.movable array;;
val create_fixed : int -> Object.fixed array;;
val width : unit -> int;;
val height : unit -> int;;
val display : int -> int-> int -> int -> unit;; (* x -> y -> w -> h, x , y, w et h de la caméra *)
val add_movable : Object.movable -> Object.movable array -> int ref -> unit ;;
val add_fixed : Object.fixed -> Object.fixed array -> int ref -> unit;;
val remove_movable : Object.movable -> Object.movable array -> int ref -> unit;;
val remove_fixed : Object.fixed -> Object.fixed array -> int ref -> unit;;
val play : unit -> unit;;
