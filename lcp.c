#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <fcntl.h>
#include <sys/types.h>
#include <io.h>
#include <sys/stat.h>
#include <unistd.h>
#include "checksum.h"
int fileTransfer(char* src, char* dist, int n)
{
    char arr[128], arr1[128];
    unsigned int count = 0, progress = 0;
    struct stat sfile; //pointer to stat struct
    int f_read, f_write, tempIndex;
    long pos;
    uint32_t chk1 = 0, chk2 = 0;
    // Open the file for READ only.

    memset(arr, 0, sizeof(arr));
    memset(arr1, 0, sizeof(arr1));
    if (stat(src, &sfile) == -1)
    {
        printf("File: %s Function: %s Line: %d \n", __FILE__, __FUNCTIONW__, __LINE__);
        perror("Error ");
        return 1;
    }

    // get information from file
    
    f_write = _open(src, O_RDONLY);
    if (f_write == -1) {
        printf("File: %s Function: %s Line: %d \n", __FILE__, __FUNCTIONW__, __LINE__);
        perror("Error ");
        return 1;
    }
    // Open the file for Cr only.

    // check whether dist file is exist

    if (stat(dist, &sfile) == -1) // if dist file is not exist
    {
        stat(src, &sfile);
        f_read = _open(dist, O_RDWR | O_CREAT, _S_IREAD | _S_IWRITE);
        if (f_read == -1) {
            printf("File: %s Function: %s Line: %d \n", __FILE__, __FUNCTIONW__, __LINE__);
            perror("Error ");
            return 1;
        }
        // write entire content
        while (count = _read(f_write, arr, n))
        {
            if (count == -1)
            {
                printf("File: %s Function: %s Line: %d \n", __FILE__, __FUNCTIONW__, __LINE__);
                perror("Error ");
                return 1;
            }
            //lseek(f_write, n, SEEK_CUR);
            _write(f_read, arr, count);
        
            memset(arr, 0, sizeof(arr));
            progress += count;
            printf("Progress: %d%%\n", progress * 100 / sfile.st_size);
        }
    }
    else // if dist file is exist
    {
        stat(src, &sfile);
        f_read = _open(dist, O_RDWR, _S_IREAD | _S_IWRITE);
        
        if (f_read == -1) {
            printf("File: %s Function: %s Line: %d \n", __FILE__, __FUNCTIONW__, __LINE__);
            perror("Error ");
            return 1;
        }
        // write entire content
        while (count = _read(f_write, arr, n))
        {
            if (count == -1)
            {
                printf("File: %s Function: %s Line: %d \n", __FILE__, __FUNCTIONW__, __LINE__);
                perror("Error ");
                return 1;
            }
            //lseek(f_write, n, SEEK_CUR);
            tempIndex = _read(f_read, arr1, n);
            if (tempIndex == -1)
            {
                printf("File: %s Function: %s Line: %d \n", __FILE__, __FUNCTIONW__, __LINE__);
                perror("Error ");
                return 1;
            }
            if (memcmp(arr, arr1, sizeof(arr)))
            {
                
                lseek(f_read, (-1) * tempIndex, SEEK_CUR);
                _write(f_read, arr, count);
                printf("Progress: %d%%\n", progress * 100 / sfile.st_size);
               
            }

            memset(arr, 0, sizeof(arr));
            memset(arr1, 0, sizeof(arr1));

            //f_read = _open(dist, O_RDWR, _S_IREAD | _S_IWRITE);
            stat(dist, &sfile);
            //fletcher32(f_read, sfile.st_size);
            progress += count;   
        }
    }
    // if dist file is exist
    //write different content between two files
    f_read = _open(src, _S_IREAD);
    if (f_read == -1 || stat(src, &sfile) == -1)
    {
        printf("File: %s Function: %s Line: %d \n", __FILE__, __FUNCTIONW__, __LINE__);
        perror("Error ");
        return 1;
    }
    // src file's checksume
    chk1 = fletcher32(src, sfile.st_size);

    f_read = _open(dist, _S_IREAD);
    if (f_read == -1 || stat(dist, &sfile) == -1)
    {
        printf("File: %s Function: %s Line: %d \n", __FILE__, __FUNCTIONW__, __LINE__);
        perror("Error ");
        return 1;
    }
    // dist file's checksume
    chk2 = fletcher32(dist, sfile.st_size );
    // check whether checksum is correct or not 
    if (chk1 == chk2)
    {
        puts("Progress: 100%\n");
    }
    printf("Checksum %s match expected value\n\n", chk1 == chk2 ? "does" : "DOES NOT");

    _close(f_write);
    _close(f_read);
    return 0;
}
int main (int argc, char *argv[])
{
	unsigned int i, j, blocksize = 32;
    char src[256], dist[256];


    if (argc == 5 && !strcmp(argv[1], "-b"))
    {
        // if -b option
        // input the block size
        blocksize = atoi(argv[2]);

        strcpy_s(src, argv[3]);
        strcpy_s(dist, argv[4]);
        if (!fileTransfer(src, dist, blocksize))
            puts("Success");
        else
            puts("Failed");
    }
    else if(argc == 3)
    {
        strcpy_s(src, argv[1]);
        strcpy_s(dist, argv[2]);
        if (!fileTransfer(src, dist, 32))
            puts("Success");
        else
            puts("Failed");
    }
    else {
        printf("Parameter is incorrect, Please type the valid value");
        exit(1);
    }
    return 0;
}
