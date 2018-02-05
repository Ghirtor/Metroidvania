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

type t = Movable of movable | Fixed of fixed;;

let generate_id () =
  let id = ref (-1) in
  fun () -> id := !id + 1; !id;;

let next_id = generate_id ();;

let move m f = m;;

let applyGravity m = m;;

let change_direction m = let t = m.mass in {id = m.id; positionX = (-1 * m.positionX); positionY = m.positionY; speedX = m.speedX; speedY = m.speedY; width = m.width; height = m.height; mass = t; life = m.life; max_life = m.max_life};;

let jump m = m;;

let collide t1 t2 = 1.0;;

let get_damage m d = {m with life = (Pervasives.max (m.life - d) 0)};;

let health m h = {m with life = (Pervasives.min (m.life + h) m.max_life)};;

let compare t1 t2 = t1 == t2;;

let create_movable x y vx vy w h m l ml = {id = next_id (); positionX = x; positionY = y; speedX = vx; speedY = vy; width = w; height = h; mass = m; life = l; max_life = ml};;

let create_fixed x y w h = {id = next_id (); positionX = x; positionY = y; speedX = 0; speedY = 0; width = w; height = h};;

let get_id t =
  match t with
    Movable(x) -> x.id
  |Fixed(x) -> x.id;;

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
