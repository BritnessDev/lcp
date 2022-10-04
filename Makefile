all: lcp

lcp: lcp.c checksum.o
	$(CC) -Wextra -Wall -o lcp lcp.c checksum.o

checksum.o:
	$(CC) -c checksum.c

inject.so: inject.c
	$(CC) -shared -fPIC -o inject.so inject.c -ldl

check: all inject.so
	bats check.bats

clean:
	rm lcp checksum.o
