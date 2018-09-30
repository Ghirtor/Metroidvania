open Tsdl;;
open Tsdl_ttf;;

let menu_loop = ref true;;

let user_events = [Sdl.Event.quit; Sdl.Event.key_down];;
let quit = ref false;;
Tools.sdl_initialize ();;
let window = Tools.create_window "metroidvania" Settings.width Settings.height (Sdl.Window.windowed);;
let renderer = Tools.create_renderer window (Sdl.Renderer.(accelerated + presentvsync));; (* create renderer *)
Sdl.render_present renderer;; (* set this renderer as active *)
let color = Sdl.Color.create 255 255 255 255;;
let fps_tab = Array.init 300 (fun i -> Tools.create_texture_from_surface renderer (Tools.create_surface_from_font Tools.font ((string_of_int i)^" fps") color));; (* preload all fps fonts to avoid memory issues *)

let scanleft = Sdl.get_scancode_from_key Sdl.K.left;;
let scanright = Sdl.get_scancode_from_key Sdl.K.right;;
let scanup = Sdl.get_scancode_from_key Sdl.K.up;;
let scandown = Sdl.get_scancode_from_key Sdl.K.down;;
let scanspace = Sdl.get_scancode_from_key Sdl.K.space;;
let scanf = Sdl.get_scancode_from_key Sdl.K.f;;
let scanesc = Sdl.get_scancode_from_key Sdl.K.escape;;

let lose = 0;;
let win = 1;;
let leave = 2;;

Bullet.store_texture renderer;;

let settings = ref (Settings.create_saved_settings ());;

let display_movable t c r b =
  let j = Object.get_jump t in
  if b then begin
    let mj = Object.get_max_jump t in
    let selected_frame = if j <= 0.0 then (Object.select_frame_movable (Object.get_speedX t) (Object.get_speedY t) (Object.get_frame t) (Array.length (Object.get_sprite_left t)) (Array.length (Object.get_sprite_right t)) (Object.get_timer t)) mj else (Object.select_frame_movable_jump (Object.get_speedX t) (Object.get_speedY t) (Object.get_frame t) (Array.length (Object.sprite_jump_left)) (Array.length (Object.sprite_jump_right)) (Object.get_timer t)) in
    if selected_frame != (Object.get_frame t) then
      begin
	Object.set_frame t selected_frame;
	Object.set_timer t;
      end;
  end;
  let last_damages_time = Object.get_last_damages_time t in
  let current_time = Sdl.get_ticks () in
  let parity = ((Int32.to_int (Int32.sub current_time last_damages_time)) / Settings.character_shield_delay_frame) mod 2 in
  if (parity = 1 || ((Int32.to_int (Int32.sub current_time last_damages_time)) > Settings.character_shield_time)) then begin
    let sprite = Object.get_current_sprite t in
    let dec = if j > 0.0 then 20 else 0 in
    if (b || ((Scene.get_enemy_display ()) && (Object.get_positionX t) != -1.0)) then
      Object_texture.render (Object.get_texture t) (((int_of_float (Object.get_positionX t)) - 30) - (Camera.get_x c)) ((int_of_float (Object.get_positionY t)) - (Camera.get_y c) - dec) sprite r (Object.get_zoom t);
  end;;

let display_fixed t c r =
  if not (String.equal (Object.get_subtype t) "TILE") then begin
    let selected_frame = (Object.select_frame_fixed (Object.get_frame t) (Array.length (Object.get_sprite_active t)) (Array.length (Object.get_sprite_inactive t)) (Object.get_timer t) (Object.get_status t) (Object.get_subtype t)) in
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

let display_bullet t c r =
  let sprite = Bullet.get_current_sprite t in
  Object_texture.render (Bullet.get_texture ()) ((int_of_float (Bullet.get_x t)) - (Camera.get_x c)) ((int_of_float (Bullet.get_y t)) - (Camera.get_y c)) sprite r (Bullet.get_zoom t);;

let cam = ref (Camera.create_camera 0 0 Settings.height Settings.width);;

let display_fps r lt c =
  let (_,_,(w,h)) = Tools.query_texture (fps_tab.(lt)) in
  let src = Sdl.Rect.create 0 0 w h in
  let dst = Sdl.Rect.create ((Camera.get_w (!cam)) - w - 6) 6 w h in
  Tools.render_copy src dst r (fps_tab.(min lt 299)); ();;

