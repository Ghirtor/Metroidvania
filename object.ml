type movable = {
  id : int;
  direction : int;
  positionX : float;
  positionY : float;
  speedX : float;
  speedY : float;
  width : int;
  height : int;
  mass : int;
  life : int;
  max_life : int;
  texture : Object_texture.t;
  sprite_left : Tsdl.Sdl.rect array;
  sprite_right : Tsdl.Sdl.rect array;
  sprite_stopped : Tsdl.Sdl.rect array;
  mutable frame : int;
  mutable timer : Tsdl.Sdl.uint32;
  zoom : int
};;

type fixed = {
  id : int;
  positionX : float;
  positionY : float;
  speedX : float;
  speedY : float;
  width : int;
  height : int;
  texture : Object_texture.t;
  sprites : Tsdl.Sdl.rect array array;
  mutable frame : int;
  mutable timer : Tsdl.Sdl.uint32;
  zoom : int;
  mutable status : int
};;

type collision_type = Null | Horizontal | Vertical;;

type collision = {
  col_type : collision_type;
  idA : int;
  idB : int;
  time : float;
  damagesA : int;
  damagesB : int
};;

type hitbox_rect = {
  id : int;
  x : int;
  y : int;
  vx : int;
  vy : int;
  w : int;
  h : int;
  damages : int
};;

type t = Movable of movable | Fixed of fixed;;

let null_collision = {col_type = Null; idA = -1; idB = -1; time = 9999.0; damagesA = -1; damagesB = -1};;

(* get the hitbox corresponding to the t object *)

let get_hitbox t =
  match t with
    Movable(x) -> {id = x.id; x = int_of_float x.positionX; y = int_of_float x.positionY; vx = int_of_float x.speedX; vy = int_of_float x.speedY; w = x.width; h = x.height; damages = 0}
  |Fixed(x) -> {id = x.id; x = int_of_float x.positionX; y = int_of_float x.positionY; vx = int_of_float x.speedX; vy = int_of_float x.speedY; w = x.width; h = x.height; damages = 0};;

(* functions for types t, movable and fixed  *)

let generate_id () =
  let id = ref (-1) in
  fun () -> id := !id + 1; !id;;

let next_id = generate_id ();;

let movable_with_constructor m = Movable m;;

let fixed_with_constructor f = Fixed f;;

let move m f w h = let t = m.mass in {
  id = m.id;
  direction = if m.direction = 1 && m.speedX < 0.0 then -1 else if m.direction = -1 && m.speedX > 0.0 then 1 else m.direction;
  positionX = Pervasives.max (Pervasives.min ((m.positionX) +. (f *. (m.speedX))) ((float_of_int w) -. (float_of_int m.width) +. 19.0)) (-19.0);
  positionY = Pervasives.max (Pervasives.min ((m.positionY) +. (f *. (m.speedY))) ((float_of_int h) -. (float_of_int m.height))) 0.0;
  speedX = m.speedX;
  speedY = m.speedY;
  width = m.width;
  height = m.height;
  mass = t;
  life = m.life;
  max_life = m.max_life;
  texture = m.texture;
  sprite_left = m.sprite_left;
  sprite_right = m.sprite_right;
  sprite_stopped = m.sprite_stopped;
  frame = m.frame;
  timer = m.timer;
  zoom = m.zoom
};;

let right m c = let l = m.life in {m with speedX = (float_of_int (Settings.player_speed / Settings.frames_per_second)) +. (((Int32.to_float c) /. 1000.0) *. (float_of_int Settings.player_speed))};;

let left m c = let l = m.life in {m with speedX = (float_of_int (-(Settings.player_speed / Settings.frames_per_second))) -. (((Int32.to_float c) /. 1000.0) *. (float_of_int Settings.player_speed))};;

let stop m = let l = m.life in {m with speedX = 0.0};;

let applyGravity m c = let l = m.life in {m with speedY = m.speedY +. (float_of_int (Settings.player_gravity / Settings.frames_per_second)) +. (((Int32.to_float c) /. 1000.0) *. (float_of_int Settings.player_gravity))};;

let apply_friction m c = let l = m.life in {m with speedY = if m.speedY >= (float_of_int (Settings.player_gravity / Settings.frames_per_second)) +. (((Int32.to_float c) /. 1000.0) *. (float_of_int Settings.player_speed)) then m.speedY -. (float_of_int (Settings.player_gravity / Settings.frames_per_second)) -. (((Int32.to_float c) /. 1000.0) *. (float_of_int Settings.player_speed)) else 0.0};;

