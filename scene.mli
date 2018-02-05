(*
val size : int;;
val players : Object.Player.t array;;
val monsters : Object.Monster.t;;
val traps : Object.Trap.t;;
val collection : Object.t array;;
val width : int;;
val height : int;;
 *)

val players : Object.t array;;
val enemies : Object.t array;;
val elements : Object.t array;;
val create_movables : unit -> Object.movable array;;
val create_fixed : unit -> Object.fixed array;;
val width : unit -> int;;
val height : unit -> int;;
val display : int -> int-> int -> int -> unit;; (* x -> y -> w -> h, x , y, w et h de la caméra *)
val add : Object.t -> Object.t array -> int ref -> unit ;;
val remove : Object.t -> Object.t array -> int ref -> unit;;
val play : unit -> unit;;
