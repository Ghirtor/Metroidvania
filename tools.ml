open Tsdl;;
open Tsdl_image;;
open Tsdl_ttf;;

let epsilon = 0.0001;;

let sdl_initialize () =
  match Sdl.init Sdl.Init.video with
  |Error (`Msg e) -> Sdl.log "Init error: %s" e; exit 1
  |Ok () -> Printf.printf "video initialized\n";
    let r = Image.init Image.Init.png in ();;

let font =
  let t = Ttf.init () in
  match Ttf.open_font "ttf/arial.ttf" 30 with
    |Error (`Msg e) -> Sdl.log "open font error: %s" e; exit 1
    |Ok (f) -> f;;

let create_surface_from_font f s c =
  match Ttf.render_text_solid f s c with
    |Error (`Msg e) -> Sdl.log "create_surface_from_font error: %s" e; exit 1
    |Ok (s) -> s;;

let create_window s w h f =
  (*match Sdl.create_window "metroidvania" 640 480 Sdl.Window.windowed with*)
  match Sdl.create_window s w h f with
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
  |Ok (s) -> s;;

let load_png s =
  match Image.load s with
  |Error (`Msg e) -> Sdl.log "load_png error: %s" e; exit 1
  |Ok (s) -> s;;

let create_texture_from_surface r s =
  match Sdl.create_texture_from_surface r s with
  |Error (`Msg e) -> Sdl.log "create_texture_from_surface error: %s" e; exit 1
  |Ok (t) -> t;;

let query_texture t =
  match Sdl.query_texture t with
  |Error (`Msg e) -> Sdl.log "query_texture error: %s" e; exit 1
  |Ok (i) -> i;;

let render_clear r =
  match Sdl.render_clear r with
  |Error (`Msg e) -> Sdl.log "render_clear error: %s" e; exit 1
  |Ok () -> ();;

let render_fill_rect rend rect =
  match Sdl.render_fill_rect rend (Some(rect)) with
  | Error (`Msg e) -> Sdl.log "render_fill_rect error: %s" e; exit 1
  | Ok() -> ()
;;

let render_draw_rect rend rect =
  match Sdl.render_draw_rect rend (Some(rect)) with
  | Error (`Msg e) -> Sdl.log "render_draw_rect error: %s" e; exit 1
  | Ok() -> ()
;;

let set_render_draw_color rend r g b a =
  match Sdl.set_render_draw_color rend r g b a with
  | Error (`Msg e) -> Sdl.log "set_render_draw_color error: %s" e; exit 1
  | Ok() -> ()
;;

let close () =
  Ttf.close_font font; 
  Ttf.quit ();
  Sdl.quit ();;
