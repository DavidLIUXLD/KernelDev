#include "io/terminal.h"

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

void Terminal_WriteChar_Old(unsigned char c, unsigned char forecolour, unsigned char backcolour)
{
    if(c == '\n') {
        col_count = 0;
        row_count ++;
        return;
    }
    WriteChar_Old(c, forecolour, backcolour, col_count, row_count);
    col_count += 1;
    row_count = col_count < VGA_LENGTH ? row_count : row_count + 1;
    col_count = col_count % VGA_LENGTH;
    return;
}

void Terminal_WriteChar(unsigned char c, unsigned char colour)
{
    if(c == '\n') {
        col_count = 0;
        row_count ++;
        return;
    }
    WriteChar(c, colour, col_count, row_count);
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