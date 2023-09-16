#ifndef TERMINAL_H
#define TERMINAL_H

#define VGA_ADDRESS 0xb8000
#define VGA_HEIGHT 20
#define VGA_LENGTH 80

#define WHITE_ON_BLACK 0x0f

#include <stddef.h>
#include <stdint.h>

void Terminal_WriteChar_Old(unsigned char c, unsigned char forecolour, unsigned char backcolour);
void Terminal_WriteChar(unsigned char c, unsigned char colour);
void Terminal_Initialize(void);

#endif