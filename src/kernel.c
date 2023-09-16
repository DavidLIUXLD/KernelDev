#include "kernel.h"
#include "config.h"
#include "io/terminal.h"
#include "string/string.h"


void kernel_main(void) 
{   
    /** Testing code
    //  uint16_t * video_mem = (uint16_t *)(0xB8000);         // pointer for colored ascii characters
    //  video_mem[0] = terminal_make_char('C', 3);
    **/
    Terminal_Initialize();
    print("Hello World!\ntest");
}