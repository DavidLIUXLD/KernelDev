#include "idt/idt.h"
#include "config.h"
#include "memory/memory.h"
#include "string/string.h"

struct IDTRDescriptor32 idtr_desc;
struct idt InterruptDescriptor32[IDT_TOTAL_INTERRUPTS];

extern void idt_load(struct IDTRDescriptor32* ptr);

void int_zero(void)
{
    print("Divided by Zero\n");
    return;
}

void idt_set(int interrupt_number, void* offset, uint8_t DPL, uint8_t type, uint8_t param_count)
{
    struct InterruptDescriptor32 interrupt_desc = idt[interrupt_number];
    interrupt_desc.offset_1 = offset & 0x0000ffff;
    interrupt_desc.selector = KERNEL_CODE_SEG;
    interrupt_desc.zero = 0x00 | param_count;
    interrupt_desc.type_attributes = DPL | GATE_TYPE_INT;
    interrupt_desc.offset_2 = offset >> 16;
    return;
}

void idt_set_int(int interrupt_number, void* offset, uint8_t DPL)
{
    idt_set(interrupt_number, offset, DPL, GATE_TYPE_INT, 0x00);
    return;
}

void idt_set_call(int interrupt_number, void* offset, uint8_t DPL, uint8_t param_count)
{
    idt_set(interrupt_number, offset, DPL, GATE_TYPE_CALL, param_count);
    return;
}

void idt_set_trap(int interrupt_number, void* offset, uint8_t DPL)
{
    idt_set(interrupt_number, offset, DPL, GATE_TYPE_TRAP, 0x00);
    return;
}

void interrupt_div_by_zero(void)
{
    print("Divided by zero error\n");
    return;
}

void idt_init(void)
{
    idt = memset(&idt, 0, sizeof(IDT));
    IDTR_DESC.size = sizeof(IDT) - 1;
    IDTR_DESC.offset = (uint32_t)idt;
    idt_load(&idtr_desc);
    idt_set_int(0, interrupt_div_by_zero, 0xE0);
    return;
}

