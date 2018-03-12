open Tsdl;;

let user_events = [Sdl.Event.quit; Sdl.Event.key_down];;
let quit = ref false;;

(*let event e =
  let t = (Sdl.Event.get e Sdl.Event.typ) in
  if t = Sdl.Event.quit then quit := true
  else if t = Sdl.Event.key_down then
    begin
      let t' = (Sdl.Event.get e Sdl.Event.keyboard_keycode) in
      if t' = Sdl.K.right then Printf.printf "Right\n" else if t'= Sdl.K.left then Printf.printf "Left\n"
    end
  ;;*)

let display_movable t c r =
  let selected_frame = (Object.select_frame_movable (Object.get_speedX t) (Object.get_speedY t) (Object.get_frame t) (Array.length (Object.get_sprite_left t)) (Array.length (Object.get_sprite_right t)) (Object.get_timer t)) in
  if selected_frame != (Object.get_frame t) then
    begin
      Object.set_frame t selected_frame;
      Object.set_timer t;
    end;
  let sprite = Object.get_current_sprite t in
  Object_texture.render (Object.get_texture t) (Object.get_positionX t) (Object.get_positionY t) sprite r (Object.get_zoom t);;

let display_fixed t c r =
  let selected_frame = (Object.select_frame_fixed (Object.get_frame t) (Array.length (Object.get_sprite_active t)) (Array.length (Object.get_sprite_active t)) (Object.get_timer t) (Object.get_status t)) in
  if selected_frame != (Object.get_frame t) then
    begin
      Object.set_frame t selected_frame;
      Object.set_timer t;
    end;
  let sprite = Object.get_current_sprite t in
  Object_texture.render (Object.get_texture t) (Object.get_positionX t) (Object.get_positionY t) sprite r (Object.get_zoom t);;

(* function to display the lifebar on the screen *)
let display_lifebar bar cam renderer =
  let color = Lifebar.get_color bar in
  let (x,y) = Lifebar.get_xy bar in
  let max_h = Lifebar.get_max_height bar in
  let max_w = Lifebar.get_max_width bar in
  let cam_h = Camera.get_h cam in
  let cam_w = Camera.get_w cam in
  (* the border rectangle *)
  let border = Sdl.Rect.create (x+cam_w/20) (y+cam_h/20) max_w max_h in
  let black = Sdl.Color.create 0 0 0 0 in
  let life_perc = (float_of_int (Lifebar.get_life bar)) /. (float_of_int (Lifebar.get_max bar)) in
  let new_size = int_of_float (life_perc *. float_of_int (max_w)) in
  (* the real rectangle with the life *)
  let new_rect = Sdl.Rect.create (x+cam_w/20) (y+cam_h/20) new_size max_h in
  let () = Tools.set_render_draw_color renderer (Sdl.Color.r color) (Sdl.Color.g color) (Sdl.Color.b color) (Sdl.Color.a color) in
  let () = Tools.render_fill_rect renderer new_rect in
  let () = Tools.set_render_draw_color renderer 0 0 0 (Sdl.Color.a color) in
  let () = Tools.render_draw_rect renderer border in
;;

(*let play () =
  let events = Sdl.Event.create () in
  while  not (!quit) do
    while Sdl.poll_event (Some(events)) do
      event events;
    done;
  done;;*)

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

let char = Object.create_movable 300 200 0 0 1 100 100 Settings.player_sprite_sheet_dir;;
Object_texture.set_texture (Object.get_texture (Object.movable_with_constructor char)) renderer;;
let tab = [|char|];;
let last_key_pressed = ref Sdl.K.left;;
(*let fps = ref (Sdl.get_ticks ());;*)
let laser = Object.create_fixed 100 130 (16*4) (53*4) Settings.laser_active_sprite_dir Sprite_clips.laser;;
Object_texture.set_texture (Object.get_texture (Object.fixed_with_constructor laser)) renderer;;

let event e =
  let t = (Sdl.Event.get e Sdl.Event.typ) in
  if t = Sdl.Event.quit then quit := true
  else if t = Sdl.Event.key_down then
    begin
      let t' = (Sdl.Event.get e Sdl.Event.keyboard_keycode) in
      if t' = Sdl.K.right then
	begin
	  tab.(0) <- Object.right (tab.(0));
	  last_key_pressed := Sdl.K.right;
	end
      else if t'= Sdl.K.left then
	begin
	  tab.(0) <- Object.left (tab.(0));
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
  while  not (!quit) do
    Tools.render_clear renderer;
    while Sdl.poll_event (Some(events)) do
      event events;
    done;
    tab.(0) <- (Object.move tab.(0) (1.0) 640 480);
    Tools.render_copy rectangle rectangle renderer texture;
    Tools.render_copy rectangle rectangle renderer texture2;
    display_fixed (Object.fixed_with_constructor laser) (Camera.create_camera 0 0 480 640) renderer;
    display_movable (Object.movable_with_constructor tab.(0)) (Camera.create_camera 0 0 480 640) renderer;
    Sdl.render_present renderer;
    (*t clock = ref (Sdl.get_ticks ()) in
    while (Int32.to_int (!clock)) < (Int32.to_int (!fps)) + 1000 / Settings.frames_per_second do
      clock := Sdl.get_ticks ();
      Sdl.delay (Int32.of_int (5));
    done;
      fps := (!clock);*)
    Sdl.delay (Int32.of_int (1000 / Settings.frames_per_second));
  done;;
play ();;

(* Sdl.delay (Int32.of_int 20000);; *)
Sdl.free_surface font_img;;
Sdl.destroy_texture texture;; (* destroy texture *)
Sdl.destroy_renderer renderer;; (* destroy renderer *)
Sdl.destroy_window window;;
Sdl.quit ();;
