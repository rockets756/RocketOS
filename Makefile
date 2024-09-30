all: os.img
	qemu-system-i386 -fda $^
debug: os.img
	gdb -x script.gdb
os.img: boot/boot_sect.bin kernel/kernel.elf
	cat $^ > $@
kernel/kernel.elf: kernel/kernel.o kernel/video/video.o kernel/interrupts/pic.o kernel/interrupts/idt.o kernel/interrupts/isrs.o kernel/input/keyboard.o
	ld -m elf_i386 -o $@ -Ttext 0x7e00 $^ --oformat binary
boot/boot_sect.bin: boot/boot_sect.asm
	nasm $^ -f bin -o $@
kernel/kernel.o: kernel/kernel.asm
	nasm $^ -f elf -o $@
kernel/video/video.o: kernel/video/video.asm
	nasm $^ -f elf -o $@
kernel/interrupts/pic.o: kernel/interrupts/pic.asm
	nasm $^ -f elf -o $@
kernel/interrupts/idt.o: kernel/interrupts/idt.asm
	nasm $^ -f elf -o $@
kernel/interrupts/isrs.o: kernel/interrupts/isrs.asm
	nasm $^ -f elf -o $@
kernel/input/keyboard.o: kernel/input/keyboard.asm
	nasm $^ -f elf -o $@

clean:
	rm os.img
	rm boot/boot_sect.bin
	rm kernel/kernel.elf
	rm kernel/kernel.o
	rm kernel/video/video.o
	rm kernel/interrupts/pic.o
	rm kernel/interrupts/idt.o
	rm kernel/interrupts/isrs.o
	rm kernel/inputs/keyboard.o
