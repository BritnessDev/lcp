#include <stdio.h>
#include <stdlib.h>
#include "checksum.h"

int main (int argc, char *argv[])
{
	if (argc < 3) {
		fprintf(stderr, "Usage: lcp [-b taille] source... destination\n");
		exit(1);
	}

	return 0;
}
