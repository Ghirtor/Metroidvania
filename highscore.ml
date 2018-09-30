let tab = Tools.get_levels ();;
let highscores = Array.init (Array.length tab) (fun i -> 1000000);;

let get_highscore l =
  let rank = (Tools.get_next_level l) - 1 in
  if rank = (-2) then highscores.((Array.length highscores) - 1) else highscores.(rank);;

let set_highscore l s =
  let rank = (Tools.get_next_level l) - 1 in
  if rank = (-2) then highscores.((Array.length highscores) - 1) <- s else highscores.(rank) <- s;;
