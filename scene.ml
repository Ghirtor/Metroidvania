type scene = {
    characters : Object.movable array;
    enemies : Object.movable array;
    monsters : Object.movable array;
    decoration : Object.fixed array;
    tiles : Object.fixed array;
    traps : Object.fixed array;
    endlevels : Object.fixed array;
    backgrounds : Background.background array;
    nb_characters : int ref; (* Number of heroes in the scene *)
    nb_enemies : int ref; (* Number of enemies in the scene *)
    nb_monsters : int ref;
    nb_decoration : int ref;
    nb_tiles : int ref;
    nb_traps : int ref;
    cam : Camera.t ref;
    width : int;
    height : int;
    background_areas : Background.background array array array;
    tile_areas : Object.fixed array array array;
    mutable end_time : Tsdl.Sdl.uint32;
    mutable ended : bool;
    friendly_bullets : Bullet.bullet array;
    enemy_bullets : Bullet.bullet array
};;

type packet = {
  mutable positionX : int;
  mutable positionY : int;
  mutable frame : int;
  mutable state : int;
  mutable direction : int;
  mutable latency : int;
  mutable life : int;
  mutable display : int
};;

let udp_packet = {positionX = 0; positionY = 0; frame = 0; state = 0; direction = 0; latency = 0; life = 0; display = 0};;

let get_enemy_display () = udp_packet.display = 1;;

let area_width = 100;;
let area_height = 100;;

let win = 0;;
let continue = 1;;

let create_movables n =
  Array.make n (Object.create_null_movable ())
;;

let create_fixed n =
  Array.make n (Object.create_null_fixed ())
;;

