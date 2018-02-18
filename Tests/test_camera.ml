open OUnit2;;

let field_width = 10000;;
let field_height = 2000;;

let cam = Camera.create_camera 0 2000 720 1280;;

assert_equal (Camera.get_h cam) 720;;
assert_equal (Camera.get_w cam) 1280;;
Printf.printf  "The camera is created\n";;

let cam2 = Camera.modify_size cam 1080 1920;;
assert_equal (Camera.get_h cam2) 1080;;
assert_equal (Camera.get_w cam2) 1920;;
Printf.printf "The camera is modified\n";;

let cam3 = Camera.move_camera cam2 4950 1450 10000 2000 100 100;;
assert_equal (Camera.get_x cam3) 4040;;
assert_equal (Camera.get_y cam3) 920;;
Printf.printf "The camera has moved\n";;

let cam4 = Camera.move_camera cam2 9950 1950 10000 2000 100 100;;
assert_equal (Camera.get_x cam4) 8080;;
assert_equal (Camera.get_y cam4) 920;;
Printf.printf "The camera is in the low right corner\n";;

let cam5 = Camera.move_camera cam2 9950 0 10000 2000 100 100;;
assert_equal (Camera.get_x cam5) 8080;;
assert_equal (Camera.get_y cam5) 0;;
Printf.printf "The camera is in the high right corner\n";;

let cam6 = Camera.move_camera cam2 0 0 10000 2000 100 100;;
assert_equal (Camera.get_x cam6) 0;;
assert_equal (Camera.get_y cam6) 0;;
Printf.printf "The camera is in the high left corner\n";;

let cam7 = Camera.move_camera cam2 0 1950 10000 2000 100 100;;
assert_equal (Camera.get_x cam7) 0;;
assert_equal (Camera.get_y cam7) 920;;
Printf.printf "The camera is in the low left corner\n";;
