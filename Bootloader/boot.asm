ORG 0x7c00
BITS 16


start:
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


message: db 'Hello World', 0
times 510-($ - $$) db 0
dw 0xAA55