let display_scene s r =
  let characters = Scene.get_characters s in
  let enemies = Scene.get_enemies s in
  let monsters = Scene.get_monsters s in
  let lasers = Scene.get_traps s in
  let c = Scene.get_camera s in
  let back_in_area = Scene.get_backgrounds_in_areas s (Camera.to_box c) in
  let tile_in_area = Scene.get_tiles_in_areas s (Camera.to_box c) in
  let friendly_bullets = Scene.get_friendly_bullets s in
  let enemy_bullets = Scene.get_enemy_bullets s in
  for i = 0 to ((Array.length lasers) - 1) do
    let t = (Object.fixed_with_constructor lasers.(i)) in
    let selected_frame = (Object.select_frame_fixed (Object.get_frame t) (Array.length (Object.get_sprite_active t)) (Array.length (Object.get_sprite_inactive t)) (Object.get_timer t) (Object.get_status t) (Object.get_subtype t)) in
    if selected_frame != (Object.get_frame t) then
      begin
	Object.set_frame t selected_frame;
	Object.set_timer t;
      end;
  done;
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
    |Some(x) -> display_movable (Object.movable_with_constructor monsters.(i)) (Scene.get_camera s) r true
  done;
  for i = 0 to ((Array.length enemies) - 1) do
    let rect = Sdl.intersect_rect (Camera.to_box c) (Object.to_box (Object.movable_with_constructor enemies.(i))) in
    match rect with
    |None -> ()
    |Some(x) -> display_movable (Object.movable_with_constructor enemies.(i)) (Scene.get_camera s) r false
  done;
  for i = 0 to ((Array.length characters) - 1) do
    let rect = Sdl.intersect_rect (Camera.to_box c) (Object.to_box (Object.movable_with_constructor characters.(i))) in
    match rect with
    |None -> ()
    |Some(x) -> display_movable (Object.movable_with_constructor characters.(i)) (Scene.get_camera s) r true
  done;
  for i = 0 to ((Array.length friendly_bullets) - 1) do
    if ((Bullet.get_x friendly_bullets.(i)) != (-1.0)) && (not (Bullet.get_collided friendly_bullets.(i))) then begin
      let rect = Sdl.intersect_rect (Camera.to_box c) (Bullet.to_box friendly_bullets.(i)) in
      match rect with
      |None -> ()
      |Some(x) -> display_bullet friendly_bullets.(i) (Scene.get_camera s) r
    end;
  done;
  for i = 0 to ((Array.length enemy_bullets) - 1) do
    if ((Bullet.get_x enemy_bullets.(i)) != (-1.0)) && (not (Bullet.get_collided enemy_bullets.(i))) then begin
      let rect = Sdl.intersect_rect (Camera.to_box c) (Bullet.to_box enemy_bullets.(i)) in
      match rect with
      |None -> ()
      |Some(x) -> display_bullet enemy_bullets.(i) (Scene.get_camera s) r
    end;
  done;;

let last_key_pressed = ref Sdl.K.left;;
let jump_key_released = ref true;;
let jump = ref false;;

(* The display of the lifebar *)
let display_lifebar bar cam hero lw lh renderer enemy =
  let new_bar = Lifebar.modify_life bar hero in
  let nnew_bar = Lifebar.modify_location new_bar cam in
  let color = Lifebar.get_color bar in
  let (x,y) = Lifebar.get_xy nnew_bar in
  let max_h = Lifebar.get_max_height nnew_bar in
  let max_w = Lifebar.get_max_width nnew_bar in
  let cam_h = (Camera.get_h cam)/20 in
  let cam_w = (Camera.get_w cam)/20 in
  let border_size = cam_h/5 in
  let distance = if enemy then (Settings.width-(max_w+border_size+cam_w)) else 0 in
  (* the border rectangle *)
  let border = Sdl.Rect.create (distance+x+cam_w-border_size) (y+cam_h-border_size) (max_w+2*border_size) (max_h+2*border_size) in
  let life_perc = (float_of_int (Lifebar.get_life nnew_bar)) /. (float_of_int (Lifebar.get_max nnew_bar)) in
  let new_size = int_of_float (life_perc *. float_of_int (max_w)) in
  (* the real rectangle with the life *)
  let new_rect = Sdl.Rect.create (distance+x+cam_w) (y+cam_h) new_size max_h in
  let border_of_border = Sdl.Rect.create (distance+x) (y+cam_h-border_size) (max_w+border_size+cam_w) (max_h+2*border_size) in
  let square_width = cam_w in
  let square_height = (max_h+2*border_size) in
  let square = Sdl.Rect.create (distance+x) (y+cam_h-border_size) square_width square_height in
  let cross_height = (3*(cam_w-border_size)/5) in
  let cross_width = ((max_h+2*border_size)/5) in
  let cross_a = Sdl.Rect.create (distance+x+square_width/2-cross_height/2) (y+cam_h-border_size+square_height/2-cross_width/2) cross_height cross_width in
  let cross_b = Sdl.Rect.create (distance+x+square_width/2-cross_width/2) (y+cam_h-border_size+square_height/2-cross_height/2) cross_width cross_height in
  let border_square = Sdl.Rect.create (distance+x) (y+cam_h-border_size) (cam_w-border_size) (max_h+2*border_size) in
  let () = Tools.set_render_draw_color renderer 0 0 0 255 in
  let () = Tools.render_fill_rect renderer border in
  let () = Tools.render_fill_rect renderer square in
  let () = Tools.set_render_draw_color renderer 255 255 255 255 in
  let () = Tools.render_draw_rect renderer border_of_border in
  let () = Tools.set_render_draw_color renderer (Sdl.Color.r color) (Sdl.Color.g color) (Sdl.Color.b color) 255 in
  let () = Tools.render_fill_rect renderer cross_a in
  let () = Tools.render_fill_rect renderer cross_b in
  let () = Tools.render_fill_rect renderer new_rect in
  let () = Tools.set_render_draw_color renderer 0 0 0 255 in
  nnew_bar
