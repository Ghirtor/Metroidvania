type t = {path : string; mutable texture : Tsdl.Sdl.texture option};;

exception Null_texture;;

let create s = {path = s; texture = None};;

let set_texture t r = t.texture <- Some (Tools.create_texture_from_surface r (Tools.load_png (t.path)));;

let get_path t = t.path;;

let get_texture t =
  match t.texture with
    None -> raise Null_texture
  |Some(x) -> x;;

let render t x y r gr z =
  let render_quad = Tsdl.Sdl.Rect.create x y (z * (Tsdl.Sdl.Rect.w r)) (z * (Tsdl.Sdl.Rect.h r)) in
  try
    Tools.render_copy r render_quad gr (get_texture t)
  with
    Null_texture -> Printf.printf "the texture is not initialized : call set_texture before render\n";;
