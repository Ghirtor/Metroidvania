external initialize : string -> string -> unit = "caml_init";;
external send : unit -> unit = "caml_send";;
external set_player_datas : int -> int -> int -> int -> int -> unit = "caml_set_player_datas";;
external set_player_level : int -> unit = "caml_set_player_level";;
external set_player_life : int -> unit = "caml_set_player_life";;
external set_player_display : int -> unit = "caml_set_player_display";;
external set_player_fire : int -> unit = "caml_set_player_fire";;
external get_datas : unit -> int * int * int * int * int * int = "caml_send_datas";;
external close : unit -> unit = "caml_close";;
external close_connection : unit -> unit = "caml_close_connection";;
external get_connection : unit -> int = "caml_get_connection";;
external get_status : unit -> int = "caml_get_status";;
external get_life : unit -> int = "caml_get_life";;
external get_display : unit -> int = "caml_get_display";;
external get_fire : unit -> int = "caml_get_fire";;

let address = "226.1.1.1";;
let port = "1500";;

let connect () = initialize address port;;

let disconnect () =
  close_connection ();
  close ();;