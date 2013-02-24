all:

TESTS=$(wildcard *.c)

.SUFFIXES:
.SUFFIXES: .c .c.out

BINARIES=$(TESTS:.c=.c.out)

.c.c.out:
	gcc $(CFLAGS) \
		-I/usr/include/python2.7/ \
		-lpython2.7 \
		-I../include/ \
		-L../include \
		-I../src \
		-L../src \
		-lzmpi \
		$< \
		-o $<.out

check:	$(BINARIES)
	for binary in $(BINARIES) ; do \
		echo "RUNNING $$binary" ; \
		LD_LIBRARY_PATH=${PWD}/../src:${LD_LIBRARY_PATH} ./$$binary || die "Running plain $$binary failed" ; \
		LD_LIBRARY_PATH=${PWD}/../src:${LD_LIBRARY_PATH} ../src/mpirun -np 2 ./$$binary || die "Running plain $$binary failed" ; \
		LD_LIBRARY_PATH=${PWD}/../src:${LD_LIBRARY_PATH} ../src/mpirun -np 3 ./$$binary || die "Running plain $$binary failed" ; \
		LD_LIBRARY_PATH=${PWD}/../src:${LD_LIBRARY_PATH} ../src/mpirun -np 5 ./$$binary || die "Running plain $$binary failed" ; \
	done

clean:
	rm -vf *.c.out