let create characters enemies monsters decoration tiles traps endlevels backgrounds width height to_cam =
  let back_count_per_area = Array.init (width / area_width + 1) (fun i -> Array.init (height / area_height + 1) (fun j -> 0)) in
  let tile_count_per_area = Array.init (width / area_width + 1) (fun i -> Array.init (height / area_height + 1) (fun j -> 0)) in
  for i = 0 to ((Array.length backgrounds) - 1) do
    let infx = ((Background.get_x backgrounds.(i)) / area_width) in
    let supx = (((Background.get_x backgrounds.(i)) + ((Background.get_w backgrounds.(i)) * (Background.get_zoom backgrounds.(i)))) / area_width) in
    let infy = ((Background.get_y backgrounds.(i)) / area_height) in
    let supy = (((Background.get_y backgrounds.(i)) + ((Background.get_h backgrounds.(i)) * (Background.get_zoom backgrounds.(i)))) / area_height) in
    for j = infx to (min supx (width / area_width)) do
      for k = infy to (min supy (height / area_height)) do
	back_count_per_area.(j).(k) <- back_count_per_area.(j).(k) + 1;
      done;
    done;
  done;
  for i = 0 to ((Array.length tiles) - 1) do
    let infx = ((int_of_float (Object.get_positionX (Object.fixed_with_constructor tiles.(i)))) / area_width) in
    let supx = (((int_of_float (Object.get_positionX (Object.fixed_with_constructor tiles.(i)))) + ((Object.get_width (Object.fixed_with_constructor tiles.(i))) * (Object.get_zoom (Object.fixed_with_constructor tiles.(i))))) / area_width) in
    let infy = ((int_of_float (Object.get_positionY (Object.fixed_with_constructor tiles.(i)))) / area_height) in
    let supy = (((int_of_float (Object.get_positionY (Object.fixed_with_constructor tiles.(i)))) + ((Object.get_height (Object.fixed_with_constructor tiles.(i))) * (Object.get_zoom (Object.fixed_with_constructor tiles.(i))))) / area_height) in
    for j = infx to (min supx (width / area_width)) do
      for k = infy to (min supy (height / area_height)) do
	tile_count_per_area.(j).(k) <- tile_count_per_area.(j).(k) + 1;
      done;
    done;
  done;
  let back_a = Array.init (width / area_width + 1) (fun i -> Array.init (height / area_height + 1) (fun j -> Array.init back_count_per_area.(i).(j) (fun k -> Background.create_null_background ()))) in
  let tile_a = Array.init (width / area_width + 1) (fun i -> Array.init (height / area_height + 1) (fun j -> Array.init tile_count_per_area.(i).(j) (fun k -> Object.create_null_fixed ()))) in
  let back_index_per_area = Array.init (width / area_width + 1) (fun i -> Array.init (height / area_height + 1) (fun j -> 0)) in
  let tile_index_per_area = Array.init (width / area_width + 1) (fun i -> Array.init (height / area_height + 1) (fun j -> 0)) in
  for i = 0 to ((Array.length backgrounds) - 1) do
    let infx = ((Background.get_x backgrounds.(i)) / area_width) in
    let supx = (((Background.get_x backgrounds.(i)) + ((Background.get_w backgrounds.(i)) * (Background.get_zoom backgrounds.(i)))) / area_width) in
    let infy = ((Background.get_y backgrounds.(i)) / area_height) in
    let supy = (((Background.get_y backgrounds.(i)) + ((Background.get_h backgrounds.(i)) * (Background.get_zoom backgrounds.(i)))) / area_height) in
    for j = infx to (min supx (width / area_width)) do
      for k = infy to (min supy (height / area_height)) do
	back_a.(j).(k).(back_index_per_area.(j).(k)) <- backgrounds.(i);
	back_index_per_area.(j).(k) <- back_index_per_area.(j).(k) + 1;
      done;
    done;
  done;
  for i = 0 to ((Array.length tiles) - 1) do
    let infx = ((int_of_float (Object.get_positionX (Object.fixed_with_constructor tiles.(i)))) / area_width) in
    let supx = (((int_of_float (Object.get_positionX (Object.fixed_with_constructor tiles.(i)))) + ((Object.get_width (Object.fixed_with_constructor tiles.(i))) * (Object.get_zoom (Object.fixed_with_constructor tiles.(i))))) / area_width) in
    let infy = ((int_of_float (Object.get_positionY (Object.fixed_with_constructor tiles.(i)))) / area_height) in
    let supy = (((int_of_float (Object.get_positionY (Object.fixed_with_constructor tiles.(i)))) + ((Object.get_height (Object.fixed_with_constructor tiles.(i))) * (Object.get_zoom (Object.fixed_with_constructor tiles.(i))))) / area_height) in
    for j = infx to (min supx (width / area_width)) do
      for k = infy to (min supy (height / area_height)) do
	tile_a.(j).(k).(tile_index_per_area.(j).(k)) <- tiles.(i);
	tile_index_per_area.(j).(k) <- tile_index_per_area.(j).(k) + 1;
      done;
    done;
  done;
  {characters; enemies; monsters; decoration; tiles; traps; endlevels; backgrounds; nb_characters = ref (Array.length characters); nb_enemies = ref (Array.length enemies); nb_monsters = ref (Array.length monsters); nb_decoration = ref (Array.length decoration); nb_tiles = ref(Array.length tiles); nb_traps = ref (Array.length traps); width; height; cam = ref to_cam; background_areas = back_a; tile_areas = tile_a; end_time = Tsdl.Sdl.get_ticks (); ended = false; friendly_bullets = Array.init 20 (fun i -> (Bullet.create_null_bullet ())); enemy_bullets = Array.init 20 (fun i -> (Bullet.create_null_bullet ()))}
;;

let add_friendly_bullet s b m a =
  try
    for i = 0 to ((Array.length s.friendly_bullets) - 1) do
      if (Bullet.get_x s.friendly_bullets.(i)) < 0.0 then begin
	if m && a then Network.set_player_fire 1;
	s.friendly_bullets.(i) <- b;
	raise Exit;
      end;
    done;
  with
  |Exit -> ();;

let add_enemy_bullet s b =
  try
    for i = 0 to ((Array.length s.enemy_bullets) - 1) do
      if (Bullet.get_x s.enemy_bullets.(i)) < 0.0 then begin
	s.enemy_bullets.(i) <- b;
	raise Exit;
      end;
    done;
  with
  |Exit -> ();;

let get_friendly_bullets s = s.friendly_bullets;;

let get_enemy_bullets s = s.enemy_bullets;;

let get_characters s =
  s.characters
;;

let nb_characters s =
  !(s.nb_characters)
;;

let get_enemies s =
  s.enemies
;;

