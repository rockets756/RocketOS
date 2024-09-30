[global pic_remap]
[global pic_get_irr]
[global pic_get_isr]
[global disable_pic]
%define IDT 		0xd00	; Pointer to the start of the interrupt descriptor table
%define PIC1_COMMAND	0x20
%define PIC1_DATA	0x21
%define PIC2_COMMAND	0xa0
%define PIC2_DATA	0xa1
%define PIC_EOI		0x20
%define PIC_DISABLE	0xff
%define PIC_READ_IRR	0x0a
%define PIC_READ_ISR	0x0b
%define ICW1_ICW4	0x01
%define ICW1_SINGLE	0x02
%define ICW1_INTERVAL4	0x04
%define ICW1_LEVEL	0x08
%define ICW1_INIT	0x10
%define ICW4_8086	0x01
%define ICW4_AUTO	0x02
%define ICW4_BUF_SLAVE	0x08
%define ICW4_BUF_MASTER	0x0c
%define ICW4_SFNM	0x10

[global pic_quick_remap]
pic_quick_remap:
	push eax
	push edx
	mov dx, 0x20
	mov al, 0x11
	out dx, al
	mov dx, 0xa0
	out dx, al
	mov dx, 0x21
	mov al, 0x20
	out dx, al
	mov dx, 0xa1
	mov al, 0x28
	out dx, al
	mov dx, 0x21
	mov al, 0x04
	out dx, al
	mov dx, 0xa1
	mov al, 0x02
	out dx, al
	mov dx, 0x21
	mov al, 0x01
	out dx, al
	mov dx, 0xa1
	out dx, al
	mov dx, 0x21
	xor al, al
	out dx, al
	mov dx, 0xa1
	out dx, al
	pop edx
	pop eax
	ret

;; pic_remap function
;; Inputs:
;;	ah = offset1
;;	al = offset2
;; Remaps both pic chips
;; FIXME: Creates unhandled fatal error somewhere
;;
pic_remap:
	pusha
	mov ebx, eax		; BH = OFFSET1	BL = OFFSET2
	mov dx, PIC1_DATA
	in  al, dx
	mov ch, al		; CH = MASK1
	mov dx, PIC2_DATA
	in  al, dx
	mov cl, al		; CL = MASK2
	mov al, ICW1_INIT
	mov ah, ICW1_ICW4
	or  al, ah
	mov dx, PIC1_COMMAND
	out dx, al
	call io_wait
	mov dx, PIC2_COMMAND
	out dx, al
	call io_wait
	mov dx, PIC1_DATA
	mov al, bh		; AL = OFFSET1
	out dx, al
	call io_wait
	mov dx, PIC2_DATA
	mov al, bl		; AL = OFFSET2
	out dx, al
	call io_wait
	mov dx, PIC1_DATA
	mov al, 0x04
	out dx, al
	call io_wait
	mov dx, PIC2_DATA
	mov al, 0x02
	out dx, al
	call io_wait
	mov dx, PIC1_DATA
	mov al, ICW4_8086
	out dx, al
	call io_wait
	mov dx, PIC2_DATA
	mov al, ICW4_8086
	out dx, al
	call io_wait
	mov dx, PIC1_DATA
	mov al, ch
	out dx, al
	mov dx, PIC2_DATA
	mov al, cl
	out dx, al
	popa
	ret

;; pic_get_irr function
;; No inputs
;; Output irr in ax
;;
pic_get_irr:
	mov ah, PIC_READ_IRR
	ret
;; pic_get_isr function
;; No inputs
;; Output isr in ax
;;
pic_get_isr:
	mov ah, PIC_READ_ISR

;; pic_get_irq_reg function
;; Inputs:
;; 	ah = ocw3
;;
pic_get_irq_reg:
	push	ebx
	push 	ecx
	push 	edx
	mov	dx, PIC1_COMMAND
	mov	al, ah
	out	dx, al			; outb(PIC1_COMMAND, ocw3);
	mov	dx, PIC2_COMMAND
	out	dx, al			; outb(PIC2_COMMAND, ocw3);
	in 	al, dx			; al = inb(PIC2_COMMAND)
	movzx	bx, al
	shl	bx, 0x08		; bx = (inb(PIC2_COMMAND) << 8)
	mov	dx, PIC1_COMMAND
	in	al, dx
	mov 	al, cl
	movzx	ax, cl
	or	ax, bx			; ax = (inb(PIC2_COMMAND) << 8) | inb(PIC1_COMMAND)
	pop	edx
	pop	ecx
	pop	ebx
	ret

;; send_eoi function
;; Inputs:
;;	ah = irq number
;; Sends end of interrupt the correct pic chip
;;
send_eoi:
	push edx
	cmp ah, 0x08
	jge send_eoi2
	mov dx, PIC1_COMMAND
	mov al, PIC_EOI
	out dx, al
	pop edx
	ret
send_eoi2:
	mov dx, PIC2_COMMAND
	mov al, PIC_EOI
	out dx, al
	pop edx
	ret

;; disable_pic function
;; No inputs
;; Disables both of the pic chips
;;
disable_pic:
	push eax
	push edx
	mov dx, PIC1_DATA
	mov al, PIC_DISABLE
	out dx, al
	mov dx, PIC2_DATA
	out dx, al
	pop edx
	pop eax
	ret

;; io_wait function
;; No inputs
;; Gives the pic some time to react
;;
io_wait:
	push eax
	push edx
	xor al, al
	mov dx, 0x80
	out dx, al
	pop edx
	pop eax
	ret

