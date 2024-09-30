[global idt_init]
[global idt_set_gate]

[extern clear_screen]
;; idt_init function
;; No inputs
;;
idt_init:
	mov 	ax, 2047
	mov 	ebx, 0xd00
	mov 	[ebx], ax
	mov	eax, 0x500
	add	ebx, 0x02
	mov	[ebx], eax
	xor	bl, bl
clear_idt_loop:
	cmp	eax, 0xd00
	je	clear_idt_done
	mov	[eax], bl
	inc	eax
	jmp	clear_idt_loop
clear_idt_done:
	;; Add ISRs here using idt_set_gate
	[extern keyboard_handler]
	mov ah, 0x01
	mov ebx, keyboard_handler
	mov cx, 0x08
	mov al, 0x8e
	lidt [0xd00]
	ret

DBG:
	push eax
	mov ah, 0x50
	call clear_screen
	pop eax
	ret

;; idt_set_gate function
;; Inputs:
;; 	ah  = idt entry number
;;	al  = idt entry flags
;;	ebx = idt entry base address
;;	cx  = idt entry sel
;;
idt_set_gate:
	pusha
	push	edx
	push	eax
	movzx	edx, ah
	mov	eax, 0x08
	mul	edx
	add	eax, 0x500
	mov	edx, eax
	pop	eax
	push	ebx
	and	ebx, 0xffff
	mov	[edx], ebx
	pop	ebx
	shr	ebx, 16
	and	ebx, 0xffff
	add	edx, 0x06
	mov	[edx], ebx
	dec	edx
	mov	[edx], al
	dec	edx
	xor	al, al
	mov	[edx], al
	sub	edx, 0x02
	mov	[edx], cx
	pop	edx
	popa
	ret

