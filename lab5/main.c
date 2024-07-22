#include <stdio.h>
#include <string.h>
#include <time.h>
#include "stb/stb_image.h"
#include "stb/stb_image_write.h"
#include "filter.h"

extern double sqrt(double);

int main(int argc, char **argv)
{
    if(argc != 4)
    {
        printf("Three files are needed");
        return 1;
    }
    char *filename_src, *filename_res_c, *filename_res_asm;
    filename_src 		= argv[1];
    filename_res_c		= argv[2];
    filename_res_asm	= argv[3];
    if(strcmp(&filename_src[strlen(filename_src) - 5], ".jpeg") != 0)
    {
        printf("Source file must be in .jpeg format");
        return 2;
    }
    if(strcmp(&filename_res_c[strlen(filename_res_c) - 5], ".jpeg") != 0)
    {
        printf("Destination file 1 must be in .jpeg format");
        return 3;
    }
    if(strcmp(&filename_res_asm[strlen(filename_res_asm) - 5], ".jpeg") != 0)
    {
        printf("Destination file 2 must be in .jpeg format");
        return 4;
    }
    printf("%s\n%s\n%s\n", filename_src, filename_res_c, filename_res_asm);

    int x, y, n;
    unsigned char *data_src = stbi_load(filename_src, &x, &y, &n, 0);
    if(data_src == NULL)
    {
        perror("Error occured while opening source file");
        return 5;
    }

    int sharp[] =
        {
            -1, -1, -1,
            -1,  9, -1,
            -1, -1, -1
        };

    int sobel[] =
        {
            1, 0, -1,
            2, 0, -2,
            1, 0, -1
        };

    int large_gauss[] =
        {  4, 15, 24, 15, 4,
           15, 60, 95, 60, 15,
           24, 95, 151, 95, 24,
           15, 60, 95, 60, 15,
           4, 15, 24, 15, 4
        };

    int gauss[] =
        {
            1, 2, 1,
            2, 4, 2,
            1, 2, 1
        };
    int size_gauss = sqrt(sizeof (gauss) / sizeof (typeof (gauss[0])));
    int div_gauss = 16;

	unsigned char *data_res_c	= malloc(x * y * 3 * sizeof (unsigned char));
	unsigned char *data_res_asm	= malloc(x * y * 3 * sizeof (unsigned char));
    
    clock_t start, end;
    
    start = clock();
    apply_filter(data_src, data_res_c, x, y, gauss, size_gauss, div_gauss);
    end = clock();
    printf("apply_filter: %Lf\n", (long double) (end - start) / CLOCKS_PER_SEC);

    start = clock();
    apply_filter_asm(data_src, data_res_asm, x, y, gauss, size_gauss, div_gauss);
    end = clock();
    printf("apply_filter_asm: %Lf\n", (long double) (end - start) / CLOCKS_PER_SEC);
    
    stbi_write_jpg(filename_res_c, x, y, 3, data_res_c, 100);
    stbi_write_jpg(filename_res_asm, x, y, 3, data_res_asm, 100);
    stbi_image_free(data_src);
    stbi_image_free(data_res_c);
    stbi_image_free(data_res_asm);
    return 0;
}
