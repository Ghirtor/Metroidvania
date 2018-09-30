open Tsdl;;

val replay : int;;
val next : int;;

val display : Sdl.renderer -> string -> bool -> bool ref -> string -> bool -> bool * string;;
(* renderer -> time to complete the level -> best score or not -> the bool ref of the loop of menu -> the name of the level -> true: multi, false: solo *)