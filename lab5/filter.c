#include "filter.h"

void apply_filter(const unsigned char *data, unsigned char *out, int width, int height, int *kernel, int kernel_size, int div)
{
    int kernel_radius = kernel_size / 2;

       // Iterate through each pixel in the image
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            int r = 0, g = 0, b = 0;

               // Iterate through the kernel
            for (int ky = 0; ky < kernel_size; ky++)
            {
                for (int kx = 0; kx < kernel_size; kx++)
                {
                    // Calculate the coordinates of the neighboring pixel
                    int nx = x + kx - kernel_radius;
                    int ny = y + ky - kernel_radius;

                       // If the neighboring pixel is not within the image bounds
                    if (!(nx >= 0 && ny >= 0 && nx < width && ny < height))
                    {
                        // Check if the modifiable pixel is closest to the neighbouring one
                        if(nx == x || ny == y ||
                            nx < 0 && ny  < 0 || nx >= width && ny < 0 || nx < 0 && ny >= height || nx >= width && ny >= height)
                        {
                            nx = x;
                            ny = y;
                        }
                        else
                        {
                            if(nx >= 0 && nx < width)
                                ny = y;
                            else// if(ny >= 0 && ny < height)
                                nx = x;
                        }
                    }
                    // Get the RGB values of the neighboring pixel
                    unsigned char nr = data[(nx + ny * width) * 3 + 0];
                    unsigned char ng = data[(nx + ny * width) * 3 + 1];
                    unsigned char nb = data[(nx + ny * width) * 3 + 2];

                       // Apply the kernel weights to the RGB values
                    r += nr * kernel[kx + ky * kernel_size];
                    g += ng * kernel[kx + ky * kernel_size];
                    b += nb * kernel[kx + ky * kernel_size];
                }
            }
               // Scale the RGB values by 1/div
            r /= div;
            g /= div;
            b /= div;

            out[(x + y * width) * 3 + 0] = (unsigned char) r;
            out[(x + y * width) * 3 + 1] = (unsigned char) g;
            out[(x + y * width) * 3 + 2] = (unsigned char) b;
        }
    }
    return;
}