let nb_enemies s =
  !(s.nb_enemies)
;;

let get_monsters s =
  s.monsters
;;

let nb_monsters s =
  !(s.nb_monsters)
;;

let get_decoration s =
  s.decoration
;;

let nb_decoration s =
  !(s.nb_decoration)
;;

let get_tiles s =
  s.tiles
;;

let nb_tiles s =
  !(s.nb_tiles)
;;

let get_traps s =
  s.traps
;;

let nb_traps s =
  !(s.nb_traps)
;;

let get_endlevels s =
  s.endlevels;;

let get_backgrounds s =
  s.backgrounds;;

let get_camera s =
  !(s.cam)
;;

let get_width s =
  s.width
;;

let get_height s =
  s.height
;;

let add_movable e a id =
  a.(!id) <- e;
  id := (!id+1)
;;

let add_fixed e a id =
  a.(!id) <- e;
  id := (!id+1)
;;

let change_camera cam t =
  t.cam := cam
;;

exception Not_found;;
exception Found of int;;

let search_movable e a id =
  for i=0 to (!id)-1 do
    if (Object.compare_movable e a.(i)) then raise (Found(i))
  done;
;;

let search_fixed e a id =
  for i=0 to (!id)-1 do
    if (Object.compare_fixed e a.(i)) then raise (Found(i))
  done;
;;

let remove_movable e a id =
  try
    search_movable e a id
  with Found(tmp) ->
    for i=tmp to (!id)-2 do
      a.(i) <- a.(i+1)
    done;
    id := (!id) - 1
;;

let remove_fixed e a id =
  try
    search_fixed e a id
  with Found(tmp) ->
    for i=tmp to (!id)-2 do
      a.(i) <- a.(i+1)
    done;
    id := (!id) - 1
;;

let remove_character e t =
  remove_movable e t.characters t.nb_characters
;;

let remove_enemy e t =
  remove_movable e t.enemies t.nb_enemies
;;

let remove_monster e t =
  remove_movable e t.monsters t.nb_monsters
;;

let remove_decoration e t =
  remove_fixed e t.decoration t.nb_decoration
;;

let remove_tile e t =
  remove_fixed e t.tiles t.nb_tiles
;;

let remove_trap e t =
  remove_fixed e t.traps t.nb_traps
;;

let set_textures s r =
  (*if (Array.length s.backgrounds) > 0 then Object_texture.set_texture_from_bmp (Background.get_texture s.backgrounds.(0)) r;
  for i = 1 to ((Array.length s.backgrounds) - 1) do
    Background.set_texture s.backgrounds.(i) (Background.get_texture s.backgrounds.(0));
    done;*)
  Background.set_texture r;
  for i = 0 to ((Array.length s.characters) - 1) do
    Object_texture.set_texture_from_png (Object.get_texture (Object.movable_with_constructor s.characters.(i))) r;
  done;
  for i = 0 to ((Array.length s.enemies) - 1) do
    Object_texture.set_texture_from_png (Object.get_texture (Object.movable_with_constructor s.enemies.(i))) r;
  done;
  for i = 0 to ((Array.length s.monsters) - 1) do
    Object_texture.set_texture_from_png (Object.get_texture (Object.movable_with_constructor s.monsters.(i))) r;
  done;
  (*for i = 0 to ((Array.length s.decoration) - 1) do
    Object_texture.set_texture_from_png (Object.get_texture (Object.fixed_with_constructor s.decoration.(i))) r;
    Object.store_textures_fixed s.decoration.(i) r;
    done;*)
(*Object_texture.set_texture_from_png (Object.get_texture (Object.fixed_with_constructor s.tiles.(0))) r;*)
  for i = 0 to ((Array.length s.tiles) - 1) do
    Object.store_textures_fixed s.tiles.(i) r;
  done;
  (*for i = 0 to ((Array.length s.traps) - 1) do
    Object_texture.set_texture_from_png (Object.get_texture (Object.fixed_with_constructor s.traps.(i))) r;
    Object.store_textures_fixed s.traps.(i) r;
    done;*)
  (*for i = 0 to ((Array.length s.endlevels) - 1) do
    Object_texture.set_texture_from_png (Object.get_texture (Object.fixed_with_constructor s.endlevels.(i))) r;
    Object.store_textures_fixed s.endlevels.(i) r;
    done;;*);;

