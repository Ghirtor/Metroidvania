type t = {x : int; y : int; h : int; w : int};;

let get_x c =
  c.x
;;

let get_y c =
  c.y
;;

let get_h c =
  c.h
;;

let get_w c =
  c.w
;;

let create_camera i j height width =
  {x = i; y = j; h = height; w = width}
;;

let modify_camera cam i j =
  {cam with x = i; y = j}
;;

let modify_size cam height width =
  {cam with h = height; w = width}
;;
