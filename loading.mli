open Tsdl;;
open Tsdl_ttf;;

type loading;;

val create : Sdl.renderer -> loading;;
val display : Sdl.renderer -> loading -> int -> unit;;
val event : Tsdl.Sdl.event -> bool ref -> unit;;
val destroy_load : loading -> unit;;