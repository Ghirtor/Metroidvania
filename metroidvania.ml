open Tsdl;;

let user_events = [Sdl.Event.quit];;
let quit = ref false;;

let event e =
  let t = (Sdl.Event.get e Sdl.Event.typ) in
  if t = Sdl.Event.quit then quit := true;;

let play () =
  let events = Sdl.Event.create () in
  while  not (!quit) do
    while Sdl.poll_event (Some(events)) do
      event events;
    done;
  done;;

Tools.sdl_initialize ();;
let window = ref (Tools.create_window "metroidvania" 640 480 Sdl.Window.windowed);;

let renderer = Tools.create_renderer !(window) (Sdl.Renderer.(accelerated + presentvsync));; (* create renderer *)
Sdl.render_present renderer;; (* set this renderer as active *)
(* let texture = create_texture renderer (Sdl.Pixel.format_rgba4444) (Sdl.Texture.access_target) 640 480;; (* create texture *)
set_renderer_target renderer texture;; (* the modifications below will be applied on the texture *)
let rectangle = Sdl.Rect.create 0 0 640 480;;
   renderer_copy rectangle rectangle renderer texture;;*)
let font_img = Tools.load_bmp "img.bmp";;
let texture = Tools.create_texture_from_surface renderer font_img;;
let texture_infos = Tools.query_texture texture;;
let rectangle = Sdl.Rect.create 0 0 640 480;;
Tools.render_copy rectangle rectangle renderer texture;;
Sdl.render_present renderer;;
play ();;

(* Sdl.delay (Int32.of_int 20000);; *)
Sdl.free_surface font_img;;
Sdl.destroy_texture texture;; (* destroy texture *)
Sdl.destroy_renderer renderer;; (* destroy renderer *)
Sdl.destroy_window (!window);;
Sdl.quit ();;
