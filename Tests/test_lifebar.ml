open OUnit2;;

let hero = (Object.create_movable 0 0 0 0 50 50 60 100 100);;

let cam = (Camera.create_camera 0 0 720 1280);;

let bar = (Lifebar.create hero cam 100);;

assert_equal (Lifebar.get_life bar) 100;;
assert_equal (Lifebar.get_xy bar) ((Camera.get_x cam),(Camera.get_y cam));;
Printf.printf "The lifebar is successfully created.\n";;

let damaged_hero = (Object.get_damage hero 30);;
let damaged_bar = (Lifebar.modify_life bar damaged_hero);;
assert_equal (Lifebar.get_life damaged_bar) 70;;
Printf.printf "The hero is successfully damaged.\n";;

let cam2 = Camera.move_camera cam 1000 1000 10000 10000 50 50;;
let moved_bar = Lifebar.modify_location bar cam2;;
assert_equal (Lifebar.get_xy moved_bar) ((Camera.get_x cam2),(Camera.get_y cam2));;
Printf.printf "The lifebar has moved successfully.\n";;

let new_color = Tsdl.Sdl.Color.create 0 255 0 0;;
let colored_bar = Lifebar.modify_color bar new_color;;
assert_equal (Lifebar.get_color colored_bar) new_color;;
Printf.printf "The lifebar has changed its color.\n";;