let get_backgrounds_in_areas s r =
  let table = Hashtbl.create 500 in
  let infx = (Tsdl.Sdl.Rect.x r) / area_width in
  let supx = ((Tsdl.Sdl.Rect.x r) + (Tsdl.Sdl.Rect.w r)) / area_width in
  let infy = (Tsdl.Sdl.Rect.y r) / area_height in
  let supy = ((Tsdl.Sdl.Rect.y r) + (Tsdl.Sdl.Rect.h r)) / area_height in
  for i = infx to (min supx (s.width / area_width)) do
    for j = infy to (min supy (s.height / area_height)) do
      for k = 0 to ((Array.length s.background_areas.(i).(j)) - 1) do
	Hashtbl.replace table s.background_areas.(i).(j).(k) s.background_areas.(i).(j).(k);
      done;
    done;
  done;
  let elements = Array.make (Hashtbl.length table) (Background.create_null_background ()) in
  let index = ref 0 in
  Hashtbl.iter (fun k v -> elements.(!index) <- v; index := !index + 1) table;
  for i = 0 to ((Array.length elements) - 1) do
    let maximum = ref (Background.get_id elements.(i)) in
    for j = i + 1 to ((Array.length elements) - 1) do
      if (Background.get_id elements.(j)) < (!maximum) then begin
	maximum := (Background.get_id elements.(j));
	let tmp = elements.(j) in
	elements.(j) <- elements.(i);
	elements.(i) <- tmp;
      end;
    done;
  done;
  elements;;

let get_tiles_in_areas s r =
  let table = Hashtbl.create 500 in
  let infx = (Tsdl.Sdl.Rect.x r) / area_width in
  let supx = ((Tsdl.Sdl.Rect.x r) + (Tsdl.Sdl.Rect.w r)) / area_width in
  let infy = (Tsdl.Sdl.Rect.y r) / area_height in
  let supy = ((Tsdl.Sdl.Rect.y r) + (Tsdl.Sdl.Rect.h r)) / area_height in
  for i = infx to (min supx (s.width / area_width)) do
    for j = infy to (min supy (s.height / area_height)) do
      for k = 0 to ((Array.length s.tile_areas.(i).(j)) - 1) do
	Hashtbl.replace table s.tile_areas.(i).(j).(k) s.tile_areas.(i).(j).(k);
      done;
    done;
  done;
  let elements = Array.make (Hashtbl.length table) (Object.create_null_fixed ()) in
  let index = ref 0 in
  Hashtbl.iter (fun k v -> elements.(!index) <- v; index := !index + 1) table;
  for i = 0 to ((Array.length elements) - 1) do
    let maximum = ref (Object.get_id (Object.fixed_with_constructor elements.(i))) in
    for j = i + 1 to ((Array.length elements) - 1) do
      if (Object.get_id (Object.fixed_with_constructor elements.(j))) < (!maximum) then begin
	maximum := (Object.get_id (Object.fixed_with_constructor elements.(j)));
	let tmp = elements.(j) in
	elements.(j) <- elements.(i);
	elements.(i) <- tmp;
      end;
    done;
  done;
  elements;;