;;

let display_pause s r cam bar =
  let render_copy = r in
  let timer = Sdl.get_ticks() in
  let continue = ref true in
  let res = ref 0 in
  let background = Sdl.Rect.create 0 0 Settings.width Settings.height in
  let () = Tools.set_render_draw_blend_mode r Sdl.Blend.mode_blend in
  let arr = Pause.arr_texture r in
  let p = ref (Pause.create arr) in
  while (!continue) do
    Tools.render_clear r;
    let r_c = render_copy in
    let events = Sdl.Event.create () in
    while Sdl.poll_event (Some(events)) do
      Pause.event events (!p) r Settings.width Settings.height res continue quit menu_loop
    done;
    let x = Sdl.Event.get events (Sdl.Event.mouse_button_x) in
    let y = Sdl.Event.get events (Sdl.Event.mouse_button_y) in
    p := Pause.on_or_off (!p) r Settings.width Settings.height x y arr;
    let () = display_scene s r_c in
    let tmp = display_lifebar bar cam ((Scene.get_characters s).(0)) (Scene.get_width s) (Scene.get_height s) r_c in
    let () = Tools.set_render_draw_color r_c 0 0 0 128 in
    let () = Tools.render_fill_rect r_c background in
    let () = Pause.display_pause (!p) r_c in
    let () = Sdl.render_present r_c in
    Sdl.delay (Int32.of_int(1000/Settings.frames_per_second))
  done;
  let () = Tools.set_render_draw_blend_mode r Sdl.Blend.mode_none in
  let () = Tools.free_arr arr in
  let end_timer = Sdl.get_ticks() in
  let sub = Int32.sub end_timer timer in
  if (!res) = 1 then (Pause.resume,sub)
  else (Pause.menu,sub)
;;

let display_settings r =
  let continue = ref true in
  let background = Sdl.Rect.create 0 0 Settings.width Settings.height in
  let arr = Settings.create_arr r (!settings) in
  let s = ref (Settings.create arr (!settings) r) in
  while (!continue) do
    Tools.render_clear r;
    let events = Sdl.Event.create () in
    while Sdl.poll_event (Some(events)) do
      s := Settings.event events (!s) r continue menu_loop arr settings
    done;
    let x = Sdl.Event.get events (Sdl.Event.mouse_button_x) in
    let y = Sdl.Event.get events (Sdl.Event.mouse_button_y) in
    s := Settings.on_or_off (!s) r x y arr;
    let () = Tools.set_render_draw_color r 0 0 0 255 in
    let () = Tools.render_fill_rect r background in
    let () = Settings.display_settings (!s) r in
    let () = Sdl.render_present r in
    Sdl.delay (Int32.of_int(1000/Settings.frames_per_second))
  done;
  Settings.destroy (!s) arr
;;

