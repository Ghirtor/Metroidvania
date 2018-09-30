TESTDIR=Tests
TESTS=$(TESTDIR)/test_object.byte $(TESTDIR)/test_camera.byte
PROJECT=metroidvania.byte

project:
	make clean_project
	ocamlbuild net.o
	ocamlbuild -use-ocamlfind -package tsdl,tsdl_mixer,tsdl_image,tsdl_ttf,lambdasoup -lflags -custom,net.o $(PROJECT)

test:
	ocamlbuild $(TESTDIR)/test_object.byte
	ocamlbuild -use-ocamlfind -package oUnit $(TESTDIR)/test_camera.byte

clean_testdir:
	rm -rf $(TESTDIR)/_build
	rm -f $(TESTDIR)/*.cm[iox] *~ .*~ #*#
	rm -f $(TESTS)
	rm -f test_*.byte
	rm -f $(TESTS).opt

clean_project:
	rm -f *.o
	rm -f *.byte
	rm -rf _build
	rm -f *.cm[iox] *~ .*~ #*#
	rm -f $(PROJECT)
	rm -f $(PROJECT).opt

clean:
	make clean_testdir
	make clean_project

exec_tests:
	make exec_test_object
	make exec_test_camera

exec_test_object:
	./test_object.byte

exec_test_camera:
	./test_camera.byte

exec_project:
	./$(PROJECT)
