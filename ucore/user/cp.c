#include <file.h>
#include <stdio.h>
#include <unistd.h>

#define BUFSIZE     4096

#define printf(...)                     fprintf(1, __VA_ARGS__)

int
main(int argc, char **argv){
    static char buffer[BUFSIZE];

    if (argc == 1) {
        printf("No file is specified.");
        return -1;
    }
    else if (argc == 2) {
        printf("You have to specify target path.");
        return -1;
    }
    else if (argc != 3) {
        printf("Too many arguments.");
        return -1;
    }
    else {
        int src_file, tgt_file, ret1, ret2;
        if ((src_file = open(argv[1], O_RDONLY)) < 0) {
            return src_file;
        }
        if ((tgt_file = open(argv[2], O_RDWR | O_CREAT)) < 0) {
            return tgt_file;
        }
        while ((ret1 = read(src_file, buffer, sizeof(buffer))) > 0) {
            if ((ret2 = write(tgt_file, buffer, ret1)) != ret1) {
                return ret2;
            }
        }
    }
    return 0;
}