all:
	ocamlc -c camera.mli camera.ml object.mli object.ml scene.mli scene.ml
	ocamlbuild -use-ocamlfind -package tsdl,tsdl_mixer metroidvania.byte
