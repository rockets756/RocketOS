[extern idt_set_gate]
[extern pic_quick_remap]
[extern send_eoi]

%include "kernel/video/video.inc"

;; irq_handler function
;; gets called when irq is fired
;;
fault_handler:
	push eax
	mov ah, LIGHT_RED_BACKGROUND
	call clear_screen
	mov eax, ERR_MSG
	call write_line
	pop eax
	xor ebx, ebx
	xor edx, edx
	mov ebx, [eax + 48]
	cmp ebx, 0x13
	jg  kill
	mov eax, (e1 - e0)
	mul ebx
	add eax, e0
	jmp eax

e0:	mov eax, ERR_MSG0
	jmp write_error
e1:	mov eax, ERR_MSG1
	jmp write_error
e2:	mov eax, ERR_MSG2
	jmp write_error
e3:	mov eax, ERR_MSG3
	jmp write_error
e4:	mov eax, ERR_MSG4
	jmp write_error
e5:	mov eax, ERR_MSG5
	jmp write_error
e6:	mov eax, ERR_MSG6
	jmp write_error
e8:	mov eax, ERR_MSG7
	jmp write_error
e9:	mov eax, ERR_MSG9
	jmp write_error
e10:	mov eax, ERR_MSG10
	jmp write_error
e11:	mov eax, ERR_MSG11
	jmp write_error
e12:	mov eax, ERR_MSG12
	jmp write_error
e13:	mov eax, ERR_MSG13
	jmp write_error
e14:	mov eax, ERR_MSG14
	jmp write_error
e15:	mov eax, ERR_MSG15
	jmp write_error
e16:	mov eax, ERR_MSG16
	jmp write_error
e17:	mov eax, ERR_MSG17
	jmp write_error
e18:	mov eax, ERR_MSG18
	jmp write_error
e19:	mov eax, ERR_MSG19
	jmp write_error
write_error:
	call write_line
kill:
	cli
	hlt

ERR_MSG:   db "FATAL ERROR RESTART COMPUTER TO CONTINUE", 0x00
ERR_MSG0:  db "DIVISION BY ZERO", 0x00
ERR_MSG1:  db "DEBUG", 0x00
ERR_MSG2:  db "NON MASKABLE INTERRUPT", 0x00
ERR_MSG3:  db "BREAKPOINT", 0x00
ERR_MSG4:  db "INTO DETECTED OVERFLOW", 0x00
ERR_MSG5:  db "OUT OF BOUNDS", 0x00
ERR_MSG6:  db "INVALID OPCODE", 0x00
ERR_MSG7:  db "NO COPROCESSOR", 0x00
ERR_MSG8:  db "DOUBLE FAULT", 0x00
ERR_MSG9:  db "COPROCESSOR SEGMENT OVERRUN", 0x00
ERR_MSG10: db "BAD TTS", 0x00
ERR_MSG11: db "SEGMENT NOT PRESENT", 0x00
ERR_MSG12: db "STACK FAULT", 0x00
ERR_MSG13: db "GENERAL PROTECTION FAULT", 0x00
ERR_MSG14: db "PAGE FAULT", 0x00
ERR_MSG15: db "UNKNOWN INTERRUPT", 0x00
ERR_MSG16: db "COPROCESSOR FAULT", 0x00
ERR_MSG17: db "ALIGNMENT CHECK", 0x00
ERR_MSG18: db "MACHINE CHECK", 0x00
ERR_MSG19: db "GENERAL ERROR", 0x00

;; isrs_init function
;; No inputs
[global isrs_init]
isrs_init:
	call pic_quick_remap
	xor ah, ah
	mov ebx, isr0
	mov cx, 0x08
	mov al, 0x8e
	call idt_set_gate
	inc ah
	mov ebx, isr1
	call idt_set_gate
	inc ah
	mov ebx, isr2
	call idt_set_gate
	inc ah
	mov ebx, isr3
	call idt_set_gate
	inc ah
	mov ebx, isr4
	call idt_set_gate
	inc ah
	mov ebx, isr5
	call idt_set_gate
	inc ah
	mov ebx, isr6
	call idt_set_gate
	inc ah
	mov ebx, isr7
	call idt_set_gate
	inc ah
	mov ebx, isr8
	call idt_set_gate
	inc ah
	mov ebx, isr9
	call idt_set_gate
	inc ah
	mov ebx, isr10
	call idt_set_gate
	inc ah
	mov ebx, isr11
	call idt_set_gate
	inc ah
	mov ebx, isr12
	call idt_set_gate
	inc ah
	mov ebx, isr13
	call idt_set_gate
	inc ah
	mov ebx, isr14
	call idt_set_gate
	inc ah
	mov ebx, isr15
	call idt_set_gate
	inc ah
	mov ebx, isr16
	call idt_set_gate
	inc ah
	mov ebx, isr17
	call idt_set_gate
	inc ah
	mov ebx, isr18
	call idt_set_gate
	inc ah
	mov ebx, isr19
	call idt_set_gate
	inc ah
	mov ebx, isr20
	call idt_set_gate
	inc ah
	mov ebx, isr21
	call idt_set_gate
	inc ah
	mov ebx, isr22
	call idt_set_gate
	inc ah
	mov ebx, isr23
	call idt_set_gate
	inc ah
	mov ebx, isr24	
	call idt_set_gate
	inc ah
	mov ebx, isr25
	call idt_set_gate
	inc ah
	mov ebx, isr26
	call idt_set_gate
	inc ah
	mov ebx, isr27
	call idt_set_gate
	inc ah
	mov ebx, isr28
	call idt_set_gate
	inc ah
	mov ebx, isr29
	call idt_set_gate
	inc ah
	mov ebx, isr30
	call idt_set_gate
	inc ah
	mov ebx, isr31
	call idt_set_gate
	ret

