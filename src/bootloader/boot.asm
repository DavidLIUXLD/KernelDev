ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start ; code segment gdt offset stmbol 
DATA_SEG equ gdt_data - gdt_start ; data segment gdt offset stmbol 

_start:
    jmp short start
    nop


times 33 db 0       ; Boot Parameter Block manual overwrite to prevent USB boot overwrite and corrupt bootloader


start:
    jmp 0:boot_main ; change code segment address to 0x7c00


handle_zero:        ; self-defined interrupt vector zero
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret


boot_main:          ; boot entry
    cli             ; Clear interrupts flag prevent interrupting of segment register changes
    mov ax, 0x00    ; boot loading to 0x7c00 (ORG 0x7c00 + offset)
    mov ds, ax      ; setting data, extra segment to 0x7c00
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00  ; stack top adr/stack size, stack growning down
    sti             ; Enable interrupts

.load_protected:    ; entering protected
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or al, 1        ; set PE (Protection Enable) bit in CR0 (Control Register 0)
    mov cr0, eax
    jmp CODE_SEG:load32 ; far call to load32 with CODE_SEG memory space


; GDT, offset increament by 8-bytes, word is 2-byte
gdt_start:
gdt_null:
dd 0x0
dd 0x0
; offset 0x8
gdt_code:           ; CS pointing to this segment
dw 0xffff           ; seg limit 0-15
dw 0x0000           ; seg base 0-15
db 0x00             ; seg base 16-23
db 0x9a             ; access byte 10011010
db 0xcf             ; flag 1100 + limit 16-19
db 0x00             ; seg base 24-31
; offset at 0x10:
gdt_data:           ; DS, SS, ES, FS, GS pointing to this segment
dw 0xffff           ; seg limit 0-15
dw 0x0000           ; seg base 0-15
db 0x00             ; seg base 16-23
db 0x92             ; access byte 10010002
db 0xcf             ; flag 1100 + limit 16-19
db 0x00             ; seg base 24-31
gdt_end:


gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; size of gdt_descriptor
    dd gdt_start               ; descriptor address

[BITS 32]                      ; change code to 32bit
load32:
    mov ax, DATA_SEG           ; assign data seg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x00200000        ; set stack frame
    mov esp, ebp
    jmp $

times 510-($ - $$) db 0 ; fill 0 between current and 516 byte addresses
dw 0xAA55 ; signature at end of the segment