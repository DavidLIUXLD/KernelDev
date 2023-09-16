#include "memory/memory.h"


void* memset(void* ptr, int c, size_t size)
{
    char* src_ptr = (char*)ptr;
    for (size_t i = 0; i < size; i++)
    {
        src_ptr[i] = (char)c;
    }
    return ptr;
}