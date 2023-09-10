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
    or al, 0x1            ; set PE (Protection Enable) bit in CR0 (Control Register 0)
    mov cr0, eax        ; hether the CPU is in Real Mode or in Protected Mode is defined by the lowest bit of the CR0, but since CS descriptor is still in current segment, execution still in 16-bit real mode
    jmp CODE_SEG:load32 ;far jmp loading CS with 0x8 selector(base 0x00000000 + eip load32) pointing to 32-bit descriptor to switch to 32-bit code mode, clearing pre-fetched input, jumping to load32


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
    dw gdt_end - gdt_start - 1  ; size of gdt_descriptor
    dd gdt_start                ; descriptor address


[BITS 32]
;=============================================================================
; load32:
; Driver function loading Kernel beginning at disk/binary file sector 1 to buffer address  
;
; @return None
;=============================================================================
load32:
    mov eax, 1          ; Starting disk sector: Disk/binary sector 1, 0 is for boot
    mov ecx, 100        ; Total sectors
    mov edi, 0x00100000 ; Target Address
    call ata_lba_read
    jmp CODE_SEG:0x00100000


;=============================================================================
; ATA read sectors (LBA mode) 
;
; @param EAX Logical Block Address of sector
; @param CL  Number of sectors to read
; @param RDI The address of buffer to put data obtained from disk
;
; @return None
;=============================================================================
ata_lba_read:
    pushfd
    and eax, 0x0FFFFFFF
    push eax
    push ebx
    push ecx
    push edx
    push edi

    mov ebx, eax         ; Save LBA in RBX

    mov edx, 0x01F6      ; Port to send drive and bit 24 - 27 of LBA
    shr eax, 24          ; Get bit 24 - 27 in al
    or al, 11100000b     ; Set bit 6 in al for LBA mode
    out dx, al

    mov edx, 0x01F2      ; Port to send number of sectors
    mov al, cl           ; Get number of sectors from CL
    out dx, al

    mov edx, 0x1F3       ; Port to send bit 0 - 7 of LBA
    mov eax, ebx         ; Get LBA from EBX
    out dx, al

    mov edx, 0x1F4       ; Port to send bit 8 - 15 of LBA
    mov eax, ebx         ; Get LBA from EBX
    shr eax, 8           ; Get bit 8 - 15 in AL
    out dx, al


    mov edx, 0x1F5       ; Port to send bit 16 - 23 of LBA
    mov eax, ebx         ; Get LBA from EBX
    shr eax, 16          ; Get bit 16 - 23 in AL
    out dx, al

    mov edx, 0x1F7       ; Command port
    mov al, 0x20         ; Read with retry.
    out dx, al

    .still_going:  in al, dx
    test al, 8           ; the sector buffer requires servicing.
    jz .still_going      ; until the sector buffer is ready.

    mov eax, 256         ; to read 256 words = 1 sector
    xor bx, bx
    mov bl, cl           ; read CL sectors
    mul bx
    mov ecx, eax         ; RCX is counter for INSW
    mov edx, 0x1F0       ; Data port, in and out
    rep insw             ; in to [RDI]

    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    popfd
    ret


times 510-($ - $$) db 0 ; fill 0 between current and 516 byte addresses
dw 0xAA55 ; signature at end of the segment