#ifndef IDT_H
#define IDT_H

#define GATE_TYPE_INT 0x0E
#define GATE_TYPE_CALL 0x0C
#define GATE_TYPE_TRAP 0x0F

#include <stdint.h>
#include <stddef.h>

struct InterruptDescriptor32
{
   uint16_t offset_1;           // offset bits 0..15
   uint16_t selector;           // a code segment selector in GDT or LDT
   uint8_t  zero;               // unused, set to 0
   uint8_t  type_attributes;    // gate type, dpl, and p fields
   uint16_t offset_2;           // offset bits 16..31
} __attribute__((packed));

struct IDTRDescriptor32
{
    uint16_t size;              // Size of the IDT - 1
    uint32_t offset;            // Linear address of IDT  
} __attribute__((packed));

void idt_set(int interrupt_number, void* offset);
void idt_init(void);

#endif


