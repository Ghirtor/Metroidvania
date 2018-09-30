open Tsdl;;
open Tsdl_ttf;;

(*let () = Tools.sdl_initialize ();;
let window = Tools.create_window "metroidvania" Settings.width Settings.height (Sdl.Window.windowed);;

let renderer = Tools.create_renderer window (Sdl.Renderer.(accelerated + presentvsync));; (* create renderer *)
Sdl.render_present renderer;;*)

let retry = 1;;
let quit = 2;;
let close = 3;;

let create_font size =
  let t = Ttf.init () in
  match Ttf.open_font "ttf/impact.ttf" size with
    |Error (`Msg e) -> Sdl.log "open font error in pause: %s" e; exit 1
    |Ok (f) -> f;;

let create_texture_from_font r text color font =
  let tmp = Tools.create_surface_from_font font text color in
  let texture = Tools.create_texture_from_surface r tmp in
  let () = Sdl.free_surface tmp in
  texture
;;

let create_background s r =
  let tmp = Tools.load_png s in
  let res = Tools.create_texture_from_surface r tmp in
  let () = Sdl.free_surface tmp in
  res
;;

type game_over = {
    go_background : Sdl.texture;
    go_text : Sdl.texture;
    go_continue : Sdl.texture;
    go_menu : Sdl.texture
  };;

let create_arr r =
  let big_font = create_font 110 in
  let medium_font = create_font 90 in
  let black = Sdl.Color.create 0 0 0 255 in
  let gray = Sdl.Color.create 128 128 128 255 in
  Array.init 6 (fun i ->
      match i with
      | 0 -> create_texture_from_font r "GAME OVER" black big_font
      | 1 -> create_texture_from_font r "Retry" black medium_font
      | 2 -> create_texture_from_font r "Retry" gray medium_font
      | 3 -> create_texture_from_font r "Menu" black medium_font
      | 4 -> create_texture_from_font r "Menu" gray medium_font
      | 5 -> create_texture_from_font r " " black medium_font
    )
;;

let create_game_over r arr multi =
  let go_background = create_background "pictures/background_game_over.png" r in
  let go_text = arr.(0) in
  let go_continue = if multi then arr.(5) else arr.(2) in
  let go_menu = arr.(4) in
  {go_background; go_text; go_continue; go_menu}
;;

let display_game_over r go =
  let screen = Sdl.Rect.create 0 0 Settings.width Settings.height in
  let () = Tools.render_copy screen screen r go.go_background in
  let() = Settings.display_element_left go.go_text r 50 (Settings.height/3) in
  let () = Settings.display_element_left go.go_continue r 50 (2*Settings.height/3) in
  let () = Settings.display_element_left go.go_menu r 50 (2*Settings.height/3+Settings.height/8) in
  ()
;;

let event e continue res go r multi =
  match Sdl.Event.(enum @@ get e typ) with
  | `Quit -> continue := false; res := close;
  | `Mouse_button_down ->
     let x = Sdl.Event.get e (Sdl.Event.mouse_button_x) in
     let y = Sdl.Event.get e (Sdl.Event.mouse_button_y) in
     if((Settings.is_on_left go.go_continue r 50 (2*Settings.height/3) x y) && (not multi)) then
       begin
         continue := false;
         res := retry
       end
     else if(Settings.is_on_left go.go_menu r 50 (2*Settings.height/3+Settings.height/8) x y) then
       begin
         continue := false;
         res := quit
       end
     else ()
     
  | _ -> ()
;;

let on_or_off_game_over r go x y arr multi =
  if(x = 0 && y = 0) then go
  else if((Settings.is_on_left go.go_continue r 50 (2*Settings.height/3) x y) && (not multi)) then
    {go with go_continue = arr.(2); go_menu = arr.(3)}
  else if (Settings.is_on_left go.go_menu r 50 (2*Settings.height/3+Settings.height/8) x y) then
    if (not multi) then
      {go with go_menu = arr.(4); go_continue = arr.(1)}
    else
      {go with go_menu = arr.(4)}
  else if (not multi) then
    {go with go_continue = arr.(1); go_menu = arr.(3)}
  else
    {go with go_menu = arr.(3)}
;;

let destroy_game_over go arr =
  let () = Sdl.destroy_texture go.go_background in
  Pause.free_arr arr
;;

let display renderer multi =
  let res = ref 0 in
  let continue = ref true in
  let arr = create_arr renderer in
  let go = ref (create_game_over renderer arr multi) in
  while(!continue) do
    let () = Tools.render_clear renderer in
    let events = Sdl.Event.create () in
    while Sdl.poll_event (Some(events)) do
      event events continue res (!go) renderer multi
    done;
    let x = Sdl.Event.get events (Sdl.Event.mouse_button_x) in
    let y = Sdl.Event.get events (Sdl.Event.mouse_button_y) in
    go := on_or_off_game_over renderer (!go) x y arr multi;
    let () = display_game_over renderer (!go) in
    let () = Sdl.render_present renderer in
    Sdl.delay (Int32.of_int(1000/Settings.frames_per_second))
  done;
  let () = destroy_game_over (!go) arr in
  (!res)
;;

(*display renderer true;;*)