open Tsdl;;
open Tsdl_ttf;;

let user_events = [Sdl.Event.quit; Sdl.Event.key_down];;
let quit = ref false;;
Tools.sdl_initialize ();;
let window = Tools.create_window "metroidvania" Settings.width Settings.height (Sdl.Window.windowed);;
let renderer = Tools.create_renderer window (Sdl.Renderer.(accelerated + presentvsync));; (* create renderer *)
Sdl.render_present renderer;; (* set this renderer as active *)
let color = Sdl.Color.create 255 255 255 255;;
let fps_tab = Array.init 300 (fun i -> Tools.create_texture_from_surface renderer (Tools.create_surface_from_font Tools.font ((string_of_int i)^" fps") color));; (* preload all fps fonts to avoid memory issues *)

let display_movable t c r =
  let selected_frame = (Object.select_frame_movable (Object.get_speedX t) (Object.get_speedY t) (Object.get_frame t) (Array.length (Object.get_sprite_left t)) (Array.length (Object.get_sprite_right t)) (Object.get_timer t)) in
  if selected_frame != (Object.get_frame t) then
    begin
      Object.set_frame t selected_frame;
      Object.set_timer t;
    end;
  let sprite = Object.get_current_sprite t in
  Object_texture.render (Object.get_texture t) ((int_of_float (Object.get_positionX t)) - (Camera.get_x c)) ((int_of_float (Object.get_positionY t)) - (Camera.get_y c)) sprite r (Object.get_zoom t);;

let display_fixed t c r =
  if not (String.equal (Object.get_subtype t) "TILE") then begin
    let selected_frame = (Object.select_frame_fixed (Object.get_frame t) (Array.length (Object.get_sprite_active t)) (Array.length (Object.get_sprite_active t)) (Object.get_timer t) (Object.get_status t) (Object.get_subtype t)) in
    if selected_frame != (Object.get_frame t) then
      begin
	Object.set_frame t selected_frame;
	Object.set_timer t;
      end;
  end;
  let sprite = Object.get_current_sprite t in
  Object_texture.render_from_collection (Object.get_texture t) ((int_of_float (Object.get_positionX t)) - (Camera.get_x c)) ((int_of_float (Object.get_positionY t)) - (Camera.get_y c)) sprite r (Object.get_zoom t);;

let display_background t c r =
  let sprite = Background.get_sprite t in
  Object_texture.render (Background.get_texture t) ((Background.get_x t) - (Camera.get_x c)) ((Background.get_y t) - (Camera.get_y c)) sprite r (Background.get_zoom t);;

let cam = ref (Camera.create_camera 0 0 Settings.height Settings.width);;

let display_fps r lt c =
  let (_,_,(w,h)) = Tools.query_texture (fps_tab.(lt)) in
  let src = Sdl.Rect.create 0 0 w h in
  let dst = Sdl.Rect.create ((Camera.get_w (!cam)) - w - 10) 10 w h in
  Tools.render_copy src dst r (fps_tab.(min lt 299)); ();;

let display_scene s r =
  let characters = Scene.get_characters s in
  let enemies = Scene.get_enemies s in
  let monsters = Scene.get_monsters s in
  let c = Scene.get_camera s in
  let back_in_area = Scene.get_backgrounds_in_areas s (Camera.to_box c) in
  let tile_in_area = Scene.get_tiles_in_areas s (Camera.to_box c) in
  for i = 0 to ((Array.length back_in_area) - 1) do
    let rect = Sdl.intersect_rect (Camera.to_box c) (Background.to_box back_in_area.(i)) in
    match rect with
    |None -> ()
    |Some(x) -> display_background back_in_area.(i) (Scene.get_camera s) r
  done;
  for i = 0 to ((Array.length tile_in_area) - 1) do
    let rect = Sdl.intersect_rect (Camera.to_box c) (Object.to_box (Object.fixed_with_constructor tile_in_area.(i))) in
    match rect with
    |None -> ()
    |Some(x) -> display_fixed (Object.fixed_with_constructor tile_in_area.(i)) (Scene.get_camera s) r
  done;
  for i = 0 to ((Array.length monsters) - 1) do
    let rect = Sdl.intersect_rect (Camera.to_box c) (Object.to_box (Object.movable_with_constructor monsters.(i))) in
    match rect with
    |None -> ()
    |Some(x) -> display_movable (Object.movable_with_constructor monsters.(i)) (Scene.get_camera s) r
  done;
  for i = 0 to ((Array.length enemies) - 1) do
    let rect = Sdl.intersect_rect (Camera.to_box c) (Object.to_box (Object.movable_with_constructor enemies.(i))) in
    match rect with
    |None -> ()
    |Some(x) -> display_movable (Object.movable_with_constructor enemies.(i)) (Scene.get_camera s) r
  done;
  for i = 0 to ((Array.length characters) - 1) do
    let rect = Sdl.intersect_rect (Camera.to_box c) (Object.to_box (Object.movable_with_constructor characters.(i))) in
    match rect with
    |None -> ()
    |Some(x) -> display_movable (Object.movable_with_constructor characters.(i)) (Scene.get_camera s) r
  done;;

