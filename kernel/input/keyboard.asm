[global keyboard_handler]
%define KDATA_PORT	0x60
%define KSTATUS_PORT	0x64

exscancode:	db 0x00
uppercase:	db 0x00

kdbus:	db 0x00, 0x1b, "1234567890-=", 0x08, 0x09, "qwertyuiop[]", 0x0a, 0x00
	db "asdfghjkl;'", 0x00, 0x5c, "zxcvbnm,./", 0x00, '*', 0x00, ' ', 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, '-', 0x00, 0x00, 0x00, '+', 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
skdbus:	db 0x00, 0x1b, "!@#$%^&*()_+", 0x08, 0x09, "QWERTYUIOP{}", 0x0a, 0x00
	db "ASDFGHJKL:", 0x22, 0x00, 0x5c, "ZXCVBNM<>?", 0x00, '*', 0x00, ' ', 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, '-', 0x00, 0x00, 0x00, '+', 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

[extern put_char]
key_pressed:
	add 	ecx, kdbus
	mov 	ah, [ecx]
	call 	put_char
	jmp 	keyboard_handler_end
ukey_pressed:
	add 	ecx, skdbus
	mov 	ah, [ecx]
	call 	put_char
	jmp 	keyboard_handler_end

keyboard_handler:
	push 	eax
	push 	ebx
	push 	ecx
	push 	edx
	xor 	eax, eax
	xor 	ebx, ebx
	xor 	ecx, ecx
	xor	edx, edx
	mov 	dx, KSTATUS_PORT
	in 	al, dx
	push 	eax
	and 	al, 0x01
	cmp 	al, 0x01
	jne 	keyboard_handler_end
	mov 	dx, KDATA_PORT
	in  	al, dx
	cmp 	al, 0xe0
	je  	exscancode1
	mov 	ah, [exscancode]
	cmp 	ah, 0x01
	je 	exscancode2
	xor 	ah, ah
	mov	[exscancode], ah
	jmp	exscancode_end
exscancode_end:
	cmp 	al, 0x2a
	je 	uppercase1
	cmp 	al, 0x36
	je 	uppercase1
	cmp 	al, 0xaa
	je 	uppercase2
	cmp 	al, 0xb6
	je 	uppercase2
	cmp 	al, 0x50
	jge 	keyboard_handler_end
uppercase_end:
	movzx 	ecx, al
	mov	ah, [uppercase]
	cmp 	ah, 0x00
	je	key_pressed
	cmp 	ah, 0x01
	je 	ukey_pressed
	jmp 	keyboard_handler_end
exscancode1:
	mov 	ah, 0x01
	mov 	[exscancode], ah
	jmp exscancode_end
exscancode2:
	mov 	ah, 0x02
	mov 	[exscancode], ah
	jmp 	exscancode
uppercase1:
	mov 	ah, 0x01
	mov 	[uppercase], ah
	jmp 	uppercase_end
uppercase2:
	mov 	ah, 0x00
	mov 	[uppercase], ah
	jmp 	uppercase_end
keyboard_handler_end:
	pop eax
	pop eax
	pop ebx
	pop ecx
	pop edx
	ret

