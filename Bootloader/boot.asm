ORG 0
BITS 16

_start:
    jmp short start
    nop

times 33 db 0 ; Boot Parameter Block manual overwrite to prevent USB boot overwrite and corrupt bootloader

start:
    jmp 0x7c0:boot_main ; change code segment address to 0x7c00

boot_main:
    
    cli ; Clear interrupts flag prevent interrupting of segment register changes
    mov ax, 0x7c0 ; boot loading to 0x7c00 (0x7c0 * 16 or shift left to 0x7c00 + ORG which is 0)
    mov ds, ax ; setting data, extra segment to 0x7c00
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enable interrupts

    mov si, message
    call print
    jmp $

print:
.loop_start:
    lodsb
    cmp al, 0
    je .loop_end
    call print_char
    jmp .loop_start
.loop_end:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret


message: db 'Hello World', 0 ; data segment(because of db) + ORG(location related to current segment) + offset within
times 510-($ - $$) db 0 ; fill 0 between current and 516 byte addresses
dw 0xAA55 ; signature at end of the segment