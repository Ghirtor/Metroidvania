type t = {path : string; texture : Tsdl.Sdl.texture};;

let create s w h r = {path = s; texture = Tools.create_texture_from_surface r (Tools.load_bmp s)};;

let get_path t = t.path;;

let get_texture t = t.texture;;

let render t x y r gr =
  let render_quad = Tsdl.Sdl.Rect.create x y (Tsdl.Sdl.Rect.w r) (Tsdl.Sdl.Rect.h r) in
  Tools.render_copy r render_quad gr (get_texture t);;
