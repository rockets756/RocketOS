all: os.img
	qemu-system-i386 -fda $^

debug: os.img
	gdb -x script.gdb

os.img: boot/boot_sect.bin kernel/kernel.elf
	cat $^ > $@

kernel/kernel.elf: kernel/kernel.o kernel/video/video.o
	ld -m elf_i386 -o $@ -Ttext 0x7e00 $^ --oformat binary

boot/boot_sect.bin: boot/boot_sect.asm
	nasm $^ -f bin -o $@

kernel/kernel.o: kernel/kernel.asm
	nasm $^ -f elf -o $@

kernel/video/video.o: kernel/video/video.asm
	nasm $^ -f elf -o $@

clean:
	rm os.img
	rm boot/boot_sect.bin
	rm kernel/kernel.elf
	rm kernel/kernel.o
	rm kernel/video/video.o