let last_key_pressed = ref Sdl.K.left;;

(* The display of the lifebar *)
let display_lifebar bar cam hero lw lh renderer =
  let cam' = Camera.move_camera cam (Object.get_positionX(Object.movable_with_constructor hero)) (Object.get_positionY(Object.movable_with_constructor hero)) lw lh (Object.get_width(Object.movable_with_constructor hero)) (Object.get_height(Object.movable_with_constructor hero)) in
  let new_bar = Lifebar.modify_life bar hero in
  let nnew_bar = Lifebar.modify_location new_bar cam' in
  let color = Lifebar.get_color bar in
  let (x,y) = Lifebar.get_xy nnew_bar in
  let max_h = Lifebar.get_max_height nnew_bar in
  let max_w = Lifebar.get_max_width nnew_bar in
  let cam_h = (Camera.get_h cam')/20 in
  let cam_w = (Camera.get_w cam')/20 in
  let border_size = cam_h/5 in
  (* the border rectangle *)
  let border = Sdl.Rect.create (x+cam_w-border_size) (y+cam_h-border_size) (max_w+2*border_size) (max_h+2*border_size) in
  let life_perc = (float_of_int (Lifebar.get_life nnew_bar)) /. (float_of_int (Lifebar.get_max nnew_bar)) in
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
  nnew_bar
;;

let event e c characters =
  let t = (Sdl.Event.get e Sdl.Event.typ) in
  if t = Sdl.Event.quit then quit := true
  else if t = Sdl.Event.key_down then
    begin
      let t' = (Sdl.Event.get e Sdl.Event.keyboard_keycode) in
      if t' = Sdl.K.right then
	begin
	  characters.(0) <- Object.right (characters.(0)) c;
	  last_key_pressed := Sdl.K.right;
	end
      else if t'= Sdl.K.left then
	begin
	  characters.(0) <- Object.left (characters.(0)) c;
	  last_key_pressed := Sdl.K.left;
	end
      else if t'= Sdl.K.up then
	begin
	  characters.(0) <- Object.jump (characters.(0)) c;
	end
    end
  else if t = Sdl.Event.key_up then
    begin
      let t' = (Sdl.Event.get e Sdl.Event.keyboard_keycode) in
      if t' = (!last_key_pressed) then characters.(0) <- Object.stop (characters.(0))
    end
;;

let play () s m =
  let (characters,enemies,monsters,decorations,tiles,traps,endlevels,backgrounds,width,height) = Level.parse s m in
  let scene = Scene.create characters enemies monsters decorations tiles traps endlevels backgrounds width height (!cam) in
  Scene.set_textures scene renderer;
  let events = Sdl.Event.create () in
  let timer = ref (Tsdl.Sdl.get_ticks ()) in (* timer used to calculate the time of a round *)
  let additional_timer = ref (Int32.of_int 0) in (* timer used to compensate the timeout of the previous round *)
  let timer_update_fps = ref (Tsdl.Sdl.get_ticks ()) in (* begin of timer to calculate next fps mean during time_update_fps *)
  let loop = ref 0 in (* count of turns before refreshing fps time *)
  let time_update_fps = 75 in (* time targeted before updating current fps *)
  let fps = ref (Settings.frames_per_second) in (* current fps *)
  let bar = ref (Lifebar.create ((Scene.get_characters scene).(0)) (!cam) 100) in
  while  not (!quit) do
    timer := Tsdl.Sdl.get_ticks ();
    Tools.render_clear renderer;
    while Sdl.poll_event (Some(events)) do
      event events (!additional_timer) (Scene.get_characters scene);
    done;
    Scene.update scene (!additional_timer);
    display_scene scene renderer; (* display all elements composing the scene that are in display area *)
    bar := display_lifebar (!bar) (!cam) ((Scene.get_characters scene).(0)) (Scene.get_width scene) (Scene.get_height scene) renderer; (* display lifebar of main character *)
    display_fps renderer (!fps) (!cam); (* display fps at top right corner *)
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
play () "levels/test.html" false;;

for i = 0 to 299 do
  Sdl.destroy_texture fps_tab.(i);
done;;
(*Sdl.free_surface font_img;;*)
(*Sdl.destroy_texture texture;; (* destroy texture *)*)
Sdl.destroy_renderer renderer;; (* destroy renderer *)
Sdl.destroy_window window;;
Tools.close ();;