let update s m dir =
  let res = ref continue in
  (* checking collisions below *)
  let check_collisions_with_gravity () =
    let collide = ref false in
    let tiles_in_area = get_tiles_in_areas s (Object.to_box (Object.movable_with_constructor s.characters.(0))) in (* tiles in areas where main character is *)
    for i = 0 to ((Array.length tiles_in_area) - 1) do
      if not (String.equal (Object.get_subtype (Object.fixed_with_constructor tiles_in_area.(i))) "LASER") then begin
	let rect = Tsdl.Sdl.intersect_rect (Object.to_box (Object.movable_with_constructor s.characters.(0))) (Object.to_box (Object.fixed_with_constructor tiles_in_area.(i))) in
	match rect with
	|None -> () (* no collision case *)
	|Some(x) ->
	   let bottom = ref false in
	   if ((Tsdl.Sdl.Rect.y x) + (Tsdl.Sdl.Rect.h x)) = ((Tsdl.Sdl.Rect.y (Object.to_box (Object.movable_with_constructor s.characters.(0)))) + (Tsdl.Sdl.Rect.h (Object.to_box (Object.movable_with_constructor s.characters.(0))))) then bottom := true;
	   if (!bottom) then begin
	     if ((String.equal (Object.get_subtype (Object.fixed_with_constructor tiles_in_area.(i))) "ENDLEVEL") && ((Object.get_status (Object.fixed_with_constructor tiles_in_area.(i))) = 1)) then begin
	       Object.change_status tiles_in_area.(i);
	       Object.set_frame (Object.fixed_with_constructor tiles_in_area.(i)) 0;
	       Object.set_timer (Object.fixed_with_constructor tiles_in_area.(i));
	       s.ended <- true;
	       s.end_time <- Tsdl.Sdl.get_ticks ();
	     end;
	     collide := true;
	     s.characters.(0) <- (Object.set_positionY s.characters.(0) (float_of_int ((Tsdl.Sdl.Rect.y x) - (Tsdl.Sdl.Rect.h (Object.to_box (Object.movable_with_constructor s.characters.(0)))))));
	     s.characters.(0) <- Object.enable_jump s.characters.(0);
	   end;
      end;
    done;
    if (not (!collide) && (Object.get_jump (Object.movable_with_constructor s.characters.(0))) <= 0.0) then s.characters.(0) <- Object.disable_jump s.characters.(0)
  in
  let check_collisions_with_move () =
    let tiles_in_area = get_tiles_in_areas s (Object.to_box (Object.movable_with_constructor s.characters.(0))) in (* tiles in areas where main character is *)
    for i = 0 to ((Array.length tiles_in_area) - 1) do
      let rect = Tsdl.Sdl.intersect_rect (Object.to_box (Object.movable_with_constructor s.characters.(0))) (Object.to_box (Object.fixed_with_constructor tiles_in_area.(i))) in
      match rect with
      |None -> () (* no collision case *)
      |Some(x) ->
	 let right = ref false in
	 let left = ref false in
	 let isLaser = ref false in
	 if (Tsdl.Sdl.Rect.x x) = (Tsdl.Sdl.Rect.x (Object.to_box (Object.movable_with_constructor s.characters.(0)))) then left := true;
	 if ((Tsdl.Sdl.Rect.x x) + (Tsdl.Sdl.Rect.w x)) = ((Tsdl.Sdl.Rect.x (Object.to_box (Object.movable_with_constructor s.characters.(0)))) + (Tsdl.Sdl.Rect.w (Object.to_box (Object.movable_with_constructor s.characters.(0))))) then right := true;
	 if ((String.equal (Object.get_subtype (Object.fixed_with_constructor tiles_in_area.(i))) "LASER") && ((!right) || (!left))) then begin
	   if ((Object.get_status (Object.fixed_with_constructor tiles_in_area.(i))) = 1) then s.characters.(0) <- (Object.get_damage s.characters.(0) Settings.laser_damages);
	   isLaser := true;
	 end;
	 if not (!isLaser) then begin
	   if (!left) then s.characters.(0) <- (Object.set_positionX s.characters.(0) (float_of_int ((Tsdl.Sdl.Rect.x x) + (Tsdl.Sdl.Rect.w x))));
	   if (!right) then s.characters.(0) <- (Object.set_positionX s.characters.(0) ((Object.get_positionX (Object.movable_with_constructor s.characters.(0))) -. (float_of_int (Tsdl.Sdl.Rect.w x))));
	 end;
    done;
  in
  let check_collisions_with_jump () =
    let tiles_in_area = get_tiles_in_areas s (Object.to_box (Object.movable_with_constructor s.characters.(0))) in (* tiles in areas where main character is *)
    for i = 0 to ((Array.length tiles_in_area) - 1) do
      if not (String.equal (Object.get_subtype (Object.fixed_with_constructor tiles_in_area.(i))) "LASER") then begin
	let rect = Tsdl.Sdl.intersect_rect (Object.to_box (Object.movable_with_constructor s.characters.(0))) (Object.to_box (Object.fixed_with_constructor tiles_in_area.(i))) in
	match rect with
	|None -> () (* no collision case *)
	|Some(x) ->
	   let top = ref false in
	   if (Tsdl.Sdl.Rect.y x) = ((Tsdl.Sdl.Rect.y (Object.to_box (Object.movable_with_constructor s.characters.(0))))) then top := true;
	   if (!top) then begin
	     s.characters.(0) <- (Object.set_positionY s.characters.(0) (float_of_int ((Tsdl.Sdl.Rect.y x) + (Tsdl.Sdl.Rect.h x))));
	     s.characters.(0) <- Object.disable_jump s.characters.(0);
	   end;
      end;
    done;
  in
  if not (s.ended) then begin
    s.characters.(0) <- (Object.applyGravity (s.characters.(0)));
    s.characters.(0) <- (Object.move_vertically s.characters.(0) (1.0) s.width s.height);
    if (Object.get_speedY (Object.movable_with_constructor s.characters.(0))) > 0.0 then check_collisions_with_gravity () else check_collisions_with_jump ();
    s.characters.(0) <- (Object.apply_friction (s.characters.(0))); (* apply friction at the end of turn to avoid unlimited gravity *)
    s.characters.(0) <- (Object.move_horizontally s.characters.(0) (1.0) s.width s.height);
    check_collisions_with_move ();
  end;
  if (s.ended && ((Int32.to_int (Int32.sub (Tsdl.Sdl.get_ticks ()) s.end_time)) >= Settings.end_animation_time)) then res := win;
  let timer_lasers = Object.get_timer_lasers () in
  let current_time = Tsdl.Sdl.get_ticks () in
  let diff = Int32.to_int (Int32.sub current_time timer_lasers) in
  let parity = (diff / Settings.laser_state_delay) mod 2 in
  for i = 0 to ((Array.length s.traps) - 1) do
    Object.set_status s.traps.(i) parity;
  done;
  if m then begin
    let st = if (Object.get_jump (Object.movable_with_constructor s.characters.(0))) > 0.0 then 2 else if Object.animation_stop (Object.movable_with_constructor s.characters.(0)) then 0 else 1 in
    let fr = Object.get_frame (Object.movable_with_constructor s.characters.(0)) in
    Network.set_player_datas (int_of_float (Object.get_positionX (Object.movable_with_constructor s.characters.(0)))) (int_of_float (Object.get_positionY (Object.movable_with_constructor s.characters.(0)))) fr st (Object.get_direction (Object.movable_with_constructor s.characters.(0)));
    Network.set_player_life (Object.get_life s.characters.(0));
    let last_damages_time = Object.get_last_damages_time (Object.movable_with_constructor s.characters.(0)) in
    let current_time = Tsdl.Sdl.get_ticks () in
    let parity = ((Int32.to_int (Int32.sub current_time last_damages_time)) / Settings.character_shield_delay_frame) mod 2 in
    if (parity = 1 || ((Int32.to_int (Int32.sub current_time last_damages_time)) > Settings.character_shield_time)) then Network.set_player_display 1 else Network.set_player_display 0;
    let (x, y, frame, state, direction, latency) = Network.get_datas () in
    let life = Network.get_life () in
    let display = Network.get_display () in
    let fire = Network.get_fire () in
    if fire = 1 then add_enemy_bullet s (Bullet.create (if direction < 0 then (float_of_int x) -. 20.0 else (float_of_int x) +. 55.0) ((float_of_int y) +. 40.0) direction);
    udp_packet.positionX <- x;
    udp_packet.positionY <- y;
    udp_packet.frame <- frame;
    udp_packet.state <- state;
    udp_packet.direction <- direction;
    udp_packet.latency <- latency;
    udp_packet.life <- life;
    udp_packet.display <- display;
    s.enemies.(0) <- (Object.set_positionX s.enemies.(0) (float_of_int x));
    s.enemies.(0) <- (Object.set_positionY s.enemies.(0) (float_of_int y));
    s.enemies.(0) <- (Object.set_direction s.enemies.(0) direction);
    s.enemies.(0) <- (Object.set_life s.enemies.(0) life);
    if state < 2 then begin
      s.enemies.(0) <- Object.set_jump s.enemies.(0) 0.0;
      Object.set_frame (Object.movable_with_constructor s.enemies.(0)) frame;
    end
    else begin
      s.enemies.(0) <- Object.set_jump s.enemies.(0) 1.0;
      Object.set_frame (Object.movable_with_constructor s.enemies.(0)) frame;
    end;
  end;
  for i = 0 to ((Array.length s.friendly_bullets) - 1) do
    if ((Bullet.get_total_dist s.friendly_bullets.(i)) > Bullet.max_travel_dist || (Bullet.get_collided s.friendly_bullets.(i))) || (Bullet.get_x s.friendly_bullets.(i)) < 0.0 then s.friendly_bullets.(i) <- (Bullet.create_null_bullet ()) else begin
      s.friendly_bullets.(i) <- Bullet.move s.friendly_bullets.(i);
      let tiles_in_area = get_tiles_in_areas s (Bullet.to_box s.friendly_bullets.(i)) in (* tiles in areas where main bullet is *)
      for i = 0 to ((Array.length tiles_in_area) - 1) do
	let rect = Tsdl.Sdl.intersect_rect (Bullet.to_box s.friendly_bullets.(i)) (Object.to_box (Object.fixed_with_constructor tiles_in_area.(i))) in
	match rect with
	|None -> () (* no collision case *)
	|Some(x) ->
	   if not (String.equal (Object.get_subtype (Object.fixed_with_constructor tiles_in_area.(i))) "LASER") then s.friendly_bullets.(i) <- Bullet.collide s.friendly_bullets.(i);
      done;
    end;
  done;
  for i = 0 to ((Array.length s.enemy_bullets) - 1) do
    if ((Bullet.get_total_dist s.enemy_bullets.(i)) > Bullet.max_travel_dist || (Bullet.get_collided s.enemy_bullets.(i))) || (Bullet.get_x s.enemy_bullets.(i)) < 0.0 then s.enemy_bullets.(i) <- (Bullet.create_null_bullet ()) else begin
      s.enemy_bullets.(i) <- Bullet.move s.enemy_bullets.(i);
      let tiles_in_area = get_tiles_in_areas s (Bullet.to_box s.enemy_bullets.(i)) in (* tiles in areas where main bullet is *)
      for i = 0 to ((Array.length tiles_in_area) - 1) do
	let rect = Tsdl.Sdl.intersect_rect (Bullet.to_box s.enemy_bullets.(i)) (Object.to_box (Object.fixed_with_constructor tiles_in_area.(i))) in
	match rect with
	|None -> () (* no collision case *)
	|Some(x) ->
	   if not (String.equal (Object.get_subtype (Object.fixed_with_constructor tiles_in_area.(i))) "LASER") then s.enemy_bullets.(i) <- Bullet.collide s.enemy_bullets.(i);
      done;
      let rect = Tsdl.Sdl.intersect_rect (Object.to_box (Object.movable_with_constructor s.characters.(0))) (Bullet.to_box s.enemy_bullets.(i)) in
      match rect with
      |None -> () (* no collision case *)
      |Some(x) ->
	 s.enemy_bullets.(i) <- Bullet.collide s.enemy_bullets.(i);
	s.characters.(0) <- (Object.get_damage s.characters.(0) Settings.fire_damages);
    end;
  done;
  (* moving camera to follow main character *)
  s.cam := Camera.move_camera (!(s.cam)) (Object.get_positionX (Object.movable_with_constructor s.characters.(0))) (Object.get_positionY (Object.movable_with_constructor s.characters.(0))) s.width s.height (Object.get_width (Object.movable_with_constructor s.characters.(0))) (Object.get_height (Object.movable_with_constructor s.characters.(0)));
  (!res);;

let free s =
  for i = 0 to ((Array.length s.characters) - 1) do
    Object.free (Object.movable_with_constructor s.characters.(i));
  done;
  for i = 0 to ((Array.length s.enemies) - 1) do
    Object.free (Object.movable_with_constructor s.enemies.(i));
  done;
  for i = 0 to ((Array.length s.monsters) - 1) do
    Object.free (Object.movable_with_constructor s.monsters.(i));
  done;
  for i = 0 to ((Array.length s.tiles) - 1) do
    Object.free (Object.fixed_with_constructor s.tiles.(i));
  done;
  Object.free_global_var ();
  Background.free ();;

