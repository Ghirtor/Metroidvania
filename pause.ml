open Tsdl;;
open Tsdl_ttf;;

let resume = 0;;
let menu = 2;;

let font = Settings.create_font ();;

type pause = {
    resume : Sdl.texture;
    menu : Sdl.texture;
  };;

let create arr =
  {resume = arr.(0); menu = arr.(2)}
;;

let arr_texture r =
  Array.init 4 (fun i ->
      let standard_color = Sdl.Color.create 255 255 255 255 in
      let select_color = Sdl.Color.create 128 128 128 255 in
      match i with
        0 -> Tools.create_texture_from_font r "Resume" standard_color font
      | 1 -> Tools.create_texture_from_font r "Resume" select_color font
      | 2 -> Tools.create_texture_from_font r "Return to the menu" standard_color font
      | 3 -> Tools.create_texture_from_font r "Return to the menu" select_color font
    )
;;

let free_arr arr =
  for i=0 to (Array.length arr)-1 do
    Sdl.destroy_texture arr.(i)
  done
;;

let get_resume p =
  p.resume
;;

let get_menu p =
  p.menu
;;

let on_or_off m r wm hm x y arr =
  if (x = 0 && y = 0) then m
  else if(Settings.is_on (get_resume m) r (wm/2) (hm/3) x y) then {resume = arr.(1); menu = arr.(2)}
  else if (Settings.is_on (get_menu m) r (wm/2) (2*hm/3) x y) then {resume = arr.(0); menu = arr.(3)}
  else {resume = arr.(0); menu = arr.(2)} 
;;

let actions continue scanesc =
  let bigarr = Sdl.get_keyboard_state () in
  if bigarr.{scanesc} = 1 then continue := false
;;

let event e m r wm hm res continue quit menu_loop =
  match Sdl.Event.(enum @@ get e typ) with
  | `Quit -> continue := false;
             quit := true;
             menu_loop := false
  | `Mouse_button_down ->
     let x = Sdl.Event.get e (Sdl.Event.mouse_button_x) in
     let y = Sdl.Event.get e (Sdl.Event.mouse_button_y) in
     if(Settings.is_on (get_resume m) r (wm/2) (hm/3) x y) then begin
         res := 1;
         continue := false
       end
     else if(Settings.is_on (get_menu m) r (wm/2) (2*hm/3) x y) then begin
         res := 2;
         continue := false
       end
  | _ -> ()
;;

let display_pause p r =
  let () = Settings.display_element (get_resume p) r (Settings.width/2) (Settings.height/3) in
  let () = Settings.display_element (get_menu p) r (Settings.width/2) (2*Settings.height/3) in
  ()
;;

let display renderer =
  let timer = Tsdl.Sdl.get_ticks() in
  let continue = ref true in
  let res = ref 0 in
  let background = Sdl.Rect.create 0 0 Settings.width Settings.height in
  let () = Tools.set_render_draw_color renderer 0 0 0 128 in
  let arr = arr_texture renderer in
  let p = ref (create arr) in
  while (!continue) do
    let events = Sdl.Event.create () in
    while Sdl.poll_event (Some(events)) do
      event events (!p) renderer Settings.width Settings.height res continue
    done;
    let x = Sdl.Event.get events (Sdl.Event.mouse_button_x) in
    let y = Sdl.Event.get events (Sdl.Event.mouse_button_y) in
    p := on_or_off (!p) renderer Settings.width Settings.height x y arr;
    let () = Tools.render_fill_rect renderer background in
    let () = display_pause (!p) renderer in
    let () = Sdl.render_present renderer in
    Sdl.delay (Int32.of_int(1000/60))
  done;
  if (!res) = 1 then resume
  else menu
;;