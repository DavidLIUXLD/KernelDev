[BITS 32]                       ; change code to 32bit
;kernel.asm.o needs to be loaded at first in the linker for the binary as it initiates data seg and other kernel starting process
;so kernel.asm cannot be included in asm section(that is placed after all other sections to prevent misalignment) of the binary
;linked by linker by "section .asm" and has to remain in the text section

global _start
extern kernel_main
CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    mov ax, DATA_SEG            ; assign data seg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x00200000         ; set stack frame
    mov esp, ebp

    in al, 0x92                 ; enable A20 line to read 21 bit of mem access
    or al, 2
    out 0x92, al

    call kernel_main
    jmp $
    
problem:
    int 0

    times 512-($ - $$) db 0     ; section alignment for kernel.asm to 512 bytes