let cam1 = Camera.create_camera 0 0 500 500;;
Printf.printf "The camera: {%d, %d, %d, %d}\n" (Camera.get_x cam1) (Camera.get_y cam1) (Camera.get_w cam1) (Camera.get_h cam1);;

Printf.printf "I modify the size of the camera\n";;
let cam2 = Camera.modify_size cam1 400 800;;
Printf.printf "The new camera: {%d, %d, %d, %d}\n" (Camera.get_x cam2) (Camera.get_y cam2) (Camera.get_w cam2) (Camera.get_h cam2);;

Printf.printf "I'll move the camera\n";;
let cam3 = Camera.move_camera cam1 1000 500 1000 600 20 60;;
Printf.printf "The new camera: {%d, %d, %d, %d}\n" (Camera.get_x cam3) (Camera.get_y cam3) (Camera.get_w cam3) (Camera.get_h cam3);;
