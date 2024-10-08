[global write_line]
[global print_hex]section .data
[global put_char]
[global clear_screen]
[global currx]
[global curry]
[global disable_cursor]

;; Character res = 80x25
%define SCREEN_WIDTH	0x50
%define SCREEN_HEIGHT	0x19

currx:		db 0x00
curry:		db 0x00
currcolor:	db 0x0f

;; write_line function
;; eax = pointer to string to print
write_line:
	push ebx
	push ecx
write_line_loop:
	mov bl, [eax]
	cmp bl, 0x00
	je write_line_done
	;; TODO: Check for newline characters
	push eax
	mov ah, bl
	call put_char
	pop eax
	inc eax
	jmp write_line_loop
write_line_done:
	call newline
	pop ecx
	pop ebx
	ret


;; print_hex function 
;; Inputs: 
;;   eax or ebx = 32 bit number to print
string_hex:       db '0x'
string_hex_buff:  db '00000000', 0x00
hex_digits:       db '0123456789abcdef'
print_hex:
  push eax 
  push ebx 
  mov ebx, eax
  lea edi, [string_hex_buff + 7]   ; Point to the end of the buffer (right-most digit)
  mov byte [edi+1], 0     ; Null-terminate the string
convert:
  mov eax, ebx           ; Move the number to eax
  and eax, 0xF           ; Mask all but the least significant 4 bits
  mov dl, [hex_digits + eax] ; Get the corresponding hex character
  mov [edi], dl          ; Store it in the buffer
  shr ebx, 4             ; Shift right by 4 bits to process the next hex digit
  dec edi                ; Move to the next position in the buffer
  test ebx, ebx          ; Check if the number is zero
  jnz convert            ; If not, continue conversion
  mov eax, string_hex
  call write_line
  pop ebx 
  pop eax 
	ret

;; put_char function
;; ah = character to print
;; Places character in ah to ((((SCREEN_WIDTH * [curry]) + [currx]) * 2) + 0xb8000) in memory
;;
put_char:
	push ebx		; PUSH FROM WHEN PUT_CHAR WAS CALLED
	push ecx		; PUSH FROM WHEN PUT_CHAR WAS CALLED
	push eax		; PUSH CHARACTER WE WANT TO PRINT TO THE STACK
	mov eax, SCREEN_WIDTH	; EAX = SCREEN_WIDTH
	xor ebx, ebx		; EBX = 0X00
	xor ecx, ecx		; ECX = 0X00
	mov cl, [curry]		; CL  = [curry]
	movzx ebx, cl		; EBX = [curry]
	mul ebx			; EAX = (SCREEN_WIDTH * [curry])
	mov cl, [currx]		; CL  = [currx]
	movzx ebx, cl		; EBX = [currx]
	add eax, ebx		; EAX =   ((SCREEN_WIDTH * [curry]) + [currx])
	shl eax, 1		; EAX =  (((SCREEN_WIDTH * [curry]) + [currx]) * 2)
	add eax, 0xb8000	; EAX = ((((SCREEN_WIDTH * [curry]) + [currx]) * 2) + 0xb8000)
	mov ebx, eax		; EBX = ((((SCREEN_WIDTH * [curry]) + [currx]) * 2) + 0xb8000)
	pop eax			; AH  = charactertoprint
	mov [ebx], ah		; WRITE CHARACTER TO VIDEO MEMEORY
	pop ecx			; RETURN FROM WHEN PUT_CHAR WAS CALLED
	pop ebx			; RETURN FROM WHEN PUT_CHAR WAS CALLED
	call inc_cursor		; INCRAMENT CURSOR TO THE NEXT AVALABLE SPOT
	call update_cursor	; MOVE CURSOR TO UPDATED POSITION
	ret			; RETURN TO PUT_CHAR CALLER


;; clear_screen function
;; ah = color number
;; Function internal registers:
;;	edx = video memory pointer
;;	eax = stores emtpy character
;; Old function I kept because it just works
;;
clear_screen:			; Start of clear_screen function
	push eax		; Save eax because the function uses it internally
	push ebx		; Save ebx because the function uses it internally
	mov ebx, 0xb8000	; Store the video pointer
clear_screen_loop:		; Loop that cycles through each character and clears it
	cmp ebx, 0xb8FA0	; See if we are at the end of the screen
	je clear_screen_done	; If so then return
	mov al, ' '		; Use the space character as the empty char
	mov [ebx], al		; Print the empty char
	inc ebx			; Incrament video pointer to color info
	mov [ebx], ah		; Write the color data
	inc ebx			; Prep for the next character slot
	jmp clear_screen_loop	; Loop to clear the next character
clear_screen_done:		; Return section
	xor al, al		; Set cursor to start
	mov [currx], al		; Set cursor to start
	mov [curry], al		; Set cursor to start
	pop ebx			; Return ebx to origional state
	pop eax			; Return eax to origional state
	ret			; Return from function

;; newline function
;; No inputs
;; Moves cursor to the start of the next line.
;;
newline:
	push eax		; Save eax from newline caller
	xor ah, ah		; AH = 0X00
	mov [currx], ah		; currx = 0X00
	mov ah, [curry]		; AH = [curry]
	cmp ah, 24		; CHECK IF WE ARE AT THE END OF THE PAGE
	je inc_cursor_scroll	; FIXME: REPLACE WITH REAL SCROOL FUNCTION
	inc ah			; AH = ([curry] + 1)
	mov [curry], ah		; [curry] = ([curry] + 1)
	pop eax			; Return eax to newline caller
	ret			; Return to newline caller

;; inc_cursor function
;; No inputs
;; Moves cursor over one. If we reached the end of a line then start a new one.
;;
inc_cursor:
	push eax
	mov ah, [currx]
	cmp ah, (SCREEN_WIDTH - 1)
	je inc_cursory
	inc ah
	mov [currx], ah
	jmp inc_cursor_end
inc_cursory:
	mov al, [curry]
	cmp al, 25
	je inc_cursor_scroll
	inc al
	mov [curry], al
	xor ah, ah
	mov [currx], ah
	jmp inc_cursor_end
inc_cursor_scroll:
	;; TODO: Implement scrolling
	xor eax, eax
	mov [currx], al
	mov [curry], al
inc_cursor_end:
	pop eax
	ret

;; update_cursor function
;; no inputs
;; Updates the position of the cursor to match [currx] and [curry]
;;
update_cursor:
	movzx bx, [currx]
	movzx ax, [curry]
	mov dl, SCREEN_WIDTH
	mul dl
	add bx, ax
	mov dx, 0x03D4
	mov al, 0x0F
	out dx, al
	inc dl
	mov al, bl
	out dx, al
	dec dl
	mov al, 0x0E
	out dx, al
	inc dl
	mov al, bh
	out dx, al
	ret

;; enable_cursor function
;; no inputs
;; Function internal registers
;; 	al = number to write to ports
;;	dx = port to write number to
;; No comments because it is self explanitory
;;
disable_cursor:
	push eax
	push edx
	mov al, 0x0a
	mov dx, 0x3d4
	out dx, al
	mov al, 0x20
	mov dx, 0x3d5
	out dx, al
	pop edx
	pop eax
	ret

