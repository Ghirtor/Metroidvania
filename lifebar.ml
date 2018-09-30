type t = {
    max_life : int;
    life : int;
    x : int;
    y : int;
    color : Tsdl.Sdl.color;
    max_height : int;
    max_width : int;
  };;

let get_max bar =
  bar.max_life
;;

let get_life bar =
  bar.life
;;

let get_xy bar =
  (bar.x, bar.y)
;;

let get_color bar =
  bar.color
;;

let get_max_height bar =
  bar.max_height
;;

let get_max_width bar =
  bar.max_width
;;

exception TooMuchLife;;

let life hero maximum =
  try
    let hero_life = (Pervasives.max 0 (Object.get_life hero)) in
    let () = if hero_life > maximum then raise TooMuchLife in
    hero_life
  with TooMuchLife ->
    maximum
;;

let create hero cam color =
  let max_life = Object.get_max_life hero in
  let hero_life =  (life hero max_life) in
  let x = (Camera.get_x cam) in
  let y = (Camera.get_y cam) in
  let h = Camera.get_h cam in
  let w = Camera.get_w cam in
  {max_life; life = hero_life; x; y; color; max_height = (h/30); max_width = (w/4)}
;;

let modify_life bar hero =
  let new_life = (life hero (get_max bar)) in
  {bar with life = new_life}
;;

let modify_location bar cam =
  let x' = (Camera.get_x cam) in
  let y' = (Camera.get_y cam) in
  {bar with x = x'; y = y'}
;;

let modify_color bar new_color =
  {bar with color = new_color}
;;