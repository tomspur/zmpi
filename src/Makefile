all: 		libzmpi

libzmpi:	libzmpi.pyx
	python setup.py build_ext --inplace

clean:
	rm -rvf *.c *.h *.so zmpi/*.so zmpi/*h zmpi/*.c build mpirun
