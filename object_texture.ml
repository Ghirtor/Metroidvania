(*type t = {path : string; mutable texture : Tsdl.Sdl.texture option};;

exception Null_texture;;

let create s = {path = s; texture = None};;

let set_texture t r =
  let s = (Tools.load_png (t.path)) in
  let (w,h) = Tsdl.Sdl.get_surface_size s in
  let s' =
    match Tsdl.Sdl.create_rgb_surface_with_format (w*4) (h*4) 32 (Tsdl.Sdl.get_surface_format_enum s) with
    |Error (`Msg e) -> Tsdl.Sdl.log "create_rgb_surface_with_format error: %s" e; exit 1
    |Ok (x) -> x in
  Tsdl.Sdl.blit_scaled ~src:s None ~dst:s' None;
  t.texture <- Some (Tools.create_texture_from_surface r s');;

let get_path t = t.path;;

let get_texture t =
  match t.texture with
    None -> raise Null_texture
  |Some(x) -> x;;

let render t x y r gr z =
  let src_scaled_rect = Tsdl.Sdl.Rect.create ((Tsdl.Sdl.Rect.x r) * 4) ((Tsdl.Sdl.Rect.y r) * 4) ((Tsdl.Sdl.Rect.w r) * 4) ((Tsdl.Sdl.Rect.h r) * 4) in
  let render_quad = Tsdl.Sdl.Rect.create x y ((Tsdl.Sdl.Rect.w r) * 4) ((Tsdl.Sdl.Rect.h r) * 4) in
  try
    Tools.render_copy src_scaled_rect render_quad gr (get_texture t)
  with
  Null_texture -> Printf.printf "the texture is not initialized : call set_texture before render\n";;*)

(*type t = {path : string; mutable texture : Tsdl.Sdl.texture option};;

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
  Null_texture -> Printf.printf "the texture is not initialized : call set_texture before render\n";;*)

type t = {path : string; mutable texture : Tsdl.Sdl.texture option; collection : (Tsdl.Sdl.rect,Tsdl.Sdl.texture) Hashtbl.t};;

exception Null_texture;;

let create s = {path = s; texture = None; collection = Hashtbl.create 100};;

let set_texture t e = t.texture <- e.texture;;

let set_texture_from_png t r = t.texture <- Some (Tools.create_texture_from_surface r (Tools.load_png (t.path)));;

let set_texture_from_bmp t r = t.texture <- Some (Tools.create_texture_from_surface r (Tools.load_bmp (t.path)));;

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
  Hashtbl.add (t.collection) r (Tools.create_texture_from_surface gr s');;

(*let render t x y r gr z =
  let () =
    try
      let e = Hashtbl.find (t.collection) r in ()
    with
    |Not_found ->
       let s = (Tools.load_png (t.path)) in
       let (w,h) = Tsdl.Sdl.get_surface_size s in
       let s' =
	 match Tsdl.Sdl.create_rgb_surface_with_format ((Tsdl.Sdl.Rect.w r) * z) ((Tsdl.Sdl.Rect.h r) * z) 32 (Tsdl.Sdl.get_surface_format_enum s) with
	 |Error (`Msg e) -> Tsdl.Sdl.log "create_rgb_surface_with_format error: %s" e; exit 1
	 |Ok (x) -> x in
       Tsdl.Sdl.blit_scaled ~src:s (Some(Tsdl.Sdl.Rect.create (Tsdl.Sdl.Rect.x r) (Tsdl.Sdl.Rect.y r) (Tsdl.Sdl.Rect.w r) (Tsdl.Sdl.Rect.h r))) ~dst:s' None;
       Hashtbl.add (t.collection) r (Tools.create_texture_from_surface gr s')
  in
  let (_,_,(w,h)) = Tools.query_texture (Hashtbl.find (t.collection) r) in
  let src_scaled_rect = Tsdl.Sdl.Rect.create 0 0 w h in
  let render_quad = Tsdl.Sdl.Rect.create x y (Tsdl.Sdl.Rect.w src_scaled_rect) (Tsdl.Sdl.Rect.h src_scaled_rect) in
  try
    Tools.render_copy src_scaled_rect render_quad gr (Hashtbl.find (t.collection) r)
  with
  Null_texture -> Printf.printf "the texture is not initialized : call set_texture before render\n";;*)

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
