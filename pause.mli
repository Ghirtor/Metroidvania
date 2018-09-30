open Tsdl;;
open Tsdl_ttf;;

type pause;;

val resume : int;;
val menu : int;;

val create : Sdl.texture array -> pause;;
val arr_texture : Sdl.renderer -> Sdl.texture array;;
val get_resume : pause -> Sdl.texture;;
val get_menu : pause -> Sdl.texture;;
val event : Sdl.event -> pause -> Sdl.renderer -> int -> int -> int ref -> bool ref -> bool ref -> bool ref -> unit;;
val on_or_off : pause -> Sdl.renderer -> int -> int -> int -> int -> Sdl.texture array -> pause;;
val display_pause : pause -> Sdl.renderer -> unit;;
val actions : bool ref -> Sdl.scancode -> unit;;
val free_arr : Sdl.texture array -> unit;;

