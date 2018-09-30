type bullet = {
  x : float;
  y : float;
  direction : int;
  collided : bool;
  total_dist : float;
  zoom : int;
  h : int;
  w : int;
};;

let global_zoom = 3;;
let max_travel_dist = 600.0;;
let bullet_speed = 600.0;;

let global_bullet_texture = Object_texture.create (Settings.pictures_dir^"bullet.png");;

let sprites = Sprite_clips.get Sprite_clips.bullet;;

let to_box b = Tsdl.Sdl.Rect.create (int_of_float b.x) (int_of_float b.y) b.w (b.h + 10);;

let create x y dir = {x = x; y = y; direction = dir; collided = false; total_dist = 0.0; zoom = global_zoom; h = global_zoom * 10; w = global_zoom * 9};;

let create_null_bullet () = {x = -1.0; y = -1.0; direction = -1; collided = false; total_dist = 0.0; zoom = global_zoom; h = global_zoom * 10; w = global_zoom * 9};;

let store_texture r =
  Object_texture.set_texture_from_png global_bullet_texture r;
  Object_texture.store_in_collection global_bullet_texture sprites.(0).(0) r global_zoom;
  Object_texture.store_in_collection global_bullet_texture sprites.(1).(0) r global_zoom;;

let move b = {b with x = if b.direction > 0 then b.x +. (bullet_speed /. (float_of_int Settings.updates_per_second)) else b.x -. (bullet_speed /. (float_of_int Settings.updates_per_second)); total_dist = b.total_dist +. (bullet_speed /. (float_of_int Settings.updates_per_second)); collided = b.total_dist >= max_travel_dist };;

let collide b = {b with collided = true};;

let get_x b = b.x;;
let get_y b = b.y;;
let get_collided b = b.collided;;
let get_total_dist b = b.total_dist;;
let get_zoom b = b.zoom;;
let get_h b = b.h;;
let get_w b = b.w;;
let get_texture () = global_bullet_texture;;

let get_current_sprite b = if b.collided then sprites.(0).(0) else sprites.(0).(0);;

let free () = Object_texture.free global_bullet_texture;;
