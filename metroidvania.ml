open Tsdl;;
open Tsdl_ttf;;

let user_events = [Sdl.Event.quit; Sdl.Event.key_down];;
let quit = ref false;;

let display_movable t c r =
  let selected_frame = (Object.select_frame_movable (Object.get_speedX t) (Object.get_speedY t) (Object.get_frame t) (Array.length (Object.get_sprite_left t)) (Array.length (Object.get_sprite_right t)) (Object.get_timer t)) in
  if selected_frame != (Object.get_frame t) then
    begin
      Object.set_frame t selected_frame;
      Object.set_timer t;
    end;
  let sprite = Object.get_current_sprite t in
  Object_texture.render (Object.get_texture t) (int_of_float (Object.get_positionX t)) (int_of_float (Object.get_positionY t)) sprite r (Object.get_zoom t);;

let display_fixed t c r =
  let selected_frame = (Object.select_frame_fixed (Object.get_frame t) (Array.length (Object.get_sprite_active t)) (Array.length (Object.get_sprite_active t)) (Object.get_timer t) (Object.get_status t)) in
  if selected_frame != (Object.get_frame t) then
    begin
      Object.set_frame t selected_frame;
      Object.set_timer t;
    end;
  let sprite = Object.get_current_sprite t in
  Object_texture.render (Object.get_texture t) (int_of_float (Object.get_positionX t)) (int_of_float (Object.get_positionY t)) sprite r (Object.get_zoom t);;

let display_fps r lt =
  let color = Sdl.Color.create 255 255 255 255 in
  let surface = Tools.create_surface_from_font Tools.font ((string_of_int lt)^" fps") color in
  let texture = Tools.create_texture_from_surface r surface in
  let (_,_,(w,h)) = Tools.query_texture texture in
  let src = Sdl.Rect.create 0 0 w h in
  let dst = Sdl.Rect.create 300 300 w h in
  Tools.render_copy src dst r texture; ();;

Tools.sdl_initialize ();;
let window = Tools.create_window "metroidvania" 640 480 (Sdl.Window.windowed);;

let renderer = Tools.create_renderer window (Sdl.Renderer.(accelerated + presentvsync));; (* create renderer *)
Sdl.render_present renderer;; (* set this renderer as active *)
(* let texture = create_texture renderer (Sdl.Pixel.format_rgba4444) (Sdl.Texture.access_target) 640 480;; (* create texture *)
set_renderer_target renderer texture;; (* the modifications below will be applied on the texture *)
let rectangle = Sdl.Rect.create 0 0 640 480;;
   renderer_copy rectangle rectangle renderer texture;;*)
let font_img = Tools.load_png "pictures/scene1_back_lvl1.png";;
let texture = Tools.create_texture_from_surface renderer font_img;;
let font_img2 = Tools.load_png "pictures/scene1_back_lvl2.png";;
let texture2 = Tools.create_texture_from_surface renderer font_img2;;
let texture_infos = Tools.query_texture texture;;
let rectangle = Sdl.Rect.create 0 0 (64*3) (96*3);;
Tools.render_copy rectangle rectangle renderer texture;;
Tools.render_copy rectangle rectangle renderer texture2;;
Sdl.render_present renderer;;

let char = Object.create_movable 300.0 200.0 0.0 0.0 1 100 100 Settings.player_sprite_sheet_dir;;
Object_texture.set_texture (Object.get_texture (Object.movable_with_constructor char)) renderer;;
let tab = [|char|];;
let last_key_pressed = ref Sdl.K.left;;
(*let fps = ref (Sdl.get_ticks ());;*)
let laser = Object.create_fixed 100.0 130.0 (16*4) (53*4) Settings.laser_active_sprite_dir Sprite_clips.laser;;
Object_texture.set_texture (Object.get_texture (Object.fixed_with_constructor laser)) renderer;;

(* The display of the lifebar *)
let display_lifebar bar cam hero renderer =
  let new_bar = Lifebar.modify_life bar hero in
  let color = Lifebar.get_color bar in
  let (x,y) = Lifebar.get_xy bar in
  let max_h = Lifebar.get_max_height bar in
  let max_w = Lifebar.get_max_width bar in
  let cam_h = (Camera.get_h cam)/20 in
  let cam_w = (Camera.get_w cam)/20 in
  let border_size = cam_h/5 in
  (* the border rectangle *)
  let border = Sdl.Rect.create (x+cam_w-border_size) (y+cam_h-border_size) (max_w+2*border_size) (max_h+2*border_size) in
  let life_perc = (float_of_int (Lifebar.get_life bar)) /. (float_of_int (Lifebar.get_max bar)) in
  let new_size = int_of_float (life_perc *. float_of_int (max_w)) in
  (* the real rectangle with the life *)
  let new_rect = Sdl.Rect.create (x+cam_w) (y+cam_h) new_size max_h in
  let border_of_border = Sdl.Rect.create x (y+cam_h-border_size) (max_w+border_size+cam_w) (max_h+2*border_size) in
  let square_width = cam_w in
  let square_height = (max_h+2*border_size) in
  let square = Sdl.Rect.create x (y+cam_h-border_size) square_width square_height in
  let cross_height = (3*(cam_w-border_size)/5) in
  let cross_width = ((max_h+2*border_size)/5) in
  let cross_a = Sdl.Rect.create (x+square_width/2-cross_height/2) (y+cam_h-border_size+square_height/2-cross_width/2) cross_height cross_width in
  let cross_b = Sdl.Rect.create (x+square_width/2-cross_width/2) (y+cam_h-border_size+square_height/2-cross_height/2) cross_width cross_height in
  let border_square = Sdl.Rect.create x (y+cam_h-border_size) (cam_w-border_size) (max_h+2*border_size) in
  let () = Tools.set_render_draw_color renderer 0 0 0 (Sdl.Color.a color) in
  let () = Tools.render_fill_rect renderer border in
  let () = Tools.render_fill_rect renderer square in
  let () = Tools.set_render_draw_color renderer 255 255 255 (Sdl.Color.a color) in
  let () = Tools.render_draw_rect renderer border_of_border in
  let () = Tools.set_render_draw_color renderer (Sdl.Color.r color) (Sdl.Color.g color) (Sdl.Color.b color) (Sdl.Color.a color) in
  let () = Tools.render_fill_rect renderer cross_a in
  let () = Tools.render_fill_rect renderer cross_b in
  let () = Tools.render_fill_rect renderer new_rect in
  let () = Tools.set_render_draw_color renderer 0 0 0 (Sdl.Color.a color) in
  new_bar
