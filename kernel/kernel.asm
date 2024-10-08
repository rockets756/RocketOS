[bits 32]
;; We are currently at 0x7e00 in memory (It shouldn't matter anymore)
jmp kmain

%include "kernel/video/video.inc"	; Text mode video library header
%include "kernel/interrupts/pic.inc"
%include "kernel/interrupts/idt.inc"
%include "kernel/interrupts/isrs.inc"

kmain:
	cli
	call idt_init
	call isrs_init
	;sti

	mov ah, GREY_BACKGROUND
	call clear_screen
	mov eax, WELCOME_MSG
	call write_line
	mov eax, WELCOME_MSG2
	call write_line
	mov eax, 0x0abcdef
	call print_hex
loop:
	hlt
	jmp loop
kill:	; Kills the cpu (restart mandatory)
	cli
	hlt

WELCOME_MSG: db "Hello, World!", 0x00
WELCOME_MSG2: db "Welcome!", 0x00
