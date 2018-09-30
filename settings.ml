(* game settings  *)
open Tsdl;;
open Tsdl_ttf;;

let width = 1280;;
let height = 720;;

let solo = 0;;
let multi = 1;;

let updates_per_second = 160;;
let frames_per_second = 60;;
let player_speed = 400;;
let player_gravity = 600;;
let player_jump = 1500;;
let max_jump_player = 400.0;;
let movable_delay_frame = 50;;
let laser_delay_frame = 90;;
let decoration_delay_frame = 40;;
let endlevel_delay_frame = 90;;
let character_shield_delay_frame = 60;;
let character_shield_time = 3000;;
let end_animation_time = 2000;;

let laser_damages = 25;;
let laser_state_delay = 3000;;

let fire_delay = 250;;
let fire_damages = 10;;

(* pictures *)

let pictures_dir = "pictures/";;
let levels_dir = "levels/";;
let arenas_dir = "arenas/";;

let player_sprite_sheet_dir = pictures_dir^"character.png";;
let laser_active_sprite_dir = pictures_dir^"laser.png";;
let laser_inactive_sprite_dir = pictures_dir^"laser_inactive.png";;
let decoration_active_sprite_dir = pictures_dir^"decoration.png";;
let endlevel_active_sprite_dir = pictures_dir^"endlevel.png";;
let endlevel_inactive_sprite_dir = pictures_dir^"endlevel_inactive.png";;

type settings = {
    display_fps : Sdl.texture;
    nb_fps : Sdl.texture;
    name : Sdl.texture;
    save_settings : Sdl.texture;
    yes : Sdl.texture;
    no : Sdl.texture;
    fps30 : Sdl.texture;
    fps40 : Sdl.texture;
    fps50 : Sdl.texture;
    fps60 : Sdl.texture;
    menu : Sdl.texture;
    display_fps_choice : bool;
    nb_fps_choice : int;
    background : Sdl.texture
  };;

type saved_settings = {
    display_fps_saved : bool;
    nb_fps_saved : int
  };;

(*
Table saves
Champs display_fps bool, nb_fps int, name varchar2
 *)
let create_saved_settings () =
  
  {display_fps_saved = false; nb_fps_saved = 60}
;;

