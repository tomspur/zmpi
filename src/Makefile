all: 		libzmpi mpirun

mpirun: 	mpirun.pyx
	cython --embed mpirun.pyx
	gcc $(CFLAGS) mpirun.c -o mpirun -I/usr/include/python2.7/ -lpython2.7

libzmpi:	libzmpi.pyx
	python setup.py build_ext --inplace

clean:
	rm -rvf *.c *.h *.so zmpi/*.so zmpi/*h zmpi/*.c build mpirun
