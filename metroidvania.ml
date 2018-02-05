open Tsdl;;

let user_events = [Sdl.Event.quit];;
let quit = ref false;;

(* need to be completed later *)
let sdl_initialize () =
  match Sdl.init Sdl.Init.video with
  |Error (`Msg e) -> Sdl.log "Init error: %s" e; exit 1
  |Ok () -> Printf.printf "video initialized\n";;

let create_window s w h f =
  match Sdl.create_window "metroidvania" 640 480 Sdl.Window.windowed with
  |Error (`Msg e) -> Sdl.log "create_window error: %s" e; exit 1
  |Ok (w) -> w;;

let get_window_surface w =
  match Sdl.get_window_surface w with
  |Error (`Msg e) -> Sdl.log "get_window_surface error: %s" e; exit 1
  |Ok (s) -> s;;

let create_renderer w f =
  match Sdl.create_renderer ~index:(-1) ~flags:f w with
  |Error (`Msg e) -> Sdl.log "create_render error: %s" e; exit 1
  |Ok (r) -> r;;

let create_texture r f a w h =
  match Sdl.create_texture r f a ~w:w ~h:h with
  |Error (`Msg e) -> Sdl.log "create_texture error: %s" e; exit 1
  |Ok (r) -> r;;

let set_render_target r t =
  match Sdl.set_render_target r (Some(t))  with
  |Error (`Msg e) -> Sdl.log "set_renderer_target error: %s" e; exit 1
  |Ok () -> ();;

let render_copy src dst r t =
  match Sdl.render_copy ~src:src ~dst:dst r t with
  |Error (`Msg e) -> Sdl.log "renderer_copy error: %s" e; exit 1
  |Ok () -> ();;

let load_bmp s =
  match Sdl.load_bmp s with
  |Error (`Msg e) -> Sdl.log "load_bmp error: %s" e; exit 1
  |Ok (r) -> r;;

let create_texture_from_surface r s =
  match Sdl.create_texture_from_surface r s with
  |Error (`Msg e) -> Sdl.log "create_texture_from_surface error: %s" e; exit 1
  |Ok (t) -> t;;

let query_texture t =
  match Sdl.query_texture t with
  |Error (`Msg e) -> Sdl.log "query_texture error: %s" e; exit 1
  |Ok (i) -> i;;

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

sdl_initialize ();;
let window = ref (create_window "metroidvania" 640 480 Sdl.Window.windowed);;

let renderer = create_renderer !(window) (Sdl.Renderer.(accelerated + presentvsync));; (* create renderer *)
Sdl.render_present renderer;; (* set this renderer as active *)
(* let texture = create_texture renderer (Sdl.Pixel.format_rgba4444) (Sdl.Texture.access_target) 640 480;; (* create texture *)
set_renderer_target renderer texture;; (* the modifications below will be applied on the texture *)
let rectangle = Sdl.Rect.create 0 0 640 480;;
   renderer_copy rectangle rectangle renderer texture;;*)
let font_img = load_bmp "img.bmp";;
let texture = create_texture_from_surface renderer font_img;;
let texture_infos = query_texture texture;;
let rectangle = Sdl.Rect.create 0 0 640 480;;
render_copy rectangle rectangle renderer texture;;
Sdl.render_present renderer;;
play ();;

(* Sdl.delay (Int32.of_int 20000);; *)
Sdl.free_surface font_img;;
Sdl.destroy_texture texture;; (* destroy texture *)
Sdl.destroy_renderer renderer;; (* destroy renderer *)
Sdl.destroy_window (!window);;
Sdl.quit ();;
