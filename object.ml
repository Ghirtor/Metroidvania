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
  zoom : int;
  jump : float;
  max_jump : float;
  mutable frame_jump : int;
  mutable timer_jump : Tsdl.Sdl.uint32;
  mutable last_damages_time : Tsdl.Sdl.uint32;
  mutable last_fire_time : Tsdl.Sdl.uint32
};;

type fixed = {
  id : int;
  subtype : string;
  positionX : float;
  positionY : float;
  speedX : float;
  speedY : float;
  width : int;
  height : int;
  texture : Object_texture.t;
  optionnal_texture : Object_texture.t;
  sprites : Tsdl.Sdl.rect array array;
  mutable frame : int;
  mutable timer : Tsdl.Sdl.uint32;
  sourceX : int;
  sourceY : int;
  zoom : int;
  mutable status : int;
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

let timer_lasers = ref (Int32.of_int 0);;

let start_timer_lasers () = timer_lasers := Tsdl.Sdl.get_ticks ();;

let get_timer_lasers () = (!timer_lasers);;

type t = Movable of movable | Fixed of fixed;;

let null_collision = {col_type = Null; idA = -1; idB = -1; time = 9999.0; damagesA = -1; damagesB = -1};;

let global_tile_texture = ref (Some(Object_texture.create ""));;

let get_global_tile_texture () =
  match (!global_tile_texture) with
    None -> failwith "no texture"
  |Some(x) -> x;;

(* get the hitbox corresponding to the t object *)

let get_hitbox t =
  match t with
    Movable(x) -> {id = x.id; x = int_of_float x.positionX; y = int_of_float x.positionY; vx = int_of_float x.speedX; vy = int_of_float x.speedY; w = x.width; h = x.height; damages = 0}
  |Fixed(x) -> {id = x.id; x = int_of_float x.positionX; y = int_of_float x.positionY; vx = int_of_float x.speedX; vy = int_of_float x.speedY; w = x.width; h = x.height; damages = 0};;

let to_box t =
  match t with
    Movable(x) -> Tsdl.Sdl.Rect.create (int_of_float x.positionX) (int_of_float x.positionY) ((x.width * x.zoom) - 10) ((x.height * x.zoom) - (x.zoom * 3))
  |Fixed(x) -> Tsdl.Sdl.Rect.create (int_of_float x.positionX) (int_of_float x.positionY) (x.width * x.zoom) (x.height * x.zoom);;

let sprite_jump_right = Sprite_clips.sprite_clips_player_jump_right;;

let sprite_jump_left = Sprite_clips.sprite_clips_player_jump_left;;

(* functions for types t, movable and fixed  *)

let generate_id () =
  let id = ref (-1) in
  fun () -> id := !id + 1; !id;;

let next_id = generate_id ();;

let movable_with_constructor m = Movable m;;

let fixed_with_constructor f = Fixed f;;

let move_vertically m f w h = let t = m.mass in {
  id = m.id;
  direction = if m.direction = 1 && m.speedX < 0.0 then -1 else if m.direction = -1 && m.speedX > 0.0 then 1 else m.direction;
  positionX = m.positionX;
  positionY = Pervasives.max ((m.positionY) +. (f *. (m.speedY))) 0.0;
  speedX = m.speedX;
  speedY = m.speedY;
  width = m.width;
  height = m.height;
  mass = t;
  life = if ((m.positionY) +. (f *. (m.speedY))) <= (float_of_int h) then m.life else 0;
  max_life = m.max_life;
  texture = m.texture;
  sprite_left = m.sprite_left;
  sprite_right = m.sprite_right;
  sprite_stopped = m.sprite_stopped;
  frame = m.frame;
  timer = m.timer;
  zoom = m.zoom;
  jump = m.jump;
  max_jump = m.max_jump;
  frame_jump = m.frame_jump;
  timer_jump = m.timer_jump;
  last_damages_time = m.last_damages_time;
  last_fire_time = m.last_fire_time
};;

let move_horizontally m f w h = let t = m.mass in {
  id = m.id;
  direction = if m.direction = 1 && m.speedX < 0.0 then -1 else if m.direction = -1 && m.speedX > 0.0 then 1 else m.direction;
  positionX = if (int_of_float m.positionY) <= h then Pervasives.max (Pervasives.min ((m.positionX) +. (f *. (m.speedX))) ((float_of_int w) -. ((float_of_int m.width) *. (float_of_int m.zoom)))) (0.0) else m.positionX;
  positionY = m.positionY;
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
  zoom = m.zoom;
  jump = m.jump;
  max_jump = m.max_jump;
  frame_jump = m.frame_jump;
  timer_jump = m.timer_jump;
  last_damages_time = m.last_damages_time;
  last_fire_time = m.last_fire_time
};;

let right m = let l = m.life in {m with speedX = ((float_of_int Settings.player_speed) /. (float_of_int Settings.updates_per_second)); life = l};;

let left m = let l = m.life in {m with speedX = ((-1.0) *. ((float_of_int Settings.player_speed) /. (float_of_int Settings.updates_per_second))); life = l};;

let stop m = let l = m.life in {m with speedX = 0.0; life = l};;

let applyGravity m = let l = m.life in {m with speedY = m.speedY +. ((float_of_int Settings.player_gravity) /. (float_of_int Settings.updates_per_second)); life = l};;

let apply_friction m = let l = m.life in {m with speedY = if m.speedY >= ((float_of_int Settings.player_gravity) /. (float_of_int Settings.updates_per_second)) then max (m.speedY -. ((float_of_int Settings.player_gravity) /. (float_of_int Settings.updates_per_second))) 0.0 else 0.0; life = l};;

let change_direction m = let t = m.mass in {m with direction = -1 * m.direction; mass = t};;

let jump m = {m with jump = if m.jump = Settings.max_jump_player then Settings.max_jump_player else min (m.jump +. ((float_of_int Settings.player_jump) /. (float_of_int Settings.updates_per_second))) (m.max_jump); max_jump = if m.jump = Settings.max_jump_player then 0.0 else m.max_jump; speedY = if m.jump = Settings.max_jump_player then 0.0 else (m.speedY -. ((float_of_int Settings.player_jump) /. (float_of_int Settings.updates_per_second)))};;

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

let get_damage m d = let timer = if (Int32.to_int (Int32.sub (Tsdl.Sdl.get_ticks ()) m.last_damages_time)) > Settings.character_shield_time then Tsdl.Sdl.get_ticks () else m.last_damages_time in {m with life = if timer != m.last_damages_time then (Pervasives.max (m.life - d) 0) else m.life; last_damages_time = timer};;

let health m h = {m with life = (Pervasives.min (m.life + h) m.max_life)};;

let create_movable x y vx vy m l ml p z w h = {id = next_id (); direction = 1; positionX = x; positionY = y; speedX = vx; speedY = vy; width = w; height = h; mass = m; life = l; max_life = ml; texture = Object_texture.create p; sprite_left = Sprite_clips.sprite_clips_player_left; sprite_right = Sprite_clips.sprite_clips_player_right; sprite_stopped = Sprite_clips.sprite_clips_player_stopped; frame = -1; timer = Tsdl.Sdl.get_ticks (); zoom = z; jump = 0.0; max_jump = Settings.max_jump_player; frame_jump = 0; timer_jump = Tsdl.Sdl.get_ticks (); last_damages_time = Tsdl.Sdl.get_ticks (); last_fire_time = Tsdl.Sdl.get_ticks ()};;

let create_enemy m = {m with texture = Object_texture.create "pictures/enemy.png"; life = m.life};;

let create_fixed st x y w h p opt t sx sy z = {id = next_id (); subtype = st; positionX = x; positionY = y; speedX = 0.0; speedY = 0.0; sourceX = sx; sourceY = sy; width = w; height = h; texture = Object_texture.create p; optionnal_texture = Object_texture.create opt; sprites = if not (String.equal st "TILE") then (Sprite_clips.get t) else [|[||];[|Tsdl.Sdl.Rect.create sx sy w h|]|]; frame = 0; timer = Tsdl.Sdl.get_ticks (); zoom = z; status = 1};;

let create_laser x y w h p sx sy z = create_fixed "LASER" x y w h p (Settings.laser_inactive_sprite_dir) (Sprite_clips.laser) sx sy z;;

let create_decoration x y w h p sx sy z = create_fixed "DECORATION" x y w h p p (Sprite_clips.decoration) sx sy z;;

let create_endlevel x y w h p sx sy z = create_fixed "ENDLEVEL" x y w h p (Settings.endlevel_inactive_sprite_dir) (Sprite_clips.endlevel) sx sy z;;

let create_tile x y w h p sx sy z = let e = get_global_tile_texture () in if (String.equal (Object_texture.get_path e) "") then global_tile_texture := Some(Object_texture.create p); create_fixed "TILE" x y w h p p (Sprite_clips.tile) sx sy z;;

let store_textures_fixed f r =
  if not (String.equal f.subtype "TILE") then begin
    for i = 0 to ((Array.length f.sprites.(0)) - 1) do
      Object_texture.store_in_collection f.optionnal_texture f.sprites.(0).(i) r f.zoom;
    done;
    for i = 0 to ((Array.length f.sprites.(1)) - 1) do
      Object_texture.store_in_collection f.texture f.sprites.(1).(i) r f.zoom;
    done;
  end
  else Object_texture.store_in_collection (get_global_tile_texture ()) f.sprites.(1).(0) r f.zoom;;

let create_null_movable () = {id = -1; direction = 1; positionX = -1.0; positionY = -1.0; speedX = -1.0; speedY = -1.0; width = -1; height = -1; mass = -1; life = -1; max_life = -1; texture = Object_texture.create ""; sprite_left = [|Tsdl.Sdl.Rect.create (-1) (-1) (-1) (-1)|]; sprite_right = [|Tsdl.Sdl.Rect.create (-1) (-1) (-1) (-1)|]; sprite_stopped = [|Tsdl.Sdl.Rect.create (-1) (-1) (-1) (-1)|]; frame = -1; timer = Tsdl.Sdl.get_ticks (); zoom = Sprite_clips.sprite_player_zoom; jump = -1.0; max_jump = -1.0; frame_jump = -1; timer_jump = Tsdl.Sdl.get_ticks (); last_damages_time = Tsdl.Sdl.get_ticks (); last_fire_time = Tsdl.Sdl.get_ticks ()};;

let create_null_fixed () = {id = -1; subtype = ""; positionX = -1.0; positionY = -1.0; speedX = -1.0; speedY = -1.0; sourceX = -1; sourceY = -1; width = -1; height = -1; texture = Object_texture.create ""; optionnal_texture = Object_texture.create ""; sprites = Sprite_clips.get (Sprite_clips.tile); frame = 0; timer = Tsdl.Sdl.get_ticks (); zoom = Sprite_clips.sprite_laser_zoom; status = 1};;

let select_frame_movable_jump vx vy f sl sr t =
  let frame = f + 1 in
  if (((Int32.to_int (Tsdl.Sdl.get_ticks ())) - (Int32.to_int t) > Settings.movable_delay_frame)) then
    begin
      if vx > 0.0 then
	begin
	  if frame < sr then frame else 0
	end
      else
	begin
	  if frame < sl then frame else 0
	end
    end
  else f;;

let select_frame_movable vx vy f sl sr t mj =
  let frame = f + 1 in
  if ((vx < 0.0 +. Tools.epsilon && vx > 0.0 -. Tools.epsilon && vy < 0.0 +. Tools.epsilon && vy > 0.0 -. Tools.epsilon) || mj <= 0.0) then -1
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

let is_dead m = m.life = 0;;

let get_delay_frame sub =
  if sub = "LASER" then Settings.laser_delay_frame
  else if sub = "DECORATION" then Settings.decoration_delay_frame
  else if sub = "ENDLEVEL" then Settings.endlevel_delay_frame
  else 0;;

let select_frame_fixed f sa si t st sub =
  let frame = f + 1 in
  if ((Int32.to_int (Tsdl.Sdl.get_ticks ())) - (Int32.to_int t) <= (get_delay_frame sub)) then f
  else
    begin
      match st with
	0 -> if frame < si then frame else si -1
      |_ -> if frame < sa then frame else 0
    end;;

let reset_frame_jump m = m.frame_jump <- 0;;

let enable_jump m = {m with jump = 0.0; max_jump = Settings.max_jump_player};;

let disable_jump m = {m with jump = m.jump; max_jump = 0.0};;

let free t =
  match t with
    Movable(x) -> Object_texture.free (x.texture)
  |Fixed(x) ->
     Object_texture.free (x.texture);
    Object_texture.free (x.optionnal_texture);;

let free_global_var () = Object_texture.free (get_global_tile_texture ());;

(* getters *)

let get_id t =
  match t with
    Movable(x) -> x.id
  |Fixed(x) -> x.id;;

let get_subtype t =
  match t with
    Movable(x) -> "movable"
  |Fixed(x) -> x.subtype;;

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

let get_max_life m = m.max_life;;

let get_texture t =
  match t with
    Movable(x) -> x.texture
  |Fixed(x) -> if x.status = 1 then begin
    if String.equal x.subtype "TILE" then (get_global_tile_texture ()) else x.texture end
    else x.optionnal_texture;;

let get_optionnal_texture f = f.optionnal_texture;;

let get_frame t =
  match t with
    Movable(x) -> if x.jump <= 0.0 then x.frame else x.frame_jump
  |Fixed(x) -> x.frame;;

let get_current_sprite_jump m =
  if m.direction = -1 then begin
    if m.frame_jump < (Array.length sprite_jump_left) then sprite_jump_left.(m.frame_jump) else sprite_jump_left.(0)
  end
  else begin
    if m.frame_jump < (Array.length sprite_jump_right) then sprite_jump_right.(m.frame_jump) else sprite_jump_right.(0)
  end;;

let get_current_sprite t =
  match t with
    Movable(x) ->
      if x.jump > 0.0 then get_current_sprite_jump x
      else begin
	if x.frame = -1 then begin
	  if x.direction = -1 then x.sprite_stopped.(0)
	  else x.sprite_stopped.(1)
	end
	else if x.frame < (Array.length x.sprite_left) then x.sprite_left.(x.frame)
	else x.sprite_right.(x.frame - (Array.length x.sprite_left))
      end
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

let get_sprite_inactive t =
  match t with
    Movable(x) -> failwith "this object doesn't have sprite_active"
  |Fixed(x) -> x.sprites.(0);;

let get_timer t =
  match t with
    Movable(x) -> if x.jump <= 0.0 then x.timer else x.timer_jump
  |Fixed(x) -> x.timer;;

let get_zoom t =
  match t with
    Movable(x) -> x.zoom
  |Fixed(x) -> x.zoom;;

let get_status t =
  match t with
    Movable(x) -> failwith "not implemented"
  |Fixed(x) -> x.status;;

let get_max_jump m =
  match m with
    Movable(x) -> x.max_jump
  |Fixed(x) -> failwith "a fixed object cannot jump";;

let get_jump m =
  match m with
    Movable(x) -> x.jump
  |Fixed(x) -> failwith "a fixed object cannot jump";;

let get_direction m = 
  match m with
    Movable(x) -> x.direction
  |Fixed(x) -> failwith "a fixed object doesn't have direction field";;

let get_last_damages_time t =
  match t with
    Movable(x) -> x.last_damages_time
  |Fixed(x) -> failwith "fixed objects can not get damages";;

let get_last_fire_time t =
  match t with
    Movable(x) -> x.last_fire_time
  |Fixed(x) -> failwith "fixed objects can not fire";;

let animation_stop m = 
  match m with
    Movable(x) -> ((x.speedX < 0.0 +. Tools.epsilon && x.speedX > 0.0 -. Tools.epsilon && x.speedY < 0.0 +. Tools.epsilon && x.speedY > 0.0 -. Tools.epsilon) || x.max_jump <= 0.0)
  |Fixed(x) -> true;;

(* setters  *)

let set_frame t f =
  match t with
    Movable(x) -> if x.jump <= 0.0 then begin x.frame <- f; reset_frame_jump x; end else x.frame_jump <- f
  |Fixed(x) -> x.frame <- f;;

let set_frame_jump t f =
  match t with
    Movable(x) -> x.frame_jump <- f
  |Fixed(x) -> failwith "this object doesn't have jump frame";;

let set_timer t =
  match t with
    Movable(x) -> if x.jump <= 0.0 then x.timer <- Tsdl.Sdl.get_ticks () else x.timer_jump <- Tsdl.Sdl.get_ticks ()
  |Fixed(x) -> x.timer <- Tsdl.Sdl.get_ticks ();;

let set_positionX m p = let l = m.life in {m with positionX = p; life = l};;

let set_positionY m p = let l = m.life in {m with positionY = p; life = l};;

let set_direction m d = let l = m.life in {m with direction = d; life = l};;

let set_jump m j = let l = m.life in {m with jump = j; life = l};;

let set_status f s = if s != f.status then set_frame (fixed_with_constructor f) 0; f.status <- s;;

let change_status f = f.status <- if f.status = 1 then 0 else 1;;

let set_life m l = {m with life = l};;

let set_last_fire_time m = m.last_fire_time <- Tsdl.Sdl.get_ticks ();;

(* functions for collision type *)

let get_first_id c = c.idA;;

let get_second_id c = c.idB;;

let get_time c = c.time;;

let get_damagesA c = c.damagesA;;

let get_damagesB c = c.damagesB;;

let get_collision_type c = c.col_type;;
