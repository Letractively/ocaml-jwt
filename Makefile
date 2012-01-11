OPT:=ocamlfind ocamlopt
CMPL:=ocamlfind ocamlc
PACK:=str,cryptokit,json-wheel
INSTALL:=ocamlfind install
UNINSTALL:=ocamlfind remove
LIBNAME:=jwt-ocaml

all:jwt.cma jwt.cmxa test

jwt.cma:jwt.ml
	$(CMPL) -a -o $@ -package $(PACK) jwt.mli jwt.ml

jwt.cmxa:jwt.ml
	$(OPT) -a -o $@ -package $(PACK) jwt.mli jwt.ml

test:test.ml
	$(OPT) -o $@ -package $(PACK) -linkpkg jwt.cmxa $<

install:
	$(INSTALL) $(LIBNAME) *.a *.o *.cm[ioxa] *.cmx[as] jwt.mli META

uninstall:
	$(UNINSTALL) $(LIBNAME)

reinstall:
	make uninstall
	make install

rebuild:
	make clean
	make

clean:
	rm -f *.cmi *.cmo *.cmx *.cma *.a *.cmxa *.o test

