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

let to_box c = Tsdl.Sdl.Rect.create c.x c.y c.w c.h;;

let modify_size cam height width =
  {cam with h = height; w = width}
;;

(*(* x y : position of the player on the level
wl hl : width and height of the level
wp hp : width and height of the player *)
let move_camera t x y wl hl wp hp =
  let cx = (x + wp/2) - (t.w/2) in
  let cy = (y + hp/2) - (t.h/2) in
  let x' = if cx < 0 then 0 else if cx > (wl-t.w) then wl-t.w else cx in
  let y' = if cy < 0 then 0 else if cy > (hl-t.h) then hl-t.h else cy in
  {t with x = x'; y = y'}
;;*)

(* x y : position of the player on the level
wl hl : width and height of the level
wp hp : width and height of the player *)
let move_camera t x y wl hl wp hp =
  let cx = ((int_of_float x) + wp/2) - (t.w/2) in
  let cy = ((int_of_float y) + hp/2) - (t.h/2) in
  let xx = if cx < 0 then 0 else if cx > (wl-t.w) then wl-t.w else cx in
  let yy = if cy < 0 then 0 else if cy > (hl-t.h) then hl-t.h else cy in
  {t with x = xx; y = yy}
;;
