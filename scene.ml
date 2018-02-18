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

(*let remove_movable e a id =
  try
    let tmp = search_movable e a id in
    for i=tmp to (!id)-2 do
      a.(i) <- a.(i+1)
    done;
    id := (!id) - 1
  with Not_found -> ()
;;*)

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

(*let display x y w h =
  for i=0 to (!id_elements)-1 do
    Object.display elements.(i) x y w h
  done;
  for i=0 to (!id_enemies)-1 do
    Object.display enemies.(i) x y w h
  done;
  for i=0 to (!id_players)-1 do
    Object.display players.(i) x y w h
  done;
  ;;*)

let display x y w h =
  ()
;;

let play () =
  Printf.printf "Do you want to play with me?"
;;
