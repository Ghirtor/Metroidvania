open Tsdl;;
open Tsdl_ttf;;

(*let () = Tools.sdl_initialize ();;
let window = Tools.create_window "metroidvania" Settings.width Settings.height (Sdl.Window.windowed);;

let renderer = Tools.create_renderer window (Sdl.Renderer.(accelerated + presentvsync));; (* create renderer *)
Sdl.render_present renderer;;*)

type loading = {
    symbole : Sdl.texture;
    background : Sdl.texture;
    load : Sdl.texture;
    loaddot : Sdl.texture;
    loaddotdot : Sdl.texture;
    loaddotdotdot : Sdl.texture
  };;

let create_font () =
  let t = Ttf.init () in
  match Ttf.open_font "ttf/arial.ttf" 100 with
    |Error (`Msg e) -> Sdl.log "open font error in pause: %s" e; exit 1
    |Ok (f) -> f;;

let font = create_font ();;

let create_texture_from_font r text color =
  let tmp = Tools.create_surface_from_font font text color in
  let texture = Tools.create_texture_from_surface r tmp in
  let () = Sdl.free_surface tmp in
  texture
;;

let create r =
  let black = Sdl.Color.create 255 255 255 255 in
  let symbole = create_texture_from_font r "M" black in
  let img = Tools.load_png "pictures/background_loading.png" in
  let background = Tools.create_texture_from_surface r img in
  let () = Sdl.free_surface img in
  let load = create_texture_from_font r "Loading" black in
  let loaddot = create_texture_from_font r "Loading." black in
  let loaddotdot = create_texture_from_font r "Loading.." black in
  let loaddotdotdot = create_texture_from_font r "Loading..." black in
  {symbole; background; load; loaddot; loaddotdot; loaddotdotdot}
;;

let display r l nb =
  let bg = Sdl.Rect.create 0 0 Settings.width Settings.height in
  Tools.render_copy bg bg r l.background;
  (*let (_,_,(w,h)) = Tools.query_texture l.symbole in
  let middle = Sdl.Point.create (w/2) (h/2) in
  let src = Sdl.Rect.create 0 0 w h in
  let dst = Sdl.Rect.create (Settings.width/2-w/2) (Settings.height/2-h/2) w h in
  Tools.render_copy_ex src dst r l.symbole nb middle Sdl.Flip.horizontal*)
  if nb < 30 then
    Settings.display_element l.load r (Settings.width/2) (Settings.height/2)
  else if (nb >= 30 && nb < 60) then
    Settings.display_element l.loaddot r (Settings.width/2) (Settings.height/2)
  else if(nb >= 60 && nb < 90) then
    Settings.display_element l.loaddotdot r (Settings.width/2) (Settings.height/2)
  else
    Settings.display_element l.loaddotdotdot r (Settings.width/2) (Settings.height/2)
(*Settings.display_element l.symbole r (Settings.width/2) (Settings.height/2)*)
;;

let event e continue =
  match Sdl.Event.(enum @@ get e typ) with
  | `Quit -> continue := false
  | _ -> ()
;;

let destroy_load l =
  Sdl.destroy_texture l.background;
  Sdl.destroy_texture l.symbole;
  Sdl.destroy_texture l.load;
  Sdl.destroy_texture l.loaddot;
  Sdl.destroy_texture l.loaddotdot;
  Sdl.destroy_texture l.loaddotdotdot
;;

(*let test () =
  let continue = ref true in
  let l = create renderer in
  let nb = ref 0 in
  while(!continue) do
    display renderer l (!nb);
    let events = Sdl.Event.create () in
    while Sdl.poll_event (Some(events)) do
      event events continue
    done;
    Sdl.render_present renderer;
    nb := (!nb)+1;
    if (!nb) = 120 then
      nb := 0;
    Sdl.delay (Int32.of_int(1/Settings.frames_per_second))
  done
;;


let () = test ();;*)