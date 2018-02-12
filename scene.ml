

let id_players = ref 0;;
let id_enemies = ref 0;;
let id_elements = ref 0;;

let width () =
(* gives the width *)
  0
;;

let height () =
(* gives the height *)
  0
;;

let create_movables n =
  Array.make n (Object.create_null_movable ())
;;

let players = create_movables 1;;

let create_fixed n =
  Array.make n (Object.create_null_fixed ())
;;

let enemies = create_movables 10;;
let elements = create_fixed 15;;

let add_movable e a id =
  a.(!id) <- e;
  id := (!id+1)
;;

let add_fixed e a id =
  a.(!id) <- e;
  id := (!id+1)
;;

exception Not_found;;

let search_movable e a =
  for i=0 to (!id)-1 do
    if (Object.compare_movable e a.(i)) = 0 then i
  done;
  raise Not_found
;;

let search_fixed e a =
  for i=0 to (!id)-1 do
    if (Object.compare_fixed e a.(i)) = 0 then i
  done;
  raise Not_found
;;

let remove_movable e a id =
  try
    let tmp = search_movable e a in
    for i=tmp to (!id)-2 do
      a.(i) <- a.(i+1)
    done;
    id := (!id) - 1
  with Not_found -> ()
;;

let remove_fixed e a id =
  try
    let tmp = search_fixed e a in
    for i=tmp to (!id)-2 do
      a.(i) <- a.(i+1)
    done;
    id := (!id) - 1
  with Not_found -> ()
;;

let display x y w h =
  for i=0 to (!id_elements)-1 do
    Object.display elements.(i) x y w h
  done;
  for i=0 to (!id_enemies)-1 do
    Object.display enemies.(i) x y w h
  done;
  for i=0 to (!id_players)-1 do
    Object.display players.(i) x y w h
  done;
;;

let play () =
  Printf.printf "Do you want to play with me?"
;;