;;

let event e c =
  let t = (Sdl.Event.get e Sdl.Event.typ) in
  if t = Sdl.Event.quit then quit := true
  else if t = Sdl.Event.key_down then
    begin
      let t' = (Sdl.Event.get e Sdl.Event.keyboard_keycode) in
      if t' = Sdl.K.right then
	begin
	  tab.(0) <- Object.right (tab.(0)) c;
	  last_key_pressed := Sdl.K.right;
	end
      else if t'= Sdl.K.left then
	begin
	  tab.(0) <- Object.left (tab.(0)) c;
	  last_key_pressed := Sdl.K.left;
	end
    end
  else if t = Sdl.Event.key_up then
    begin
      let t' = (Sdl.Event.get e Sdl.Event.keyboard_keycode) in
      if t' = (!last_key_pressed) then tab.(0) <- Object.stop (tab.(0))
    end
;;

let play () =
  let events = Sdl.Event.create () in
  let timer = ref (Tsdl.Sdl.get_ticks ()) in (* timer used to calculate the time of a round *)
  let additional_timer = ref (Int32.of_int 0) in (* timer used to compensate the timeout of the previous round *)
  let timer_update_fps = ref (Tsdl.Sdl.get_ticks ()) in (* begin of timer to calculate next fps mean during time_update_fps *)
  let loop = ref 0 in (* count of turns before refreshing fps time *)
  let time_update_fps = 75 in (* time targeted before updating current fps *)
  let fps = ref (Settings.frames_per_second) in (* current fps *)
  let cam = Camera.create_camera 0 0 480 640 in
  let bar = ref (Lifebar.create char cam 100) in
  while  not (!quit) do
    timer := Tsdl.Sdl.get_ticks ();
    Tools.render_clear renderer;
    while Sdl.poll_event (Some(events)) do
      event events (!additional_timer);
    done;
    tab.(0) <- (Object.applyGravity (tab.(0)) (!additional_timer));
    tab.(0) <- (Object.move tab.(0) (1.0) 640 480);
    tab.(0) <- (Object.apply_friction (tab.(0)) (!additional_timer)); (* apply friction at the end of turn to avoid unlimited gravity *)
    Tools.render_copy rectangle rectangle renderer texture;
    Tools.render_copy rectangle rectangle renderer texture2;
    display_fixed (Object.fixed_with_constructor laser) (Camera.create_camera 0 0 480 640) renderer;
    display_movable (Object.movable_with_constructor tab.(0)) (Camera.create_camera 0 0 480 640) renderer;
    bar := display_lifebar (!bar) cam char renderer;
    display_fps renderer (!fps);
    Sdl.render_present renderer;
    let diff_timer_fps = Int32.to_int (Int32.sub (Tsdl.Sdl.get_ticks ()) (!timer_update_fps)) in
    if (diff_timer_fps >= time_update_fps) then begin
      fps := int_of_float ((float_of_int 1000) /. ((float_of_int diff_timer_fps) /. (float_of_int ((!loop) + 1))));
      loop := 0;
      timer_update_fps := Tsdl.Sdl.get_ticks ();
    end
    else loop := !loop + 1;
    let diff = (Int32.sub (Int32.of_int (1000 / Settings.frames_per_second)) ((Int32.sub (Tsdl.Sdl.get_ticks ()) (!timer)))) in
    additional_timer :=  (if (Int32.to_int diff) < 0 then Int32.abs diff else Int32.of_int 0);
    Sdl.delay (Int32.of_int (max 0 (Int32.to_int (Int32.sub (Int32.of_int (1000 / Settings.frames_per_second)) (Int32.sub (Tsdl.Sdl.get_ticks ()) (!timer))))));
  done;;
play ();;

Sdl.free_surface font_img;;
Sdl.destroy_texture texture;; (* destroy texture *)
Sdl.destroy_renderer renderer;; (* destroy renderer *)
Sdl.destroy_window window;;
Tools.close ();;
