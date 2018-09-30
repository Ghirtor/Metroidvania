open Tsdl;;
open Tsdl_ttf;;

type selection = {
    levels : Sdl.texture array;
    names : string array;
    menu : Sdl.texture;
    background : Sdl.texture
  };;

let get_name s i =
  s.names.(i)
;;

let white = Sdl.Color.create 255 255 255 255;;
let red = Sdl.Color.create 255 0 0 255;;
let selected = Sdl.Color.create 255 128 128 255;;

let create_font () =
  let t = Ttf.init () in
  match Ttf.open_font "ttf/arial.ttf" 45 with
    |Error (`Msg e) -> Sdl.log "open font error in pause: %s" e; exit 1
    |Ok (f) -> f;;

let font = create_font ();;

let create_arr arr r =
  Array.init (Array.length arr) (fun i ->
      Game_over.create_texture_from_font r arr.(i) white font
    )
;;

let create_arr_menu r =
  Array.init 2 (fun i ->
      match i with
      | 0 -> Tools.create_texture_from_font r "Menu" white font
      | 1 -> Tools.create_texture_from_font r "Menu" selected font
    )
;;

let event e continue menu_loop arr_menu s r choice choice_nb =
  let x = Sdl.Event.get e (Sdl.Event.mouse_button_x) in
  let y = Sdl.Event.get e (Sdl.Event.mouse_button_y) in
  match Sdl.Event.(enum @@ get e typ) with
  | `Quit -> continue := false;
             menu_loop := false;
             s
  | `Mouse_button_down ->
     if(Settings.is_on_left s.menu r 50 (Settings.height/20) x y) then
       begin
         let () = Sdl.destroy_texture arr_menu.(1) in
         arr_menu.(1) <- Tools.create_texture_from_font r "Menu" red font;
         {s with menu = arr_menu.(1)}
       end
     else
       begin
         for i=0 to (Array.length s.levels)-1 do
           if(Settings.is_on s.levels.(i) r (Settings.width/2) ((i+1)*Settings.height/15) x y) then
             begin
               choice := true;
               continue := false;
               choice_nb := i
             end
         done;
         s
       end
  | `Mouse_button_up ->
     if(Settings.is_on_left s.menu r 50 (Settings.height/20) x y) then
       begin
         let () = Sdl.destroy_texture arr_menu.(1) in
         arr_menu.(1) <- Tools.create_texture_from_font r "Menu" selected font;
         continue := false;
         {s with menu = arr_menu.(1)}
       end
     else
       s
  | _ -> s
;;

let create r arr_menu mode =
  let names = if mode = Settings.solo then Tools.get_levels () else Tools.get_arenas () in
  let () = Array.sort String.compare names in
  for i=0 to (Array.length names)-1 do
    let tmp = String.split_on_char '.' names.(i) in
    names.(i) <- (List.hd tmp);
  done;
  let levels = create_arr names r in
  let menu = arr_menu.(0) in
  let background = Tools.create_background "pictures/background_selection.png" r in
  {levels; menu; names; background}
;;

let on_or_off s r x y arr_menu =
  if(x = 0 && y = 0) then s
  else if(Settings.is_on_left s.menu r 50 (Settings.height/20) x y) then
    {s with menu = arr_menu.(1)}
  else
    begin
      for i=0 to (Array.length s.levels)-1 do
        if(Settings.is_on s.levels.(i) r (Settings.width/2) ((i+1)*Settings.height/15) x y) then
          begin
            Sdl.destroy_texture s.levels.(i);
            s.levels.(i) <- Game_over.create_texture_from_font r s.names.(i) selected font
          end
        else
          begin
            Sdl.destroy_texture s.levels.(i);
            s.levels.(i) <- Game_over.create_texture_from_font r s.names.(i) white font
          end
      done;
      {s with menu = arr_menu.(0)}
    end
;;

let destroy_selection s arr_menu =
  let () = Tools.free_arr s.levels in
  let () = Tools.free_arr arr_menu in
  let () = Sdl.destroy_texture s.background in
  Sdl.destroy_texture s.menu
;;

let display_selection s r =
  let screen = Sdl.Rect.create 0 0 Settings.width Settings.height in
  let () = Tools.render_copy screen screen r s.background in
  let () = Settings.display_element_left s.menu r (50) (Settings.height/20)in
  for i=0 to (Array.length s.levels)-1 do
    Settings.display_element s.levels.(i) r (Settings.width/2) ((i+1)*Settings.height/15)
  done;
  ()
;;