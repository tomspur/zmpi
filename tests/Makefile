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
	nosetests -v

clean:
	rm -vf *.c.out
