all: mpirun libzmpi check

mpirun:
	cd src; make mpirun

libzmpi:
	cd src; make libzmpi

check:
	cd tests; make check

clean:
	cd src; make clean
	cd tests; make clean