let event e =
  match Sdl.Event.(enum @@ get e typ) with
  | `Quit ->
     quit := true;
    menu_loop := false;
  | _ -> ();;

let check_pause s cam bar =
  let bigarr = Sdl.get_keyboard_state () in
  let sub_t = ref (Int32.of_int 0) in
  if bigarr.{scanesc} = 1 then
    begin
      let (pause_choice,sub_timer) = display_pause s renderer cam bar in
      if pause_choice = Pause.menu then quit := true;
      sub_t := sub_timer;
    end;
  (!sub_t);;

let actions characters s m =
  let bigarr = Sdl.get_keyboard_state () in
  (* all the useless key states *)
  if bigarr.{Sdl.get_scancode_from_key (!last_key_pressed)} = 0 then characters.(0) <- Object.stop (characters.(0));
  if bigarr.{scanup} = 0 then begin
    jump := false;
    jump_key_released := true;
    characters.(0) <- Object.disable_jump characters.(0);
  end;
  if ((bigarr.{scanleft} = 1 && bigarr.{scanright} = 1) || (bigarr.{scanup} = 1 && bigarr.{scandown} = 1)) then begin
    characters.(0) <- Object.stop (characters.(0));
    jump := false;
    characters.(0) <- Object.disable_jump characters.(0);
  end
  else begin
    if bigarr.{scanleft} = 1 then
      begin
        characters.(0) <- Object.left (characters.(0));
        last_key_pressed := Sdl.K.left;
      end;
    if bigarr.{scanright} = 1 then
      begin
        characters.(0) <- Object.right (characters.(0));
        last_key_pressed := Sdl.K.right;
      end;
    if bigarr.{scanup} = 1 then
      begin
	if (!jump_key_released) && not (!jump) && (Object.get_max_jump (Object.movable_with_constructor characters.(0))) > 0.0 then begin
	  (*characters.(0) <- Object.jump (characters.(0)) c;*)
	  jump := true;
	  jump_key_released := false;
	end;
      end;
    if bigarr.{scanf} = 1 then begin
      let last_fire_time = Object.get_last_fire_time (Object.movable_with_constructor characters.(0)) in
      let diff = Int32.to_int (Int32.sub (Sdl.get_ticks ()) last_fire_time) in
      if diff > Settings.fire_delay then begin
	Object.set_last_fire_time characters.(0);
	let x = Object.get_positionX (Object.movable_with_constructor characters.(0)) in
	let y = Object.get_positionY (Object.movable_with_constructor characters.(0)) in
	let dir = Object.get_direction (Object.movable_with_constructor characters.(0)) in
	Scene.add_friendly_bullet s (Bullet.create (if dir < 0 then x -. 20.0 else x +. 55.0) (y +. 40.0) dir) m true;
      end
    end;
  end;;

let rec play s m =
  if m then begin
    let continue = ref true in
    let arr = Waiting.create_arr renderer in
    let w = ref (Waiting.create renderer arr) in
    let nb = ref 0 in
    Network.connect ();
    Network.set_player_level (Tools.get_arena_rank (String.sub s (String.length Settings.arenas_dir) ((String.length s) - (String.length Settings.arenas_dir))));
    Network.set_player_life 100;
    Network.set_player_datas (-1) (-1) (-1) 0 0;
    Network.send ();
    while ((Network.get_status ()) = 0 && (!continue)) do
      let () = Tools.render_clear renderer in
      let events = Sdl.Event.create () in
      while Sdl.poll_event (Some(events)) do
	w := Waiting.event events continue menu_loop (!w) arr renderer;
	event events;
      done;
      let x = Sdl.Event.get events (Sdl.Event.mouse_button_x) in
      let y = Sdl.Event.get events (Sdl.Event.mouse_button_y) in
      w := Waiting.on_or_off (!w) renderer x y arr;
      let () = Waiting.display renderer (!w) (!nb) in
      Sdl.render_present renderer;
      nb := (!nb)+1;
      if ((!nb) = 120) then nb := 0;
      Sdl.delay (Int32.of_int (1000 / Settings.frames_per_second));
    done;
    if not (!continue) then quit := true;
    Waiting.destroy (!w) arr;
  end;
  (* loading *)
  let l = Loading.create renderer in
  let nb = ref 0 in
  Tools.render_clear renderer;
  Loading.display renderer l (!nb);
  Sdl.render_present renderer;
  let disp_fps = Settings.get_display_fps (!settings) in
  let fps_target = (Settings.get_nb_fps (!settings)) in
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
  (*let bar = ref (Lifebar.create ((Scene.get_characters scene).(0)) (!cam) 100) in*)
  let red = Sdl.Color.create 255 0 0 255 in
  let yellow = Sdl.Color.create 255 255 0 255 in
  let bar = ref (Lifebar.create ((Scene.get_characters scene).(0)) (!cam) red) in
  let enemy_bar = if m then ref (Lifebar.create ((Scene.get_enemies scene).(0)) (!cam) yellow) else bar in
  nb := 0;
  let timer_loading = Tsdl.Sdl.get_ticks () in
  let target = Random.int 3000 in
  let result = ref leave in
  let continue = ref true in
  while(!continue) do
    Tools.render_clear renderer;
    Loading.display renderer l (!nb);
    let events = Sdl.Event.create () in
    while Sdl.poll_event (Some(events)) do
      Loading.event events continue;
      event events;
    done;
    Sdl.render_present renderer;
    nb := (!nb)+(3*(1000/Settings.frames_per_second)/16);
    if (!nb) > 120 then nb := 0;
    if (Int32.sub (Tsdl.Sdl.get_ticks ()) timer_loading) > (Int32.of_int (2000 + target)) then continue := false;
    Sdl.delay (Int32.of_int(1000/Settings.frames_per_second))
  done;
  Loading.destroy_load l;
  (*let sub_timer = ref (Int32.of_int 0) in*)
  (* waiting enemy if we are in multipklayer mode *)
  if m then begin
    Network.set_player_level (Tools.get_arena_rank (String.sub s (String.length Settings.arenas_dir) ((String.length s) - (String.length Settings.arenas_dir))));
    Network.set_player_life (Object.get_life characters.(0));
    Network.set_player_datas (int_of_float (Object.get_positionX (Object.movable_with_constructor characters.(0)))) (int_of_float (Object.get_positionY (Object.movable_with_constructor characters.(0)))) (-1) (0)  (Object.get_direction (Object.movable_with_constructor characters.(0)));
    Network.set_player_fire 0;
  end;
  (* let's play ! *)
  (*quit := false;*)
  let game_time = Tsdl.Sdl.get_ticks () in
  let pause_time = ref (Int32.of_int 0) in
  Object.start_timer_lasers ();
  while  not (!quit) do
    timer := Tsdl.Sdl.get_ticks ();
    Tools.render_clear renderer;
    actions (Scene.get_characters scene) scene m;
    while Sdl.poll_event (Some(events)) do
      event events;
    done;
    additional_timer := Int32.add (!additional_timer) (Int32.of_int (1000 / fps_target));
    while (Int32.to_int (!additional_timer)) >= (1000 / Settings.updates_per_second) do
      if (Object.get_max_jump (Object.movable_with_constructor ((Scene.get_characters scene).(0)))) <= 0.0 then jump := false;
      if (!jump) then (Scene.get_characters scene).(0) <- Object.jump ((Scene.get_characters scene).(0));
      let update = Scene.update scene m s in
      if update = Scene.win then begin
	result := win;
	quit := true;
      end;
      additional_timer := Int32.sub (!additional_timer) (Int32.of_int (1000 / Settings.updates_per_second));
    done;
    display_scene scene renderer; (* display all elements composing the scene that are in display area *)
    (*bar := display_lifebar (!bar) (!cam) ((Scene.get_characters scene).(0)) (Scene.get_width scene) (Scene.get_height scene) renderer; (* display lifebar of main character *)*)
    bar := display_lifebar (!bar) (!cam) ((Scene.get_characters scene).(0)) (Scene.get_width scene) (Scene.get_height scene) renderer false; (* display lifebar of main character *)
    if m then enemy_bar := display_lifebar (!enemy_bar) (!cam) ((Scene.get_enemies scene).(0)) (Scene.get_width scene) (Scene.get_height scene) renderer true; (* display lifebar of main character *)
    if disp_fps then display_fps renderer (!fps) (!cam); (* display fps at top right corner *)
    Sdl.render_present renderer;
    let diff_timer_fps = Int32.to_int (Int32.sub (Tsdl.Sdl.get_ticks ()) (!timer_update_fps)) in
    if (diff_timer_fps >= time_update_fps) then begin
      fps := int_of_float ((float_of_int 1000) /. ((float_of_int diff_timer_fps) /. (float_of_int ((!loop) + 1))));
      loop := 0;
      timer_update_fps := Tsdl.Sdl.get_ticks ();
    end
    else loop := !loop + 1;
    let diff = (Int32.sub (Int32.of_int (1000 / fps_target)) ((Int32.sub (Tsdl.Sdl.get_ticks ()) (!timer)))) in
    additional_timer :=  (if (Int32.to_int diff) < 0 then (Int32.add (Int32.abs diff) (!additional_timer)) else !additional_timer);
    Sdl.delay (Int32.of_int (max 0 (Int32.to_int (Int32.sub (Int32.of_int (1000 / fps_target)) (Int32.sub (Tsdl.Sdl.get_ticks ()) (!timer))))));
    let bigarr = Sdl.get_keyboard_state () in
    if not (Object.is_dead ((Scene.get_characters scene).(0))) && not (!quit) then let sub_t = check_pause scene (!cam) (!bar) in pause_time := Int32.add sub_t (!pause_time) else if not (!quit) then begin quit := true; result := lose; end;
    if m && (Object.is_dead ((Scene.get_enemies scene).(0))) && not (!quit) then begin quit := true; result := win; end;
    if m && (Network.get_connection ()) = 0 then begin quit := true; result := win; end;
  done;
  if m then Network.disconnect ();
  let end_game_time = Tsdl.Sdl.get_ticks () in
  let total_game_time = Int32.to_int (Int32.sub (Int32.sub (Int32.sub end_game_time game_time) (!pause_time)) (Int32.of_int Settings.end_animation_time)) in
  let minutes = total_game_time / 60000 in
  let seconds = (total_game_time - minutes) / 1000 in
  let chrono = (string_of_int minutes)^":"^(string_of_int seconds) in
  Scene.free scene;
  if (!result) = lose then begin
    let r = Game_over.display renderer m in
    if r = Game_over.retry then begin
      quit := false;
      play s m;
    end
    else if r = Game_over.close then menu_loop := false;
  end
  else if (!result) = win then begin
    let name = String.sub s (String.length Settings.levels_dir) ((String.length s) - (String.length Settings.levels_dir)) in
    if not m then begin
      let highscore = Highscore.get_highscore name > total_game_time in
      Highscore.set_highscore name total_game_time;
      let (res, next) = Success.display renderer chrono highscore menu_loop name m in
      if res then begin
	quit := false;
	play ((Settings.levels_dir)^next) m;
      end
    end
    else begin
      let (res, next) = Success.display renderer chrono false menu_loop name m in ()
    end;
  end;;

let level_choice r m =
  quit := false;
  let arr_menu = Level_selection.create_arr_menu r in
  let c = ref (Level_selection.create r arr_menu m) in
  let level_loop = ref true in
  let background = Sdl.Rect.create 0 0 Settings.width Settings.height in
  let choice_nb = ref (-1) in
  let choice = ref false in
  while (!level_loop) do
    let () = Tools.render_clear r in
    let events = Sdl.Event.create () in
    while Sdl.poll_event (Some(events)) do
      c := Level_selection.event events level_loop menu_loop arr_menu (!c) r choice choice_nb
    done;
    let x = Sdl.Event.get events (Sdl.Event.mouse_button_x) in
    let y = Sdl.Event.get events (Sdl.Event.mouse_button_y) in
    c := Level_selection.on_or_off (!c) r x y arr_menu;
    let () = Tools.set_render_draw_color r 0 0 0 255 in
    let () = Tools.render_fill_rect r background in
    let () = Level_selection.display_selection (!c) r in
    Sdl.render_present r;
    Sdl.delay (Int32.of_int(1000/Settings.frames_per_second));
  done;
  let () = Level_selection.destroy_selection (!c) arr_menu in
  if (!choice) then
    begin
      let lv = Level_selection.get_name (!c) (!choice_nb) in
      play ((if m = Settings.solo then Settings.levels_dir else Settings.arenas_dir)^lv^".html") (if m = Settings.solo then false else true)
    end
;;

let start () =
  while (!menu_loop) do
    let res_menu = Menu.display renderer Settings.width Settings.height in
    if res_menu = Menu.quit then menu_loop := false
    else if res_menu = Menu.settings then display_settings renderer
    else if res_menu = Menu.solo then level_choice renderer Settings.solo(*play "levels/test.html" false*)
    else if res_menu = Menu.multi then (*display_wait_multi renderer*) level_choice renderer Settings.multi(*play "levels/test.html" true*)
    else menu_loop := false
  done;
;;

start ();;

for i = 0 to 299 do
  Sdl.destroy_texture fps_tab.(i);
done;;
(*Sdl.free_surface font_img;;*)
(*Sdl.destroy_texture texture;; (* destroy texture *)*)
Bullet.free ();;
Sdl.destroy_renderer renderer;; (* destroy renderer *)
Sdl.destroy_window window;;
Tools.close ();;
