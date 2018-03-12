open Tsdl;;

(* sprites for the player  *)
let sprite_player_zoom = 3;;
let sprite_player_moving_width = 41;;
let sprite_player_moving_height = 45;;
let sprite_player_stopped_width = 25;;
let sprite_player_stopped_height = 48;;
let sprite_player_left1 = Sdl.Rect.create 192 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left2 = Sdl.Rect.create 142 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left3 = Sdl.Rect.create 94 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left4 = Sdl.Rect.create 43 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left5 = Sdl.Rect.create 193 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left6 = Sdl.Rect.create 142 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left7 = Sdl.Rect.create 93 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left8 = Sdl.Rect.create 44 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right1 = Sdl.Rect.create 243 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right2 = Sdl.Rect.create 292 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right3 = Sdl.Rect.create 340 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right4 = Sdl.Rect.create 389 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right5 = Sdl.Rect.create 242 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right6 = Sdl.Rect.create 292 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right7 = Sdl.Rect.create 342 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right8 = Sdl.Rect.create 389 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_stopped = Sdl.Rect.create 0 0 sprite_player_stopped_width sprite_player_stopped_height;;
let sprite_clips_player_left = [|sprite_player_left1; sprite_player_left2; sprite_player_left3; sprite_player_left4; sprite_player_left5; sprite_player_left6; sprite_player_left7; sprite_player_left8|];;
let sprite_clips_player_right = [|sprite_player_right1; sprite_player_right2; sprite_player_right3; sprite_player_right4; sprite_player_right5; sprite_player_right6; sprite_player_right7; sprite_player_right8|];;

(* sprites for fixed objects *)

let sprite_laser_zoom = 4;;
let sprite_laser_width = 16;;
let sprite_laser_height = 53;;
let sprite_laser_active1 = Sdl.Rect.create 0 11 sprite_laser_width sprite_laser_height;;
let sprite_laser_active2 = Sdl.Rect.create 16 11 sprite_laser_width sprite_laser_height;;
let sprite_clips_laser_active = [|sprite_laser_active1; sprite_laser_active2|];;

(* functions *)

let laser = 0;;

let get t =
  if t = laser then sprite_clips_laser_active else failwith "invalid type";;
