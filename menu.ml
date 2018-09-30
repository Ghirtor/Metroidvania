open Tsdl;;
open Tsdl_ttf;;

let solo = 1;;
let multi = 2;;
let settings = 3;;
let quit = 4;;

let create_font () =
  let t = Ttf.init () in
  match Ttf.open_font "ttf/arial.ttf" 45 with
    |Error (`Msg e) -> Sdl.log "open font error in menu: %s" e; exit 1
    |Ok (f) -> f;;

let font = create_font ();;

let arr_texture r =
  Array.init 8
    (fun i -> let standard_color = Sdl.Color.create 255 255 255 255 in
              let select_color = Sdl.Color.create 255 128 128 255 in
              match i with
                0 -> Tools.create_texture_from_font r "Play" standard_color font
              | 1 -> Tools.create_texture_from_font r "Play" select_color font
              | 2 -> Tools.create_texture_from_font r "Play Online" standard_color font
              | 3 -> Tools.create_texture_from_font r "Play Online" select_color font
              | 4 -> Tools.create_texture_from_font r "Settings" standard_color font
              | 5 -> Tools.create_texture_from_font r "Settings" select_color font
              | 6 -> Tools.create_texture_from_font r "Quit" standard_color font
              | 7 -> Tools.create_texture_from_font r "Quit" select_color font
    )
;;


(*let () = Tools.sdl_initialize ();;

let window = Tools.create_window "metroidvania" 640 480 (Sdl.Window.windowed);;
let renderer = Tools.create_renderer window (Sdl.Renderer.(accelerated + presentvsync));; (* create renderer *)
Sdl.render_present renderer;;*)

type menu = {
    play : Sdl.texture;
    multi : Sdl.texture;
    settings : Sdl.texture;
    quit : Sdl.texture;
    background : Sdl.texture
  };;

let create arr r =
  let play = arr.(0) in
  let multi = arr.(2) in
  let settings = arr.(4) in
  let quit = arr.(6) in
  let background = Tools.create_background "pictures/background_menu.png" r in
  {play; multi; settings; quit; background}
;;

let get_play m =
  m.play
;;

let get_multi m =
  m.multi
;;

let get_settings m =
  m.settings
;;

let get_quit m =
  m.quit
;;

let display_element t r wt ht =
  let (_,_,(w,h)) = Tools.query_texture t in
  let src = Sdl.Rect.create 0 0 w h in
  let dst = Sdl.Rect.create (wt-w/2) (ht-h/2) w h in
  Tools.render_copy src dst r t;
  ()
;;

let is_on t r wt ht x y =
  let (_,_,(w,h)) = Tools.query_texture t in
  (((wt-w/2) < x) && ((wt+w/2) > x) && ((ht-h/2) < y) && ((ht+h/2) > y))
;;

let on_or_off m r wm hm x y arr =
  if (x = 0 && y = 0) then m
  else if(is_on (get_play m) r (wm/4) (hm/5) x y) then
    begin
      let play = arr.(1) in
      let multi = arr.(2) in
      let settings = arr.(4) in
      let quit = arr.(6) in
      {m with play; multi; settings; quit}
    end
  else if (is_on (get_multi m) r (wm/4) (2*hm/5) x y) then
    begin
      let play = arr.(0) in
      let multi = arr.(3) in
      let settings = arr.(4) in
      let quit = arr.(6) in
      {m with play; multi; settings; quit}
    end
  else if (is_on (get_settings m) r (wm/4) (3*hm/5) x y) then
    begin
      let play = arr.(0) in
      let multi = arr.(2) in
      let settings = arr.(5) in
      let quit = arr.(6) in
      {m with play; multi; settings; quit}
    end
  else if (is_on (get_quit m) r (wm/4) (4*hm/5) x y) then
    begin
      let play = arr.(0) in
      let multi = arr.(2) in
      let settings = arr.(4) in
      let quit = arr.(7) in
      {m with play; multi; settings; quit}
    end
  else
    begin
      let play = arr.(0) in
      let multi = arr.(2) in
      let settings = arr.(4) in
      let quit = arr.(6) in
      {m with play; multi; settings; quit}
    end
;;

let event e m r wm hm res continue arr =
  let red = Sdl.Color.create 255 0 0 255 in
  let standard = Sdl.Color.create 255 128 128 255 in
  match Sdl.Event.(enum @@ get e typ) with
  | `Quit -> continue := false;
             m
  | `Mouse_button_down ->
     let x = Sdl.Event.get e (Sdl.Event.mouse_button_x) in
     let y = Sdl.Event.get e (Sdl.Event.mouse_button_y) in
     if(is_on (get_quit m) r (wm/4) (4*hm/5) x y) then
       begin
         Sdl.destroy_texture arr.(7);
         arr.(7) <- Settings.create_text r red "Quit";
         {m with quit = arr.(7)}
       end
     else if(is_on (get_play m) r (wm/4) (hm/5) x y) then begin
         Sdl.destroy_texture arr.(1);
         arr.(1) <- Settings.create_text r red "Play";
         {m with play = arr.(1)}
       end
     else if(is_on (get_multi m) r (wm/4) (2*hm/5) x y) then begin
         Sdl.destroy_texture arr.(3);
         arr.(3) <- Settings.create_text r red "Play Online";
         {m with multi = arr.(3)}
       end
     else if(is_on (get_settings m) r (wm/4) (3*hm/5) x y) then begin
         Sdl.destroy_texture arr.(5);
         arr.(5) <- Settings.create_text r red "Settings";
         {m with settings = arr.(5)}
       end
     else m
  | `Mouse_button_up ->
     let x = Sdl.Event.get e (Sdl.Event.mouse_button_x) in
     let y = Sdl.Event.get e (Sdl.Event.mouse_button_y) in
     if(is_on (get_quit m) r (wm/4) (4*hm/5) x y) then
       begin
         continue := false;
         Sdl.destroy_texture arr.(7);
         arr.(7) <- Settings.create_text r standard "Quit";
         {m with quit = arr.(7)}
       end
     else if(is_on (get_play m) r (wm/4) (hm/5) x y) then begin
         Sdl.destroy_texture arr.(1);
         arr.(1) <- Settings.create_text r standard "Play";
         res := 1;
         continue := false;
         {m with play = arr.(1)}
       end
     else if(is_on (get_multi m) r (wm/4) (2*hm/5) x y) then begin
         Sdl.destroy_texture arr.(3);
         arr.(3) <- Settings.create_text r standard "Play Online";
         res := 2;
         continue := false;
         {m with multi = arr.(3)}
       end
     else if(is_on (get_settings m) r (wm/4) (3*hm/5) x y) then begin
         Sdl.destroy_texture arr.(5);
         arr.(5) <- Settings.create_text r standard "Settings";
         res := 3;
         continue := false;
         {m with settings = arr.(5)}
       end
     else
       begin
         Sdl.destroy_texture arr.(1);
         Sdl.destroy_texture arr.(3);
         Sdl.destroy_texture arr.(5);
         Sdl.destroy_texture arr.(7);
         arr.(1) <- Settings.create_text r standard "Play";
         arr.(3) <- Settings.create_text r standard "Play Online";
         arr.(5) <- Settings.create_text r standard "Settings";
         arr.(7) <- Settings.create_text r standard "Quit";
         m
       end
  | _ -> m
;;

let display_text m r wm hm =
  let screen = Sdl.Rect.create 0 0 Settings.width Settings.height in
  let () = Tools.render_copy screen screen r m.background in
  let () = display_element m.play r (wm/4) (hm/5) in
  let () = display_element m.multi r (wm/4) (2*hm/5) in
  let () = display_element m.settings r (wm/4) (3*hm/5) in
  display_element m.quit r (wm/4) (4*hm/5)
;;


(* if the function returns 0: the player has selected quit
If it returns 1: the player has selected play
If it returns 2: the player has selected settings
sw: screen width
sh: screen height
*)
let display renderer sw sh =
  let continue = ref true in
  let arr_text = arr_texture renderer in
  let m = ref (create arr_text renderer) in
  let res = ref 0 in
  let background = Sdl.Rect.create 0 0 sw sh in
  let () = Tools.set_render_draw_color renderer 0 0 0 255 in
  while (!continue) do
    Sdl.render_clear renderer;
    let events = Sdl.Event.create () in
    while Sdl.poll_event (Some(events)) do
      m := event events (!m) renderer sw sh res continue arr_text
    done;
    let x = Sdl.Event.get events (Sdl.Event.mouse_button_x) in
    let y = Sdl.Event.get events (Sdl.Event.mouse_button_y) in
    m := on_or_off (!m) renderer sw sh x y arr_text;
    let () = Tools.render_fill_rect renderer background in
    let () = display_text (!m) renderer sw sh in
    let () = Sdl.render_present renderer in
    Sdl.delay (Int32.of_int(1000/60))
  done;
  Tools.free_arr arr_text;
  Sdl.destroy_texture (!m).background;
  if (!res) = 1 then solo
  else if (!res) = 2 then multi
  else if (!res) = 3 then settings
  else quit
;;

(*let g = display renderer 640 480;;*)
