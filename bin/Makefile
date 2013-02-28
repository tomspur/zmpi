all: 		mpirun mpimaster

mpirun: 	mpirun.pyx
	PYTHONPATH=../src cython --embed mpirun.pyx
	gcc $(CFLAGS) mpirun.c -o mpirun -I/usr/include/python2.7/ -lpython2.7

mpimaster: 	mpimaster.pyx
	PYTHONPATH=../src cython --embed mpimaster.pyx
	gcc $(CFLAGS) mpimaster.c -o mpimaster -I/usr/include/python2.7/ -lpython2.7

clean:
	rm -rvf *.c *.h *.so zmpi/*.so zmpi/*h zmpi/*.c build mpirun mpimaster