let create_font () =
  let t = Ttf.init () in
  match Ttf.open_font "ttf/arial.ttf" 45 with
    |Error (`Msg e) -> Sdl.log "open font error in pause: %s" e; exit 1
    |Ok (f) -> f;;

let font = create_font();;

let get_display_fps s =
  s.display_fps_saved
;;

let get_nb_fps s =
  s.nb_fps_saved
;;

let create_text r color text =
  let tmp = Tools.create_surface_from_font font text color in
  let texture = Tools.create_texture_from_surface r tmp in
  let () = Sdl.free_surface tmp in
  texture
;;

let create_arr r saved =
  Array.init 19 (fun i ->
      let white = Sdl.Color.create 255 255 255 255 in
      let selected = Sdl.Color.create 255 128 128 255 in
      let green = Sdl.Color.create 0 255 0 255 in
      let black = Sdl.Color.create 0 0 0 255 in
      let color_yes = if saved.display_fps_saved then green else white in
      let color_no = if saved.display_fps_saved then white else green in
      let color_30 = if saved.nb_fps_saved = 30 then green else white in
      let color_40 = if saved.nb_fps_saved = 40 then green else white in
      let color_50 = if saved.nb_fps_saved = 50 then green else white in
      let color_60 = if saved.nb_fps_saved = 60 then green else white in
      match i with
      | 0 -> create_text r white "Display FPS:"
      | 1 -> create_text r white "FPS:"
      | 2 -> create_text r white "Name:"
      | 3 -> create_text r white "Save settings"
      | 4 -> create_text r color_yes "Yes"
      | 5 -> create_text r color_no "No"
      | 6 -> create_text r color_30 "30"
      | 7 -> create_text r color_40 "40"
      | 8 -> create_text r color_50 "50"
      | 9 -> create_text r color_60 "60"
      | 10 -> create_text r white "Menu"
      | 11 -> create_text r selected "Save settings"
      | 12 -> create_text r selected "Yes"
      | 13 -> create_text r selected "No"
      | 14 -> create_text r selected "30"
      | 15 -> create_text r selected "40"
      | 16 -> create_text r selected "50"
      | 17 -> create_text r selected "60"
      | 18 -> create_text r selected "Menu"
    )
;;


let create arr saved r =
  let background = Tools.create_background "pictures/background_settings.png" r in
  {display_fps = arr.(0); nb_fps = arr.(1); name = arr.(2); save_settings = arr.(3);
   yes = arr.(4); no = arr.(5); fps30 = arr.(6); fps40 = arr.(7); fps50 = arr.(8);
   fps60 = arr.(9); menu = arr.(10); display_fps_choice = saved.display_fps_saved; nb_fps_choice = saved.nb_fps_saved; background
  }
;;

let is_on t r wt ht x y =
  let (_,_,(w,h)) = Tools.query_texture t in
  (((wt-w/2) < x) && ((wt+w/2) > x) && ((ht-h/2) < y) && ((ht+h/2) > y))
;;

let is_on_left t r wt ht x y =
  let (_,_,(w,h)) = Tools.query_texture t in
  (((wt) < x) && ((wt+w) > x) && ((ht-h/2) < y) && ((ht+h/2) > y))
;;

let event e s r continue menu_loop arr saved =
  let white = Sdl.Color.create 255 255 255 255 in
  let green = Sdl.Color.create 0 255 0 255 in
  let selected = Sdl.Color.create 255 0 0 255 in
  let red = Sdl.Color.create 255 128 128 255 in
  let x = Sdl.Event.get e (Sdl.Event.mouse_button_x) in
  let y = Sdl.Event.get e (Sdl.Event.mouse_button_y) in
  match Sdl.Event.(enum @@ get e typ) with
  | `Quit -> continue := false;
             menu_loop := false;
             s
  | `Mouse_button_down ->
     if(is_on s.no r (7*width/8) (height/7) x y) then
       if(s.display_fps_choice) then
         begin
           Sdl.destroy_texture arr.(4);
           Sdl.destroy_texture arr.(5);
           Sdl.destroy_texture arr.(13);
           arr.(4) <- create_text r white "Yes";
           arr.(5) <- create_text r green "No";
           arr.(13) <- create_text r selected "No";
           {s with yes = arr.(4); no = arr.(5); display_fps_choice = false}         
         end
       else
         begin
           Sdl.destroy_texture arr.(13);
           arr.(13) <- create_text r selected "No";
           {s with no = arr.(13)}
         end
     else if(is_on s.yes r (6*width/8) (height/7) x y) then
       if(not s.display_fps_choice) then
         begin
           Sdl.destroy_texture arr.(4);
           Sdl.destroy_texture arr.(5);
           Sdl.destroy_texture arr.(12);
           arr.(4) <- create_text r green "Yes";
           arr.(5) <- create_text r white "No";
           arr.(12) <- create_text r selected "Yes";
           {s with yes = arr.(4); no = arr.(5); display_fps_choice = true}
         end
       else
         begin
           Sdl.destroy_texture arr.(12);
           arr.(12) <- create_text r selected "Yes";
           {s with yes = arr.(12)}
         end
     else if(is_on s.fps60 r (7*width/8) (2*height/7) x y) then
       if(not (s.nb_fps_choice = 60)) then
         begin
           Sdl.destroy_texture arr.(6);
           Sdl.destroy_texture arr.(7);
           Sdl.destroy_texture arr.(8);
           Sdl.destroy_texture arr.(9);
           Sdl.destroy_texture arr.(17);
           arr.(6) <- create_text r white "30";
           arr.(7) <- create_text r white "40";
           arr.(8) <- create_text r white "50";
           arr.(9) <- create_text r green "60";
           arr.(17) <- create_text r selected "60";
           {s with fps30 = arr.(6); fps40 = arr.(7); fps50 = arr.(8); fps60 = arr.(9); nb_fps_choice = 60}
         end
       else
         begin
           Sdl.destroy_texture arr.(17);
           arr.(17) <- create_text r selected "60";
           {s with fps60 = arr.(17)}
         end
     else if(is_on s.fps50 r (6*width/8) (2*height/7) x y) then
       if(not (s.nb_fps_choice = 50)) then
         begin
           Sdl.destroy_texture arr.(6);
           Sdl.destroy_texture arr.(7);
           Sdl.destroy_texture arr.(8);
           Sdl.destroy_texture arr.(9);
           Sdl.destroy_texture arr.(16);
           arr.(6) <- create_text r white "30";
           arr.(7) <- create_text r white "40";
           arr.(8) <- create_text r green "50";
           arr.(9) <- create_text r white "60";
           arr.(16) <- create_text r selected "50";
           {s with fps30 = arr.(6); fps40 = arr.(7); fps50 = arr.(8); fps60 = arr.(9); nb_fps_choice = 50}
         end
       else
         begin
           Sdl.destroy_texture arr.(16);
           arr.(16) <- create_text r selected "50";
           {s with fps50 = arr.(16)}
         end
     else if(is_on s.fps40 r (5*width/8) (2*height/7) x y) then
       if(not (s.nb_fps_choice = 40)) then
         begin
           Sdl.destroy_texture arr.(6);
           Sdl.destroy_texture arr.(7);
           Sdl.destroy_texture arr.(8);
           Sdl.destroy_texture arr.(9);
           Sdl.destroy_texture arr.(15);
           arr.(6) <- create_text r white "30";
           arr.(7) <- create_text r green "40";
           arr.(8) <- create_text r white "50";
           arr.(9) <- create_text r white "60";
           arr.(15) <- create_text r selected "40";
           {s with fps30 = arr.(6); fps40 = arr.(7); fps50 = arr.(8); fps60 = arr.(9); nb_fps_choice = 40}
         end
       else
         begin
           Sdl.destroy_texture arr.(15);
           arr.(15) <- create_text r selected "40";
           {s with fps40 = arr.(15)}
         end
     else if(is_on s.fps30 r (4*width/8) (2*height/7) x y) then
       if(not (s.nb_fps_choice = 30)) then
         begin
           Sdl.destroy_texture arr.(6);
           Sdl.destroy_texture arr.(7);
           Sdl.destroy_texture arr.(8);
           Sdl.destroy_texture arr.(9);
           Sdl.destroy_texture arr.(14);
           arr.(6) <- create_text r green "30";
           arr.(7) <- create_text r white "40";
           arr.(8) <- create_text r white "50";
           arr.(9) <- create_text r white "60";
           arr.(14) <- create_text r selected "30";
           {s with fps30 = arr.(6); fps40 = arr.(7); fps50 = arr.(8); fps60 = arr.(9); nb_fps_choice = 30}
         end
       else
         begin
           Sdl.destroy_texture arr.(14);
           arr.(14) <- create_text r selected "30";
           {s with fps30 = arr.(14)}
         end
     else if(is_on_left s.save_settings r (width/100) (5*height/7) x y) then
       begin
         Sdl.destroy_texture arr.(11);
         arr.(11) <- create_text r selected "Save settings";
         saved := {display_fps_saved = s.display_fps_choice;
                   nb_fps_saved = s.nb_fps_choice};
         {s with save_settings = arr.(11)}
       end
     else if(is_on_left s.menu r (width/100) (6*height/7) x y) then
       begin
         Sdl.destroy_texture arr.(18);
         arr.(18) <- create_text r selected "Menu";
         {s with menu = arr.(18)}
       end
     else
       s
  | `Mouse_button_up ->
     if(is_on s.no r (7*width/8) (height/7) x y) then
       begin
         Sdl.destroy_texture arr.(13);
         arr.(13) <- create_text r red "No";
         {s with no = arr.(13)}         
       end
     else if(is_on s.yes r (6*width/8) (height/7) x y) then
       begin
         Sdl.destroy_texture arr.(12);
         arr.(12) <- create_text r red "Yes";
         {s with yes = arr.(12)}
       end
     else if(is_on s.fps60 r (7*width/8) (2*height/7) x y) then
       begin
         Sdl.destroy_texture arr.(17);
         arr.(17) <- create_text r red "60";
         {s with fps60 = arr.(17)}
       end
     else if(is_on s.fps50 r (6*width/8) (2*height/7) x y) then
       begin
         Sdl.destroy_texture arr.(16);
         arr.(16) <- create_text r red "50";
         {s with fps50 = arr.(16)}
       end
     else if(is_on s.fps40 r (5*width/8) (2*height/7) x y) then
       begin
         Sdl.destroy_texture arr.(15);
         arr.(15) <- create_text r red "40";
         {s with fps40 = arr.(15)}
       end
     else if(is_on s.fps30 r (4*width/8) (2*height/7) x y) then
       begin
         Sdl.destroy_texture arr.(14);
         arr.(14) <- create_text r red "30";
         {s with fps30 = arr.(14)}
       end
     else if(is_on_left s.save_settings r (width/100) (5*height/7) x y) then
       begin
         Sdl.destroy_texture arr.(11);
         arr.(11) <- create_text r red "Save settings";
         {s with save_settings = arr.(11)}
       end
     else if(is_on_left s.menu r (width/100) (6*height/7) x y) then
       begin
         Sdl.destroy_texture arr.(18);
         arr.(18) <- create_text r red "Menu";
         continue := false;
         {s with menu = arr.(18)}
       end
     else s
  | _ -> s
;;

let display_element_left t r wt ht =
  let (_,_,(w,h)) = Tools.query_texture t in
  let src = Sdl.Rect.create 0 0 w h in
  let dst = Sdl.Rect.create wt (ht-h/2) w h in
  Tools.render_copy src dst r t;
  ()
;;

let display_element t r wt ht =
  let (_,_,(w,h)) = Tools.query_texture t in
  let src = Sdl.Rect.create 0 0 w h in
  let dst = Sdl.Rect.create (wt-w/2) (ht-h/2) w h in
  Tools.render_copy src dst r t;
  ()
;;

let on_or_off s r x y arr =
  if(x = 0 && y = 0) then s
  else if(is_on s.no r (7*width/8) (height/7) x y) then
    {s with no = arr.(13)}
  else if(is_on s.yes r (6*width/8) (height/7) x y) then
    {s with yes = arr.(12)}
  else if(is_on s.fps60 r (7*width/8) (2*height/7) x y) then
    {s with fps60 = arr.(17)}
  else if(is_on s.fps50 r (6*width/8) (2*height/7) x y) then
    {s with fps50 = arr.(16)}
  else if(is_on s.fps40 r (5*width/8) (2*height/7) x y) then
    {s with fps40 = arr.(15)}
  else if(is_on s.fps30 r (4*width/8) (2*height/7) x y) then
    {s with fps30 = arr.(14)}
  else if(is_on_left s.save_settings r (width/100) (5*height/7) x y) then
    {s with save_settings = arr.(11)}
  else if(is_on_left s.menu r (width/100) (6*height/7) x y) then
    {s with menu = arr.(18)}
  else
    {s with yes = arr.(4); no = arr.(5); fps30 = arr.(6); fps40 = arr.(7); fps50 = arr.(8);
    fps60 = arr.(9); save_settings = arr.(3); menu = arr.(10)}
;;

let destroy s arr =
  let () = Tools.free_arr arr in
  Sdl.destroy_texture s.background
;;

let display_settings s r =
  let screen = Sdl.Rect.create 0 0 width height in
  let () = Tools.render_copy screen screen r s.background in
  let () = display_element_left s.display_fps r (width/100) (height/7) in
  let () = display_element_left s.nb_fps r (width/100) (2*height/7) in
  let () = display_element_left s.save_settings r (width/100) (5*height/7) in
  let () = display_element_left s.menu r (width/100) (6*height/7) in
  let () = display_element s.no r (7*width/8) (height/7) in
  let () = display_element s.yes r (6*width/8) (height/7) in
  let () = display_element s.fps60 r (7*width/8) (2*height/7) in
  let () = display_element s.fps50 r (6*width/8) (2*height/7) in
  let () = display_element s.fps40 r (5*width/8) (2*height/7) in
  display_element s.fps30 r (4*width/8) (2*height/7)
;;

