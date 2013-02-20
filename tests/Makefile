all:

check:
	@$(foreach file,$(wildcard *.c), gcc -L../src -I/usr/include/python2.7/ -I../include/ -I../src -L../include -lpython2.7 -lzmpi $(file) -o $(file).out;)
	@$(foreach file,$(wildcard *.c), LD_LIBRARY_PATH=${PWD}/../src:${LD_LIBRARY_PATH} ./$(file).out)
	@$(foreach file,$(wildcard *.c), LD_LIBRARY_PATH=${PWD}/../src:${LD_LIBRARY_PATH} ../src/mpirun -np 2 ./$(file).out)
	@$(foreach file,$(wildcard *.c), LD_LIBRARY_PATH=${PWD}/../src:${LD_LIBRARY_PATH} ../src/mpirun -np 3 ./$(file).out)
	@$(foreach file,$(wildcard *.c), LD_LIBRARY_PATH=${PWD}/../src:${LD_LIBRARY_PATH} ../src/mpirun -np 5 ./$(file).out)

clean:
	rm -vf *.c.out
