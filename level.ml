open Soup;;

let multi = ref false;;
let scene_title = ref "";;
let scene_width = ref 0;;
let scene_height = ref 0;;
let characters = ref [|Object.create_null_movable ()|];;
let enemies = ref [|Object.create_null_movable ()|];;
let monsters = ref [|Object.create_null_movable ()|];;
let decorations = ref [|Object.create_null_fixed ()|];;
let tiles = ref [|Object.create_null_fixed ()|];;
let traps = ref [|Object.create_null_fixed ()|];;
let endlevels = ref [|Object.create_null_fixed ()|];;
let backgrounds = ref [|Background.create_null_background ()|];;
let ind_characters = ref 0;;
let ind_enemies = ref 0;;
let ind_monsters = ref 0;;
let ind_decorations = ref 0;;
let ind_tiles = ref 0;;
let ind_traps = ref 0;;
let ind_endlevels = ref 0;;
let ind_background = ref 0;;
let nb_decorations = ref 0;;
let nb_tiles = ref 0;;
let nb_traps = ref 0;;
let nb_endlevels = ref 0;;

let activate_multi b = multi := b;;

let characterIter =
  ind_characters := 0;
  let x = ref 0 in
  let y = ref 0 in
  let w = ref 0 in
  let h = ref 0 in
  let zoom = ref 0 in
  let path = ref "" in
  let j = ref 0 in
  let f = fun e ->
    if !j = 0 then x := (int_of_string e)
    else if !j = 1 then y := (int_of_string e)
    else if !j = 4 then w := (int_of_string e)
    else if !j = 5 then h := (int_of_string e)
    else if !j = 6 then zoom := (int_of_string e)
    else if !j = 7 then begin
      path := String.sub e 1 ((String.length e) - 1);
      characters := (Array.make 1 (Object.create_null_movable ()));
      !characters.(!ind_characters) <- Object.create_movable (float_of_int (!x)) (float_of_int (!y)) 0.0 0.0 1 100 100 (!path) (!zoom) (!w) (!h);
      ind_characters := !ind_characters + 1;
    end;
    j := !j + 1;
  in
  fun span -> (trimmed_texts span |> List.iter f);;

let tileIter =
  let t = ref "" in
  let x = ref 0 in
  let y = ref 0 in
  let srcX = ref 0 in
  let srcY = ref 0 in
  let w = ref 0 in
  let h = ref 0 in
  let zoom = ref 0 in
  let path = ref "" in
  let j = ref 0 in
  let f = fun e ->
    if !j = 0 then t := e
    else if !j = 1 then x := (int_of_string e)
    else if !j = 2 then y := (int_of_string e)
    else if !j = 3 then srcX := (int_of_string e)
    else if !j = 4 then srcY := (int_of_string e)
    else if !j = 5 then w := (int_of_string e)
    else if !j = 6 then h := (int_of_string e)
    else if !j = 7 then zoom := (int_of_string e)
    else if !j = 8 then begin
      j := -2;
      path := String.sub e 1 ((String.length e) - 1);
      if !t = "DECORATION" then begin
	!decorations.(!ind_decorations) <- Object.create_decoration (float_of_int (!x)) (float_of_int (!y)) (!w) (!h) (!path) (!srcX) (!srcY) (!zoom);
	ind_decorations := !ind_decorations + 1;
      end
      else if !t = "LASER" then begin
	!traps.(!ind_traps) <- Object.create_laser (float_of_int (!x)) (float_of_int (!y)) (!w) (!h) (!path) (!srcX) (!srcY) (!zoom);
	ind_traps := !ind_traps + 1;
      end
      else if !t = "ENDLEVEL" then begin
	!endlevels.(!ind_endlevels) <- Object.create_endlevel (float_of_int (!x)) (float_of_int (!y)) (!w) (!h) (!path) (!srcX) (!srcY) (!zoom);
	ind_endlevels := !ind_endlevels + 1;
      end
      else begin
	!tiles.(!ind_tiles) <- Object.create_tile (float_of_int (!x)) (float_of_int (!y)) (!w) (!h) (!path) (!srcX) (!srcY) (!zoom);
	ind_tiles := !ind_tiles + 1;
      end;
    end;
    j := !j + 1;
  in
  fun span -> (trimmed_texts span |> List.iter f);;

