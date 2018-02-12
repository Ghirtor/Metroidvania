type movable = {
  id : int;
  positionX : int;
  positionY : int;
  speedX : int;
  speedY : int;
  width : int;
  height : int;
  mass : int;
  life : int;
  max_life : int
};;

type fixed = {
  id : int;
  positionX : int;
  positionY : int;
  speedX : int;
  speedY : int;
  width : int;
  height : int
};;

type collision = {
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

let null_collision = {idA = -1; idB = -1; time = 9999.0; damagesA = -1; damagesB = -1};;

(* get the hitbox corresponding to the t object *)

let get_hitbox t =
  match t with
    Movable(x) -> {id = x.id; x = x.positionX; y = x.positionY; vx = x.speedX; vy = x.speedY; w = x.width; h = x.height; damages = 0}
  |Fixed(x) -> {id = x.id; x = x.positionX; y = x.positionY; vx = x.speedX; vy = x.speedY; w = x.width; h = x.height; damages = 0};;

(* functions for types t, movable and fixed  *)

let generate_id () =
  let id = ref (-1) in
  fun () -> id := !id + 1; !id;;

let next_id = generate_id ();;

let move m f = let t = m.mass in {id = m.id; positionX = int_of_float ((float_of_int m.positionX) +. (f *. (float_of_int  m.speedX))); positionY = int_of_float ((float_of_int m.positionY) +. (f *. (float_of_int  m.speedY))); speedX = m.speedX; speedY = m.speedY; width = m.width; height = m.height; mass = t; life = m.life; max_life = m.max_life};;

let applyGravity m = m;;

let change_direction m = let t = m.mass in {id = m.id; positionX = (-1 * m.positionX); positionY = m.positionY; speedX = m.speedX; speedY = m.speedY; width = m.width; height = m.height; mass = t; life = m.life; max_life = m.max_life};;

let jump m = m;;

let get_collision h1 h2 = null_collision;;

let collide t1 t2 = get_collision (get_hitbox t1) (get_hitbox t2);;

let get_damage m d = {m with life = (Pervasives.max (m.life - d) 0)};;

let health m h = {m with life = (Pervasives.min (m.life + h) m.max_life)};;

let create_movable x y vx vy w h m l ml = {id = next_id (); positionX = x; positionY = y; speedX = vx; speedY = vy; width = w; height = h; mass = m; life = l; max_life = ml};;

let create_fixed x y w h = {id = next_id (); positionX = x; positionY = y; speedX = 0; speedY = 0; width = w; height = h};;

let create_null_movable () = {id = -1; positionX = -1; positionY = -1; speedX = -1; speedY = -1; width = -1; height = -1; mass = -1; life = -1; max_life = -1};;

let create_null_fixed () = {id = -1; positionX = -1; positionY = -1; speedX = -1; speedY = -1; width = -1; height = -1};;

(* getters *)

let get_id t =
  match t with
    Movable(x) -> x.id
  |Fixed(x) -> x.id;;

let compare t1 t2 = (get_id t1) = (get_id t2);;

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

(* functions for collision type *)

let get_first_id c = c.idA;;

let get_second_id c = c.idB;;

let get_time c = c.time;;

let get_damagesA c = c.damagesA;;

let get_damagesB c = c.damagesB;;
