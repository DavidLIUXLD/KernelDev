[BITS 32]                       ; change code to 32bit
global _start
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

    jmp $