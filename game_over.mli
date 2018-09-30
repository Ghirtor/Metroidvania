open Tsdl;;

val retry : int;;
val quit : int;;
val close : int;;

val display : Sdl.renderer -> bool -> int;;
val create_texture_from_font : Sdl.renderer -> string -> Sdl.color -> Tsdl_ttf.Ttf.font -> Sdl.texture;;
val create_background : string -> Sdl.renderer -> Sdl.texture;;