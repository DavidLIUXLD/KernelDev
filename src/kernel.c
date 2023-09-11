#include "kernel.h"
#include <stddef.h>
#include <stdint.h>



volatile uint16_t * video_mem = 0;
uint16_t col_count = 0;
uint16_t row_count = 0;


uint16_t Calculate_Colour(unsigned char forecolour, unsigned char backcolour)
{
    uint16_t colour = (backcolour << 4) | (forecolour & 0x0F);
    return colour;
}

void WriteVGACharOld(unsigned char c, unsigned char colour, int x, int y)
{
    volatile uint16_t * targetMem = video_mem + y * VGA_LENGTH + x;
    *targetMem = c | (colour << 8);
    return;
}

void WriteVGAChar(unsigned char c, unsigned char colour, int x, int y)
{
    video_mem[y * VGA_LENGTH + x] = c | (colour << 8);
    return;
}


void WriteChar_Old(unsigned char c, unsigned char forecolour, unsigned char backcolour, int x, int y)
{
     uint16_t attrib = Calculate_Colour(forecolour, backcolour);
     WriteVGAChar(c, attrib, x, y);
     return;
}

void WriteChar(unsigned char c, unsigned char colour, int x, int y)
{
    WriteVGAChar(c, colour, x, y);
    return;
}


void Terminal_WriteChar(unsigned char c)
{
    if(c == '\n') {
        col_count = 0;
        row_count ++;
        return;
    }
    WriteChar(c, WHITE_ON_BLACK, col_count, row_count);
    col_count += 1;
    row_count = col_count < VGA_LENGTH ? row_count : row_count + 1;
    col_count = col_count % VGA_LENGTH;
    return;
}

void Terminal_Initialize(void)
{
    video_mem = (volatile uint16_t *)VGA_ADDRESS;
    col_count = 0;
    row_count = 0;
    for(int y = 0; y <= VGA_HEIGHT - 1; y ++) {
        for(int x = 0; x <= VGA_LENGTH - 1; x ++) {
            WriteChar(' ', WHITE_ON_BLACK, x, y);
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
        Terminal_WriteChar(str[x]);
    }
    return len;

}
/** Testing function, deprecated
//  uint16_t terminal_make_char(char c, char color) {
//  return (color << 8) | c;
}
**/
void kernel_main(void) 
{   
    /** Testing code
    //  uint16_t * video_mem = (uint16_t *)(0xB8000);         // pointer for colored ascii characters
    //  video_mem[0] = terminal_make_char('C', 3);
    **/
    Terminal_Initialize();
    print("Hello World!\ntest");
}