let backgroundIter =
  ind_background := 0;
  let zoom = ref 0 in
  let w = ref 0 in
  let h = ref 0 in
  let j = ref 0 in
  let f = fun e ->
    if !j = 0 then w := (int_of_string e)
    else if !j = 1 then h := (int_of_string e)
    else if !j = 2 then zoom := (int_of_string e)
    else if !j = 3 then begin
      let texture = Object_texture.create (String.sub e 1 ((String.length e) - 1)) in
      backgrounds := (Array.make ((((!scene_height) / ((!h) * (!zoom)))+1) * (((!scene_width) / ((!w) * (!zoom)))+1)) (Background.create_null_background ()));
      for y = 0 to ((!scene_height) / ((!h) * (!zoom))) do
	for x = 0 to ((!scene_width) / ((!w) * (!zoom))) do
	  !backgrounds.(!ind_background) <- Background.create (x*((!w)*(!zoom))) (y*((!h)*(!zoom))) (!w) (!h) (!zoom) (String.sub e 1 ((String.length e) - 1));
	  ind_background := !ind_background + 1;
	done;
      done;
    end;
    j := !j + 1;
  in
  fun span -> (trimmed_texts span |> List.iter f);;

let sceneIter =
  let j = ref 0 in
  let f = fun e ->
    if !j = 0 then scene_width := (int_of_string e)
    else if !j = 1 then scene_height := (int_of_string e);
    j := !j + 1;
  in
  fun span -> (trimmed_texts span |> List.iter f);;

let set_title s = scene_title := s;;

let parse s m =
  activate_multi m;
  characters := [||];
  enemies := [||];
  monsters := [||];
  decorations := [||];
  tiles := [||];
  traps := [||];
  endlevels := [||];
  backgrounds := [||];
  ind_decorations := 0;
  ind_tiles := 0;
  ind_traps := 0;
  ind_endlevels := 0;
  nb_decorations := 0;
  nb_tiles := 0;
  nb_traps := 0;
  nb_endlevels := 0;
  let soup = read_file s |> parse in
  soup $ "title" |> R.leaf_text |> set_title;
  let body = soup $ "body" in
  let elements = body $$ "div" in
  iter (fun hd ->
    if (List.nth (classes hd) 0) = "tile" then begin
      let span = hd $$ "span" in
      iter (fun hd ->
	let f = fun e ->
	  if e = "TILE" then nb_tiles := !nb_tiles + 1
	  else if e = "LASER" then nb_traps := !nb_traps + 1
	  else if e = "DECORATION" then nb_decorations := !nb_decorations +1
	  else if e = "ENDLEVEL" then nb_endlevels := !nb_endlevels + 1
	in
	trimmed_texts hd |> List.iter f) span;
    end) elements;
  tiles := (Array.make (!nb_tiles) (Object.create_null_fixed ()));
  decorations := (Array.make (!nb_decorations) (Object.create_null_fixed ()));
  traps := (Array.make (!nb_traps) (Object.create_null_fixed ()));
  endlevels := (Array.make (!nb_endlevels) (Object.create_null_fixed ()));
  body $$ "div" |> iter (fun div ->
    let c = 0 |> List.nth (classes div) in
    if c = "scene" then div $$ "span" |> iter sceneIter
    else if c = "background" then div $$ "span" |> iter backgroundIter
    else if c = "character" then div $$ "span" |> iter characterIter
    else if c = "tile" then begin
      div $$ "span" |> iter tileIter;
    end;
  );
  ((!characters),(!enemies),(!monsters),(!decorations),(Array.append (Array.append (Array.append (!tiles) (!endlevels)) (!traps)) (!decorations)),(!traps),(!endlevels),(!backgrounds),(!scene_width),(!scene_height));;
