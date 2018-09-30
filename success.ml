open Tsdl;;
open Tsdl_ttf;;

let replay = 1;;
let next = 2;;

type success = {
    background : Sdl.texture;
    text : Sdl.texture;
    time : Sdl.texture;
    best_score : Sdl.texture;
    menu : Sdl.texture;
    next : Sdl.texture;
    next_level : bool;
    replay : Sdl.texture
  };;

let create_font size =
  let t = Ttf.init () in
  match Ttf.open_font "ttf/arial.ttf" size with
    |Error (`Msg e) -> Sdl.log "open font error in pause: %s" e; exit 1
    |Ok (f) -> f;;

let create_arr r =
  let white = Sdl.Color.create 255 255 255 255 in
  let gray = Sdl.Color.create 128 128 128 255 in
  let font = create_font 45 in
  Array.init 6 (fun i ->
      match i with
      | 0 -> Tools.create_texture_from_font r "Menu" white font
      | 1 -> Tools.create_texture_from_font r "Menu" gray font
      | 2 -> Tools.create_texture_from_font r "Replay" white font
      | 3 -> Tools.create_texture_from_font r "Replay" gray font
      | 4 -> Tools.create_texture_from_font r "Next Level" white font
      | 5 -> Tools.create_texture_from_font r "Next Level" gray font
    )
;;

let create r t b arr level =
  let font = create_font 120 in
  let font' = create_font 80 in
  let white = Sdl.Color.create 255 255 255 255 in
  let time = Tools.create_texture_from_font r ("Time: "^t) white font' in
  let best_score = Tools.create_texture_from_font r (if b then "Best Score!" else " ") white font' in
  let text = Tools.create_texture_from_font r "Level Complete!" white font in
  let menu = arr.(0) in
  let background = Tools.create_background "pictures/background_level_complete.png" r in
  let replay = arr.(2) in
  let next_level = level in
  let next = if next_level then arr.(4) else Tools.create_texture_from_font r " " white font in
  {time; best_score; text; menu; background; next; replay; next_level}
;;

let destroy_success s arr =
  let () = Sdl.destroy_texture s.background in
  let () = Sdl.destroy_texture s.time in
  let () = Sdl.destroy_texture s.best_score in
  let () = Sdl.destroy_texture s.text in
  Tools.free_arr arr
;;

let display_success s r =
  let screen = Sdl.Rect.create 0 0 Settings.width Settings.height in
  let () = Tools.render_copy screen screen r s.background in
  let () = Settings.display_element s.text r (Settings.width/2) (Settings.height/10) in
  let () = Settings.display_element s.best_score r (Settings.width/5) (3*Settings.height/10) in
  let () = Settings.display_element s.time r (4*Settings.width/5) (3*Settings.height/10) in
  let () = Settings.display_element s.menu r (Settings.width/4) (9*Settings.height/10) in
  let () = Settings.display_element s.replay r (2*Settings.width/4) (9*Settings.height/10) in
  let () = Settings.display_element s.next r (3*Settings.width/4) (9*Settings.height/10) in
  ()
;;

let event e continue s r menu_loop res =
  match Sdl.Event.(enum @@ get e typ) with
  | `Quit -> continue := false;
             menu_loop := false
  | `Mouse_button_down ->
     let x = Sdl.Event.get e (Sdl.Event.mouse_button_x) in
     let y = Sdl.Event.get e (Sdl.Event.mouse_button_y) in
     if(Settings.is_on s.menu r (Settings.width/4) (9*Settings.height/10) x y) then
       begin
         continue := false;
         res := 0
       end
     else if(Settings.is_on s.replay r (2*Settings.width/4) (9*Settings.height/10) x y) then
       begin
         continue := false;
         res := 1
       end
     else if((Settings.is_on s.next r (3*Settings.width/4) (9*Settings.height/10) x y) && s.next_level) then
       begin
         continue := false;
         res := 2
       end
  | _ -> ()
;;

let on_or_off r s x y arr =
  if(x = 0 && y = 0) then s
  else if(Settings.is_on s.menu r (Settings.width/4) (9*Settings.height/10) x y) then
    {s with menu = arr.(1)}
  else if(Settings.is_on s.replay r (2*Settings.width/4) (9*Settings.height/10) x y) then
    {s with replay = arr.(3)}
  else if((Settings.is_on s.next r (3*Settings.width/4) (9*Settings.height/10) x y) && s.next_level) then
    {s with next = arr.(5)}
  else if s.next_level then
    {s with menu = arr.(0); replay = arr.(2); next = arr.(4)}
  else
    {s with menu = arr.(0); replay = arr.(2)}
;;

let display r time best_score menu_loop level multi =
  let continue = ref true in
  let arr = create_arr r in
  let tmp = Tools.get_next_level level in
  let s = ref(create r time best_score arr ((tmp >=0) && (not multi))) in
  let res = ref (-1) in
  while (!continue) do
    let () = Tools.render_clear r in
    let events = Sdl.Event.create () in
    while Sdl.poll_event (Some(events)) do
      event events continue (!s) r menu_loop res
    done;
    let x = Sdl.Event.get events (Sdl.Event.mouse_button_x) in
    let y = Sdl.Event.get events (Sdl.Event.mouse_button_y) in
    s := on_or_off r (!s) x y arr;
    let () = display_success (!s) r in
    Sdl.render_present r;
    Sdl.delay (Int32.of_int(1/Settings.frames_per_second))
  done;
  let () = destroy_success (!s) arr in
  let arr_level = Tools.get_levels () in
  let () = Array.sort String.compare arr_level in
  let i = if (tmp = (-1)) then (Array.length arr_level) else tmp in
  if (!res) = 1 then
    begin
      let n = arr_level.(i-1) in
      (true,n)
    end
  else if (!res) = 2 then
    begin
      let n = arr_level.(i) in
      (true,n)
    end
  else
    begin
      let n = "" in
      (false,n)
    end            
;;