CC=gcc
CFLAGS=-I.
DEPS = evilexec.c

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

all: evilexec.o 
	$(CC) -o evilexec evilexec.o -I. -lcap-ng && setcap 'cap_dac_read_search=eip' evilexec

.PHONY: clean

clean:
	rm -f *.o evilexec
