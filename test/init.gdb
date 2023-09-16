add-symbol-file ../build/kernelfull.o 0x00100000
break kernel_main
target remote | qemu-system-x86_64 -hda ../bin/os.bin -gdb stdio -S