isr_common_stub:
	pusha
	push ds
	push es
	push fs
	push gs
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov eax, esp
	push eax
	mov eax, fault_handler
	call eax
	pop eax
	pop gs
	pop fs
	pop es
	pop ds
	popa
	add esp, 8
	iret

;;  0: Divide By Zero Exception
isr0:
    cli
    push byte 0
    push byte 0
    jmp isr_common_stub
;;  1: Debug Exception
isr1:
    cli
    push byte 0
    push byte 1
    jmp isr_common_stub
;;  2: Non Maskable Interrupt Exception
isr2:
    cli
    push byte 0
    push byte 2
    jmp isr_common_stub
;;  3: Int 3 Exception
isr3:
    cli
    push byte 0
    push byte 3
    jmp isr_common_stub
;;  4: INTO Exception
isr4:
    cli
    push byte 0
    push byte 4
    jmp isr_common_stub
;;  5: Out of Bounds Exception
isr5:
    cli
    push byte 0
    push byte 5
    jmp isr_common_stub
;;  6: Invalid Opcode Exception
isr6:
    cli
    push byte 0
    push byte 6
    jmp isr_common_stub
;;  7: Coprocessor Not Available Exception
isr7:
    cli
    push byte 0
    push byte 7
    jmp isr_common_stub
;;  8: Double Fault Exception (With Error Code!)
isr8:
    cli
    push byte 8
    jmp isr_common_stub
;;  9: Coprocessor Segment Overrun Exception
isr9:
    cli
    push byte 0
    push byte 9
    jmp isr_common_stub
;; 10: Bad TSS Exception (With Error Code!)
isr10:
    cli
    push byte 10
    jmp isr_common_stub
;; 11: Segment Not Present Exception (With Error Code!)
isr11:
    cli
    push byte 11
    jmp isr_common_stub
;; 12: Stack Fault Exception (With Error Code!)
isr12:
    cli
    push byte 12
    jmp isr_common_stub
;; 13: General Protection Fault Exception (With Error Code!)
isr13:
    cli
    push byte 13
    jmp isr_common_stub
;; 14: Page Fault Exception (With Error Code!)
isr14:
    cli
    push byte 14
    jmp isr_common_stub
;; 15: Reserved Exception
isr15:
    cli
    push byte 0
    push byte 15
    jmp isr_common_stub
;; 16: Floating Point Exception
isr16:
    cli
    push byte 0
    push byte 16
    jmp isr_common_stub
;; 17: Alignment Check Exception
isr17:
    cli
    push byte 0
    push byte 17
    jmp isr_common_stub
;; 18: Machine Check Exception
isr18:
    cli
    push byte 0
    push byte 18
    jmp isr_common_stub
;; 19: Reserved
isr19:
    cli
    push byte 0
    push byte 19
    jmp isr_common_stub
;; 20: Reserved
isr20:
    cli
    push byte 0
    push byte 20
    jmp isr_common_stub
;; 21: Reserved
isr21:
    cli
    push byte 0
    push byte 21
    jmp isr_common_stub
;; 22: Reserved
isr22:
    cli
    push byte 0
    push byte 22
    jmp isr_common_stub
;; 23: Reserved
isr23:
    cli
    push byte 0
    push byte 23
    jmp isr_common_stub
;; 24: Reserved
isr24:
    cli
    push byte 0
    push byte 24
    jmp isr_common_stub
;; 25: Reserved
isr25:
    cli
    push byte 0
    push byte 25
    jmp isr_common_stub
;; 26: Reserved
isr26:
    cli
    push byte 0
    push byte 26
    jmp isr_common_stub
;; 27: Reserved
isr27:
    cli
    push byte 0
    push byte 27
    jmp isr_common_stub
;; 28: Reserved
isr28:
    cli
    push byte 0
    push byte 28
    jmp isr_common_stub
;; 29: Reserved
isr29:
    cli
    push byte 0
    push byte 29
    jmp isr_common_stub
;; 30: Reserved
isr30:
    cli
    push byte 0
    push byte 30
    jmp isr_common_stub
;; 31: Reserved
isr31:
    cli
    push byte 0
    push byte 31
    jmp isr_common_stub
