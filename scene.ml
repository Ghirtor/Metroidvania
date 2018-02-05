open Tsdl;;

module Scene : scene =
  struct

    let players = create();;
    let enemies = create();;
    let elements = create();;
    
    let create () =
      [||]
    ;;
    
    let add e a =
      let l = (Array.length a) in
      Array.init (l+1) (fun i -> if i < l then a.(i) else e)
    ;;

    exception not_found;;
    
    let search e a =
      for i=0 to (Array.length a)-1 do
        if (e.compare a.(i)) = 0 then i
      done;
      raise not_found
    ;;
    
    let remove e a =
      let l = (Array.length a) in
      let i = search e a in
      Array.init (l-1) (fun j -> if j < i then a.(j) else a.(j+1))
    ;;

    let display x y =
      for i=0 to (Array.length elements)-1 do
        Object.display elements.(i)
      done;
      for i=0 to (Array.length enemies)-1 do
        Object.display enemies.(i)
      done;
      for i=0 to (Array.length players)-1 do
        Object.display players.(i)
      done;
    ;;
  end
;;
