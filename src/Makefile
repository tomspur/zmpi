all: 		mpirun libzmpi

mpirun: 	mpirun.pyx
	cython --embed mpirun.pyx
	gcc $(CFLAGS) mpirun.c -o mpirun -I/usr/include/python2.7/ -lpython2.7

libzmpi:	zmpi.pyx
	python setup.py build_ext --inplace

clean:
	rm -vf *.c *.h zmpi.so
