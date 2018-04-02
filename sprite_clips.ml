open Tsdl;;

(* sprites for the player  *)
let sprite_player_zoom = 3;;
let sprite_player_moving_width = 41;;
let sprite_player_moving_height = 45;;
let sprite_player_stopped_width = 41;;
let sprite_player_stopped_height = 45;;
let sprite_player_jump_left1 = Sdl.Rect.create 92 1151 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_left2 = Sdl.Rect.create 42 1151 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_left3 = Sdl.Rect.create 192 1101 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_left4 = Sdl.Rect.create 142 1151 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_left5 = Sdl.Rect.create 92 1101 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_left6 = Sdl.Rect.create 42 1101 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_left7 = Sdl.Rect.create 192 1151 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_left8 = Sdl.Rect.create 142 1151 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_right1 = Sdl.Rect.create 342 1151 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_right2 = Sdl.Rect.create 392 1101 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_right3 = Sdl.Rect.create 242 1101 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_right4 = Sdl.Rect.create 292 1101 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_right5 = Sdl.Rect.create 342 1101 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_right6 = Sdl.Rect.create 392 1101 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_right7 = Sdl.Rect.create 242 1151 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_jump_right8 = Sdl.Rect.create 292 1151 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left1 = Sdl.Rect.create 192 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left2 = Sdl.Rect.create 142 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left3 = Sdl.Rect.create 92 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left4 = Sdl.Rect.create 42 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left5 = Sdl.Rect.create 192 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left6 = Sdl.Rect.create 142 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left7 = Sdl.Rect.create 92 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left8 = Sdl.Rect.create 42 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left9 = Sdl.Rect.create 192 750 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_left10 = Sdl.Rect.create 142 751 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right1 = Sdl.Rect.create 242 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right2 = Sdl.Rect.create 292 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right3 = Sdl.Rect.create 342 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right4 = Sdl.Rect.create 392 651 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right5 = Sdl.Rect.create 242 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right6 = Sdl.Rect.create 292 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right7 = Sdl.Rect.create 342 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right8 = Sdl.Rect.create 392 701 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right9 = Sdl.Rect.create 242 750 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_right10 = Sdl.Rect.create 292 750 sprite_player_moving_width sprite_player_moving_height;;
let sprite_player_stopped_right = Sdl.Rect.create 242 0 sprite_player_stopped_width sprite_player_stopped_height;;
let sprite_player_stopped_left = Sdl.Rect.create 192 0 sprite_player_stopped_width sprite_player_stopped_height;;
let sprite_clips_player_stopped = [|sprite_player_stopped_left; sprite_player_stopped_right|];;
let sprite_clips_player_left = [|sprite_player_left1; sprite_player_left2; sprite_player_left3; sprite_player_left4; sprite_player_left5; sprite_player_left6; sprite_player_left7; sprite_player_left8; sprite_player_left9; sprite_player_left10|];;
let sprite_clips_player_right = [|sprite_player_right1; sprite_player_right2; sprite_player_right3; sprite_player_right4; sprite_player_right5; sprite_player_right6; sprite_player_right7; sprite_player_right8; sprite_player_right9; sprite_player_right10|];;
let sprite_clips_player_jump_left = [|sprite_player_jump_left1; sprite_player_jump_left2; sprite_player_jump_left3; sprite_player_jump_left4; sprite_player_jump_left5; sprite_player_jump_left6; sprite_player_jump_left7; sprite_player_jump_left8|];;
let sprite_clips_player_jump_right = [|sprite_player_jump_right1; sprite_player_jump_right2; sprite_player_jump_right3; sprite_player_jump_right4; sprite_player_jump_right5; sprite_player_jump_right6; sprite_player_jump_right7; sprite_player_jump_right8|];;


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
