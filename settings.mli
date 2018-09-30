open Tsdl;;
open Tsdl_ttf;;

type settings;;
type saved_settings;;

val width : int;;
val height : int;;

val solo : int;;
val multi : int;;

val updates_per_second : int;;
val frames_per_second : int;;
val player_speed : int;;
val player_gravity : int;;
val player_jump : int;;
val max_jump_player : float;;
val movable_delay_frame : int;;
val laser_delay_frame : int;;
val decoration_delay_frame : int;;
val endlevel_delay_frame : int;;
val character_shield_delay_frame : int;;
val character_shield_time : int;;
val end_animation_time : int;;

val laser_damages : int;;
val laser_state_delay : int;;

val fire_delay : int;;
val fire_damages : int;;

val pictures_dir : string;;
val levels_dir : string;;
val arenas_dir : string;;

val player_sprite_sheet_dir : string;;
val laser_active_sprite_dir : string;;
val laser_inactive_sprite_dir : string;;
val decoration_active_sprite_dir : string;;
val endlevel_active_sprite_dir : string;;
val endlevel_inactive_sprite_dir : string;;

val get_display_fps : saved_settings -> bool;;
val get_nb_fps : saved_settings -> int;;

val display_settings : settings -> Sdl.renderer -> unit;;
val create_arr : Sdl.renderer -> saved_settings -> Sdl.texture array;;
val create : Sdl.texture array -> saved_settings -> Sdl.renderer -> settings;;
val create_font : unit -> Ttf.font;;
val event : Sdl.event -> settings -> Sdl.renderer -> bool ref -> bool ref -> Sdl.texture array -> saved_settings ref -> settings;;
val display_element : Sdl.texture -> Sdl.renderer -> int -> int -> unit;;
val display_element_left : Sdl.texture -> Sdl.renderer -> int -> int -> unit;;
val is_on : Sdl.texture -> Sdl.renderer -> int -> int -> int -> int -> bool;;
val is_on_left : Sdl.texture -> Sdl.renderer -> int -> int -> int-> int -> bool;;
val on_or_off : settings -> Sdl.renderer -> int -> int -> Sdl.texture array -> settings;;
val create_saved_settings : unit -> saved_settings;;
val create_text : Sdl.renderer -> Sdl.color -> string -> Sdl.texture;;
val destroy : settings -> Sdl.texture array -> unit;;
