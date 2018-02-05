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
exception not_found;;
val width : int;;
val height : int;;
val display : int -> int -> unit;; (* x -> y, x et y du personnage *)
val add : Object.t -> Object.t array -> Object.t array;;
val remove : Object.t -> Object.t array -> Object.t array;;
val create_collection : unit -> Object.t array;;
