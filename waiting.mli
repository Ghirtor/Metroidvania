open Tsdl;;

type wait;;

val create_arr : Sdl.renderer -> Sdl.texture array;;
val create : Sdl.renderer -> Sdl.texture array -> wait;;
val destroy : wait -> Sdl.texture array -> unit;;
val event : Sdl.event -> bool ref -> bool ref -> wait -> Sdl.texture array -> Sdl.renderer -> wait;;
val display : Sdl.renderer -> wait -> int -> unit;;
val on_or_off : wait -> Sdl.renderer -> int -> int -> Sdl.texture array -> wait;;
