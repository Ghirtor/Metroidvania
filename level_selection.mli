open Tsdl;;
open Tsdl_ttf;;

type selection;;

val create : Sdl.renderer -> Sdl.texture array -> int -> selection;;
val event : Sdl.event -> bool ref -> bool ref -> Sdl.texture array -> selection -> Sdl.renderer -> bool ref -> int ref -> selection;;
val destroy_selection : selection -> Sdl.texture array -> unit;;
val display_selection : selection -> Sdl.renderer -> unit;;
val create_arr_menu : Sdl.renderer -> Sdl.texture array;;
val on_or_off : selection -> Sdl.renderer -> int -> int -> Sdl.texture array -> selection;;
val get_name : selection -> int -> string;;