let change_direction m = let t = m.mass in {m with direction = -1 * m.direction};;

let jump m = m;;

(* we assume that point (x=0, y=0 is at top left corner *)
(* checks if there is a collision between 2 hitboxes *)
let get_collision h1 h2 =
  let top = if h2.y > h1.y then h1 else h2 in
  let bottom = if top == h1 then h2 else h1 in
  let left = if h1.x < h2.x then h1 else h2 in
  let right = if left == h1 then h2 else h1 in
  (* checks if hitboxes are already in collision *)
  let c1 = right.x <= left.x + left.w in
  let c2 = top.y + top.h >= bottom.y in
  if c1 && c2 then null_collision else
    begin
      (* checks if hitboxes are getting away *)
      let c3 = right.vx >= 0 && left.vx <= 0 in
      let c4 = top.vy <= 0 && bottom.vy >= 0 in
      if c3 && c4 then null_collision else
	begin
	  let time_before_collision_x = (float_of_int (Pervasives.abs (right.x - (left.x + left.w)))) /. (float_of_int (Pervasives.abs (left.vx + right.vx))) in
	  let time_before_collision_y = (float_of_int (Pervasives.abs (bottom.y - (top.y + top.h)))) /. (float_of_int (Pervasives.abs (bottom.vy + top.vy))) in
	  let time_before_collision = Pervasives.max time_before_collision_x time_before_collision_y in
	  let entityA = if time_before_collision_x > time_before_collision_y then left else top in
	  let entityB = if time_before_collision_x > time_before_collision_y then right else bottom in
	  (* A is the entity at left if collision is of type Horizontal and at top in the other case. B is the other one  *)
	  {col_type = if time_before_collision < 0.0 then Null else if time_before_collision_x > time_before_collision_y then Horizontal else Vertical; idA = entityA.id; idB = entityB.id; time = time_before_collision; damagesA = entityA.damages; damagesB = entityB.damages};
	end;
    end;;

let collide t1 t2 = get_collision (get_hitbox t1) (get_hitbox t2);;

let get_damage m d = {m with life = (Pervasives.max (m.life - d) 0)};;

let health m h = {m with life = (Pervasives.min (m.life + h) m.max_life)};;

let create_movable x y vx vy m l ml p = {id = next_id (); direction = 1; positionX = x; positionY = y; speedX = vx; speedY = vy; width = (Sprite_clips.sprite_player_stopped_width) * Sprite_clips.sprite_player_zoom; height = (Sprite_clips.sprite_player_stopped_height) * Sprite_clips.sprite_player_zoom; mass = m; life = l; max_life = ml; texture = Object_texture.create p; sprite_left = Sprite_clips.sprite_clips_player_left; sprite_right = Sprite_clips.sprite_clips_player_right; sprite_stopped = Sprite_clips.sprite_clips_player_stopped; frame = -1; timer = Tsdl.Sdl.get_ticks (); zoom = Sprite_clips.sprite_player_zoom};;

let create_fixed x y w h p t = {id = next_id (); positionX = x; positionY = y; speedX = 0.0; speedY = 0.0; width = w; height = h; texture = Object_texture.create p; sprites = [|[||]; Sprite_clips.get t|]; frame = 0; timer = Tsdl.Sdl.get_ticks (); zoom = Sprite_clips.sprite_laser_zoom; status = 1};;

let create_null_movable () = {id = -1; direction = 1; positionX = -1.0; positionY = -1.0; speedX = -1.0; speedY = -1.0; width = -1; height = -1; mass = -1; life = -1; max_life = -1; texture = Object_texture.create ""; sprite_left = [|Tsdl.Sdl.Rect.create (-1) (-1) (-1) (-1)|]; sprite_right = [|Tsdl.Sdl.Rect.create (-1) (-1) (-1) (-1)|]; sprite_stopped = [|Tsdl.Sdl.Rect.create (-1) (-1) (-1) (-1)|]; frame = -1; timer = Tsdl.Sdl.get_ticks (); zoom = Sprite_clips.sprite_player_zoom};;

let create_null_fixed () = {id = -1; positionX = -1.0; positionY = -1.0; speedX = -1.0; speedY = -1.0; width = -1; height = -1; texture = Object_texture.create ""; sprites = [|Sprite_clips.get Sprite_clips.laser|]; frame = 0; timer = Tsdl.Sdl.get_ticks (); zoom = Sprite_clips.sprite_laser_zoom; status = 1};;

let select_frame_movable vx vy f sl sr t =
  let frame = f + 1 in
  if ((vx = 0.0 && vy = 0.0) || vy > 0.0) then -1
  else if (((Int32.to_int (Tsdl.Sdl.get_ticks ())) - (Int32.to_int t) > Settings.movable_delay_frame) || f = (-1)) then
    begin
      if vx > 0.0 then
	begin
	  if frame < (sl + sr) && frame >= sl then frame
	  else if frame = (sl + sr) then sl
	  else frame + sl
	end
      else
	begin
	  if frame < sl then frame
	  else if frame = sl then 0
	  else frame - sr
	end
    end
  else f;;

let select_frame_fixed f sa si t st =
  let frame = f + 1 in
  if ((Int32.to_int (Tsdl.Sdl.get_ticks ())) - (Int32.to_int t) <= Settings.laser_delay_frame) then f
  else
    begin
      match st with
	0 -> if frame < si then frame else 0
      |_ -> if frame < sa then frame else 0
    end;;

(* getters *)

let get_id t =
  match t with
    Movable(x) -> x.id
  |Fixed(x) -> x.id;;

let compare t1 t2 = (get_id t1) = (get_id t2);;

let compare_movable m1 m2 = m1 == m2;;

let compare_fixed f1 f2 = f1 == f2;;

let get_positionX t =
  match t with
    Movable(x) -> x.positionX
  |Fixed(x) -> x.positionX;;

let get_positionY t =
  match t with
    Movable(x) -> x.positionY
  |Fixed(x) -> x.positionY;;

let get_speedX t =
  match t with
    Movable(x) -> x.speedX
  |Fixed(x) -> x.speedX;;

let get_speedY t =
  match t with
    Movable(x) -> x.speedY
  |Fixed(x) -> x.speedY;;

let get_width t =
  match t with
    Movable(x) -> x.width
  |Fixed(x) -> x.width;;

let get_height t =
  match t with
    Movable(x) -> x.height
  |Fixed(x) -> x.height;;

let get_mass m = m.mass;;

let get_life m = m.life;;

let get_texture t =
  match t with
    Movable(x) -> x.texture
  |Fixed(x) -> x.texture;;

let get_frame t =
  match t with
    Movable(x) -> x.frame
  |Fixed(x) -> x.frame;;

let get_current_sprite t =
  match t with
    Movable(x) ->
      if x.frame = -1 then begin
	if x.direction = -1 then x.sprite_stopped.(0)
	else x.sprite_stopped.(1)
      end
      else if x.frame < (Array.length x.sprite_left) then x.sprite_left.(x.frame)
      else x.sprite_right.(x.frame - (Array.length x.sprite_left))
  |Fixed(x) -> x.sprites.(x.status).(x.frame);;

let get_sprite_left t =
  match t with
    Movable(x) -> x.sprite_left
  |Fixed(x) -> failwith "this object doesn't have sprite_left";;

let get_sprite_right t =
  match t with
    Movable(x) -> x.sprite_right
  |Fixed(x) -> failwith "this object doesn't have sprite_right";;

let get_sprite_active t =
  match t with
    Movable(x) -> failwith "this object doesn't have sprite_active"
  |Fixed(x) -> x.sprites.(1);;

let get_timer t =
  match t with
    Movable(x) -> x.timer
  |Fixed(x) -> x.timer;;

let get_zoom t =
  match t with
    Movable(x) -> x.zoom
  |Fixed(x) -> x.zoom;;

let get_status t =
  match t with
    Movable(x) -> failwith "not implemented"
  |Fixed(x) -> x.status;;

(* setters  *)

let set_frame t f =
  match t with
    Movable(x) -> x.frame <- f
  |Fixed(x) -> x.frame <- f;;

let set_timer t =
  match t with
    Movable(x) -> x.timer <- Tsdl.Sdl.get_ticks ()
  |Fixed(x) -> x.timer <- Tsdl.Sdl.get_ticks ();;

(* functions for collision type *)

let get_first_id c = c.idA;;

let get_second_id c = c.idB;;

let get_time c = c.time;;

let get_damagesA c = c.damagesA;;

let get_damagesB c = c.damagesB;;

let get_collision_type c = c.col_type;;
