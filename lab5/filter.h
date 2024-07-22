#ifndef FILTER_H
#define FILTER_H

void apply_filter(const unsigned char *data, unsigned char *out, int width, int height, int *kernel, int kernel_size, int div);
void apply_filter_asm(const unsigned char *data, unsigned char *out, int width, int height, int *kernel, int kernel_size, int div);

#endif // FILTER_H
