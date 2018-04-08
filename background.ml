type background = {
  id : int;
  x : int;
  y : int;
  w : int;
  h : int
};;

let global_sprite = ref (Tsdl.Sdl.Rect.create 1 1 1 1);;
let global_texture = ref None;;
let global_zoom = ref 0;;

let generate_id () =
  let id = ref (-1) in
  fun () -> id := !id + 1; !id;;

let next_id = generate_id ();;

let get_global_texture () =
  match (!global_texture) with
    None -> failwith "no texture"
  |Some(x) -> x;;

let create_null_background () = {id = -1; x = -1; y = -1; w = -1; h = -1};;

let create x y w h z p =
  if (Tsdl.Sdl.Rect.x (!global_sprite)) = 1 || (not (String.equal (Object_texture.get_path (get_global_texture ())) p)) then begin
    global_sprite := Tsdl.Sdl.Rect.create 0 0 w h;
    global_texture := Some(Object_texture.create p);
    global_zoom := z;
  end;
  {id = next_id (); x = x; y = y; w = w; h = h};;

let set_texture r = Object_texture.set_texture_from_bmp (get_global_texture ()) r;;

let store_texture b r = Object_texture.store_in_collection (get_global_texture ()) (!global_sprite) r (!global_zoom);;

let get_sprite b = !global_sprite;;

let get_id b = b.id;;

let to_box b = Tsdl.Sdl.Rect.create b.x b.y (b.w * (!global_zoom)) (b.h * (!global_zoom));;

let get_x b = b.x;;
let get_y b = b.y;;
let get_w b = b.w;;
let get_h b = b.h;;
let get_zoom b = (!global_zoom);;
let get_texture b = get_global_texture ();;
