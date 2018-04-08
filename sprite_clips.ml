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
let sprite_laser_inactive1 = Sdl.Rect.create 0 11 sprite_laser_width sprite_laser_height;;
let sprite_laser_inactive2 = Sdl.Rect.create 16 11 sprite_laser_width sprite_laser_height;;
let sprite_laser_inactive3 = Sdl.Rect.create 32 11 sprite_laser_width sprite_laser_height;;
let sprite_laser_inactive4 = Sdl.Rect.create 48 11 sprite_laser_width sprite_laser_height;;
let sprite_laser_inactive5 = Sdl.Rect.create 64 11 sprite_laser_width sprite_laser_height;;
let sprite_laser_inactive6 = Sdl.Rect.create 80 11 sprite_laser_width sprite_laser_height;;
let sprite_laser_inactive7 = Sdl.Rect.create 96 11 sprite_laser_width sprite_laser_height;;
let sprite_clips_laser_inactive = [|sprite_laser_inactive1; sprite_laser_inactive2; sprite_laser_inactive3; sprite_laser_inactive4; sprite_laser_inactive5; sprite_laser_inactive6; sprite_laser_inactive7|];;

let sprite_decoration_width = 14;;
let sprite_decoration_height = 15;;
let sprite_decoration_active1 = Sdl.Rect.create 1 1 sprite_decoration_width sprite_decoration_height;;
let sprite_decoration_active2 = Sdl.Rect.create 17 1 sprite_decoration_width sprite_decoration_height;;
let sprite_decoration_active3 = Sdl.Rect.create 33 1 sprite_decoration_width sprite_decoration_height;;
let sprite_decoration_active4 = Sdl.Rect.create 49 1 sprite_decoration_width sprite_decoration_height;;
let sprite_decoration_active5 = Sdl.Rect.create 65 1 sprite_decoration_width sprite_decoration_height;;
let sprite_clips_decoration_active = [|sprite_decoration_active1; sprite_decoration_active2; sprite_decoration_active3; sprite_decoration_active4; sprite_decoration_active5|];;

let sprite_endlevel_width = 16;;
let sprite_endlevel_height = 16;;
let sprite_endlevel_inactive = Sdl.Rect.create 0 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active1 = Sdl.Rect.create 0 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active2 = Sdl.Rect.create 16 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active3 = Sdl.Rect.create 32 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active4 = Sdl.Rect.create 48 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active5 = Sdl.Rect.create 64 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active6 = Sdl.Rect.create 80 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active7 = Sdl.Rect.create 96 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active8 = Sdl.Rect.create 112 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active9 = Sdl.Rect.create 128 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active10 = Sdl.Rect.create 144 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active11 = Sdl.Rect.create 160 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active12 = Sdl.Rect.create 176 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active13 = Sdl.Rect.create 192 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active14 = Sdl.Rect.create 208 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_endlevel_active15 = Sdl.Rect.create 224 0 sprite_endlevel_width sprite_endlevel_height;;
let sprite_clips_endlevel_inactive = [|sprite_endlevel_inactive|];;
let sprite_clips_endlevel_active = [|sprite_endlevel_active1; sprite_endlevel_active2; sprite_endlevel_active3; sprite_endlevel_active4; sprite_endlevel_active5; sprite_endlevel_active6; sprite_endlevel_active7; sprite_endlevel_active8; sprite_endlevel_active9; sprite_endlevel_active10; sprite_endlevel_active11; sprite_endlevel_active12; sprite_endlevel_active13; sprite_endlevel_active14; sprite_endlevel_active15|];;

(* functions *)

let laser = 0;;
let endlevel = 1;;
let decoration = 2;;
let tile = 3;;

let get t =
  if t = laser then [|sprite_clips_laser_inactive;sprite_clips_laser_active|]
  else if t = endlevel then [|[|sprite_endlevel_inactive|];sprite_clips_endlevel_active|]
  else if t = decoration then [|[||];sprite_clips_decoration_active|]
  else [|[||];sprite_clips_laser_active|];;
