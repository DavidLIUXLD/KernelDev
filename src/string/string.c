#include "string/string.h"
#include "io/terminal.h"

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
        Terminal_WriteChar(str[x], WHITE_ON_BLACK);
    }
    return len;
}