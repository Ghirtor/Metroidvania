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
    tile_areas : Object.fixed array array array
};;

let area_width = 100;;
let area_height = 100;;

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
  {characters; enemies; monsters; decoration; tiles; traps; endlevels; backgrounds; nb_characters = ref (Array.length characters); nb_enemies = ref (Array.length enemies); nb_monsters = ref (Array.length monsters); nb_decoration = ref (Array.length decoration); nb_tiles = ref(Array.length tiles); nb_traps = ref (Array.length traps); width; height; cam = ref to_cam; background_areas = back_a; tile_areas = tile_a}
;;

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
  for i = 0 to ((Array.length s.decoration) - 1) do
    Object_texture.set_texture_from_png (Object.get_texture (Object.fixed_with_constructor s.decoration.(i))) r;
    Object.store_textures_fixed s.decoration.(i) r;
  done;
  Object_texture.set_texture_from_png (Object.get_texture (Object.fixed_with_constructor s.tiles.(0))) r;
  for i = 0 to ((Array.length s.tiles) - 1) do
    Object.store_textures_fixed s.tiles.(i) r;
  done;
  for i = 0 to ((Array.length s.traps) - 1) do
    Object_texture.set_texture_from_png (Object.get_texture (Object.fixed_with_constructor s.traps.(i))) r;
    Object.store_textures_fixed s.traps.(i) r;
  done;;

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

let update s t =
  s.characters.(0) <- (Object.applyGravity (s.characters.(0)) t);
  s.characters.(0) <- (Object.move s.characters.(0) (1.0) s.width s.height);
  s.characters.(0) <- (Object.apply_friction (s.characters.(0)) t); (* apply friction at the end of turn to avoid unlimited gravity *)
  s.cam := Camera.move_camera (!(s.cam)) (Object.get_positionX (Object.movable_with_constructor s.characters.(0))) (Object.get_positionY (Object.movable_with_constructor s.characters.(0))) s.width s.height (Object.get_width (Object.movable_with_constructor s.characters.(0))) (Object.get_height (Object.movable_with_constructor s.characters.(0)));;
