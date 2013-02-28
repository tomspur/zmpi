all: bins libzmpi check

bins:
	cd bin; make

libzmpi:
	cd src; make libzmpi

check:
	cd tests; make check

clean:
	cd bin; make clean
	cd src; make clean
	cd tests; make clean
	rm -rvf build
