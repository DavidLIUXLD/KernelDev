#include "kernel.h"
#include <stddef.h>
#include <stdint.h>



volatile uint16_t * video_mem = 0;
uint16_t col_count = 0;
uint16_t row_count = 0;


void WriteChar(unsigned char c, unsigned char forecolour, unsigned char backcolour, int x, int y)
{
     uint16_t attrib = (backcolour << 4) | (forecolour & 0x0F);
     video_mem[y * VGA_LENGTH + x] = c | (attrib << 8);
}


void Terminal_WriteChar(unsigned char c, unsigned char forecolour, unsigned char backcolour)
{
    if(c == '\n') {
        col_count = 0;
        row_count ++;
        return;
    }
    WriteChar(c, forecolour, backcolour, col_count, row_count);
    col_count += 1;
    row_count = col_count < VGA_LENGTH ? row_count : row_count + 1;
    col_count = col_count % VGA_LENGTH;
    return;
}

void Terminal_Initialize(void)
{
    video_mem = (volatile uint16_t *)0xB8000;
    col_count = 0;
    row_count = 0;
    for(int y = 0; y <= VGA_HEIGHT - 1; y ++) {
        for(int x = 0; x <= VGA_LENGTH - 1; x ++) {
            WriteChar(' ', 0x00, 0x00, x, y);
        }
    }
    return;
}


size_t strlen(const char * str)
{
    size_t len = 0;
    while(str[len])
    {
        len ++;
    }
    return len;
}

size_t print(const char * str)
{
    size_t len = strlen(str);
    for(int x = 0; x <= len - 1; x ++) {
        Terminal_WriteChar(str[x], 0x0F, 0x00);
    }
    return len;

}

void kernel_main(void) 
{
    Terminal_Initialize();
    print("Hello World!\ntest");
}