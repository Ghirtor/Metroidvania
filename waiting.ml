open Tsdl;;
open Tsdl_ttf;;

type wait = {
    background : Sdl.texture;
    text : Sdl.texture;
    text1 : Sdl.texture;
    text2 : Sdl.texture;
    text3 : Sdl.texture;
    menu : Sdl.texture
  };;

let create_font size =
  let t = Ttf.init () in
  match Ttf.open_font "ttf/arial.ttf" size with
    |Error (`Msg e) -> Sdl.log "open font error in pause: %s" e; exit 1
    |Ok (f) -> f;;

let big_font = create_font 80;;
let medium_font = create_font 45;;
let white = Sdl.Color.create 255 255 255 255;;
let selected = Sdl.Color.create 255 128 128 255;;
let red = Sdl.Color.create 255 0 0 255;;

let create_arr r =
  Array.init 2 (fun i ->
      match i with
      | 0 -> Game_over.create_texture_from_font r "Menu" white medium_font
      | 1 -> Game_over.create_texture_from_font r "Menu" selected medium_font
    )
;;

let destroy w arr =
  let () = Sdl.destroy_texture w.background in
  let () = Sdl.destroy_texture w.text in
  let () = Sdl.destroy_texture w.text1 in
  let () = Sdl.destroy_texture w.text2 in
  let () = Sdl.destroy_texture w.text3 in
  Tools.free_arr arr
;;

let create r arr=
  let background = Tools.create_background "pictures/waiting_multi.png" r in
  let text = Game_over.create_texture_from_font r "Waiting for players" white big_font in
  let text1 = Game_over.create_texture_from_font r "Waiting for players." white big_font in
  let text2 = Game_over.create_texture_from_font r "Waiting for players.." white big_font in
  let text3 = Game_over.create_texture_from_font r "Waiting for players..." white big_font in
  let menu = arr.(0) in
  {background; text; text1; text2; text3; menu}
;;

let event e continue menu_loop w arr r =
  let x = Sdl.Event.get e (Sdl.Event.mouse_button_x) in
  let y = Sdl.Event.get e (Sdl.Event.mouse_button_y) in
  match Sdl.Event.(enum @@ get e typ) with
  | `Quit -> continue := false;
             menu_loop := false;
             w
  | `Mouse_button_down ->
     if(Settings.is_on w.menu r (Settings.width/2) (9*Settings.height/10) x y) then
       begin
         Sdl.destroy_texture arr.(1);
         arr.(1) <- Game_over.create_texture_from_font r "Menu" red medium_font;
         {w with menu = arr.(1)}
       end
     else w
  | `Mouse_button_up ->
     if(Settings.is_on w.menu r (Settings.width/2) (9*Settings.height/10) x y) then
       begin
         Sdl.destroy_texture arr.(1);
         arr.(1) <- Game_over.create_texture_from_font r "Menu" selected medium_font;
         continue := false;
         {w with menu = arr.(1)}
       end
     else
       begin
         Sdl.destroy_texture arr.(1);
         arr.(1) <- Game_over.create_texture_from_font r "Menu" selected medium_font;
         w
       end
  | _ -> w
;;

let on_or_off w r x y arr =
  if(x = 0 && y = 0) then w
  else if(Settings.is_on w.menu r (Settings.width/2) (9*Settings.height/10) x y) then
    {w with menu = arr.(1)}
  else
    {w with menu = arr.(0)}
;;

let display r w nb =
  let screen = Sdl.Rect.create 0 0 Settings.width Settings.height in
  let () = Tools.render_copy screen screen r w.background in
  if nb < 30 then
    Settings.display_element w.text r (Settings.width/2) (Settings.height/2)
  else if nb < 60 then
    Settings.display_element w.text1 r (Settings.width/2) (Settings.height/2)
  else if nb < 90 then
    Settings.display_element w.text2 r (Settings.width/2) (Settings.height/2)
  else
    Settings.display_element w.text3 r (Settings.width/2) (Settings.height/2);
  let () = Settings.display_element w.menu r (Settings.width/2) (9*Settings.height/10) in
  ()
;;
