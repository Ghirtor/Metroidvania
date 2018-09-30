type t = {path : string; mutable texture : Tsdl.Sdl.texture option; collection : (Tsdl.Sdl.rect,Tsdl.Sdl.texture) Hashtbl.t};;

exception Null_texture;;

let create s = {path = s; texture = None; collection = Hashtbl.create 0};;

let set_texture t e = t.texture <- e.texture;;

let set_texture_from_png t r =
  let s = Tools.load_png (t.path) in
  t.texture <- Some (Tools.create_texture_from_surface r s);
  Tsdl.Sdl.free_surface s;;

let set_texture_from_bmp t r =
  let s = Tools.load_bmp (t.path) in
  t.texture <- Some (Tools.create_texture_from_surface r s);
  Tsdl.Sdl.free_surface s;;

let get_path t = t.path;;

let get_texture t =
  match t.texture with
    None -> raise Null_texture
  |Some(x) -> x;;

let store_in_collection t r gr z =
  let s = (Tools.load_png (t.path)) in
  let (w,h) = Tsdl.Sdl.get_surface_size s in
  let s' =
    match Tsdl.Sdl.create_rgb_surface_with_format ((Tsdl.Sdl.Rect.w r) * z) ((Tsdl.Sdl.Rect.h r) * z) 32 (Tsdl.Sdl.get_surface_format_enum s) with
    |Error (`Msg e) -> Tsdl.Sdl.log "create_rgb_surface_with_format error: %s" e; exit 1
    |Ok (x) -> x in
  Tsdl.Sdl.blit_scaled ~src:s (Some(Tsdl.Sdl.Rect.create (Tsdl.Sdl.Rect.x r) (Tsdl.Sdl.Rect.y r) (Tsdl.Sdl.Rect.w r) (Tsdl.Sdl.Rect.h r))) ~dst:s' None;
  Hashtbl.add (t.collection) r (Tools.create_texture_from_surface gr s');
  Tsdl.Sdl.free_surface s;
  Tsdl.Sdl.free_surface s';;

let render_from_collection t x y r gr z =
  let (_,_,(w,h)) = Tools.query_texture (Hashtbl.find (t.collection) r) in
  let src_scaled_rect = Tsdl.Sdl.Rect.create (if x < 0 then abs x else 0) (if y < 0 then abs y else 0) (w - (if x < 0 then abs x else 0)) (h - (if y < 0 then abs y else 0)) in
  let render_quad = Tsdl.Sdl.Rect.create (max x 0) (max y 0) (Tsdl.Sdl.Rect.w src_scaled_rect) (Tsdl.Sdl.Rect.h src_scaled_rect) in
  try
    Tools.render_copy src_scaled_rect render_quad gr (Hashtbl.find (t.collection) r)
  with
    Null_texture -> Printf.printf "the texture is not initialized : call set_texture before render\n";;

let render t x y r gr z =
  let render_quad = Tsdl.Sdl.Rect.create x y (z * (Tsdl.Sdl.Rect.w r)) (z * (Tsdl.Sdl.Rect.h r)) in
  try
    Tools.render_copy r render_quad gr (get_texture t)
  with
    Null_texture -> Printf.printf "the texture is not initialized : call set_texture before render\n";;

let free t =
  try
    Hashtbl.iter (fun a b -> Tsdl.Sdl.destroy_texture b) (t.collection);
    Hashtbl.reset (t.collection);
    Tsdl.Sdl.destroy_texture (get_texture t);
  with
  |Null_texture -> ();;

