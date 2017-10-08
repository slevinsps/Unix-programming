.386p ; ����� ��������� ����������� ������������
      ; ����������� ����� ������ 32-���������� ���������������,
			; ����� �-� ���. � �����������������

; ���� �� ������ - �������-�. ������ 6, ��, ���������
;									 ������ ����� 6, ����� ����������� �������


; ������ ������� ���� ���� ��������


; ����������� ��������� - ��������� ���������� � ����� start � �������� RM_seg; �����, ���������� ���������� ��������, �����, �����������,
; �� ��������� � ���������� ����� �� PM_Entry �������� PM_seg

; ������ �� �������, �� ������������, �� ������������, �� ������, �� ������

; � �������������

descr struc     ; ��������� ��� �������� ������������ �������� � ������� ���������� ������������ GDT
	lim 		dw 0	; ������� (���� 0..15)  - ������ �������� � ������
	base_l 	dw 0	; ������� 16 ����� �������� ����. - ������� ����� ������� � ����������� �������� ������������
	base_m 	db 0	; ��������� 8 ����� �������� ����.
	attr_1	db 0	; �����/�������� �������, ������������ � ����� ������ ������
	attr_2	db 0	; ����� ������������ ���� �������.
	base_h 	db 0	; ��������� 8 ����� �������� ����.
descr ends

int_descr struc ; ��������� ��� �������� ������������ ����������
	offs_l 	dw 0 	; ������� 16 ����� ������, ���� ���������� ������� � ������ ������������� ����������.
	sel			dw 0	; �������� �������� � ����� ����������/������������� �������� ����
	counter db 0  ; �������, �� ������������ � ���������. ������ ����!
	attr		db 0  ; ��������
	offs_h 	dw 0  ; ������� 16 ����� ������, ���� ���������� �������.
int_descr ends

; Protected mode
PM_seg	SEGMENT PARA PUBLIC 'CODE' USE32		; ���������, ��� ������� �������� �� ����� 32 ����� ���������; �������� LOOP �����
												                    ;������������ ECX �������, � �� ������ ��� ������� ��������� CX
										                        ;��� ���� ���� ��� ����� ����������� "�������" ���, �� ��� ����� �������� ����� ������ � ������ ��� ������� ������ ����
	                ASSUME	CS:PM_seg

    ; ������� ������������ �������� GDT
  	GDT		label	byte

  	; ������� ����������
  	gdt_null	descr <>

  	; 32-������ 4-����������� ������� � ����� = 0
  	gdt_flatDS	descr <0FFFFh,0,0,92h,11001111b,0>	; 92h = 10010010b

  	; 16-������ 64-����������� ������� ���� � ����� RM_seg
  	gdt_16bitCS	descr <RM_seg_size-1,0,0,98h,0,0>	; 98h = 10011010b

  	; 32-������ 4-����������� ������� ���� � ����� PM_seg
  	gdt_32bitCS	descr <PM_seg_size-1,0,0,98h,01000000b,0>

  	; 32-������ 4-����������� ������� ������ � ����� PM_seg
  	gdt_32bitDS	descr <PM_seg_size-1,0,0,92h,01000000b,0>

  	; 32-������ 4-����������� ������� ������ � ����� stack_seg
  	gdt_32bitSS	descr <stack_l-1,0,0, 92h, 01000000b,0>

  	gdt_size = $-GDT ; ������ ����� ������� GDT+1���� (�� ���� �����)

  	gdtr	df 0	; ���������� ������� 6 ���� ��� ������� ���������� ������� ������������ GDTR

    ; ����� ��� ����������
    SEL_flatDS     equ   8
    SEL_16bitCS    equ   16
    SEL_32bitCS    equ   24
    SEL_32bitDS    equ   32
    SEL_32bitSS    equ   40

    ; ������� ������������ ���������� IDT
    IDT	label	byte

    ; ������ 32 �������� ������� (� ��������� �� ������������)
    int_descr 32 dup (<0, SEL_32bitCS,0, 8Eh, 0>)

    ; ���������� ���������� �� �������
    int08 int_descr <0, SEL_32bitCS,0, 8Eh, 0>

    ; ���������� ���������� �� ����������
    int09 int_descr	<0, SEL_32bitCS,0, 8Eh, 0>

    idt_size = $-IDT ; ������ ����� ������� IDT+1���� (�� ���� �����)

    idtr	df 0 ; ���������� ������� 6 ���� ��� ������� ������� ������������ ���������� IDTR

    idtr_real dw	3FFh,0,0 ; ���������� �������� IDTR � �������� ������

    master	db 0					 ; ����� ���������� �������� �����������
    slave		db 0					 ; ��������

    escape		db 0				 ; ���� - ���� �������� � �������� �����, ���� ==1
    time_08		dd 0				 ; ������� ��������� ����� �������



	; ����� ����� � 32-������ ���������� �����
PM_entry:
		; ����� � �������� ������ �� ��������� � ����������� ������ ��������� ������, ����� � ����;
		;������ �� ��������������� �� �������������
		mov	ax,SEL_32bitDS
		mov	ds,ax
		mov	ax,SEL_flatDS
		mov	es,ax
		mov	ax,SEL_32bitSS
		mov	ebx,stack_l
		mov	ss,ax
		mov	esp,ebx

		; ��������� ����������, ����������� ����� ��� � �������� ������
		sti ; ��������� ����� ���������� IF = 1

		;������� ���������� ��������� ������ � �������� ��� �� �����
		call	compute_memory

		;�������� � ����������� �����, ������������ ��������� �� ���������� ���������� � �������
		;����� �� ����� - �� ������� Enter (��������� � ����������� ���������� ���������� new_int09)
work:
		test	escape, 1
		jz	work

goback:
		; ��������� ����������, �� �� ��� �� �������
		; ��� ���� ������������� ��� ���������, �� �� �������
		cli ; ����� ����� ���������� IF = 0

		; � �� ������ �� ����� �������� ��������� ������� � ����������? ���, ��� �����, � ����� �� ������ ��������� �� ����� RM_return
		db	0EAh ; �� �������, ������, � ��������, �� �������� ��������, ���������, ��� ���������������� � ����� � ��������-�.
		; �����. ��� ������ ��� ������� far jump
		dd	offset RM_return
		dw	SEL_16bitCS


	;����� ����������� ���������� ���������� �������, ������� ����� � ���������� ������ ������� ������� time_08
new_int08:
		; ������ ���������
		push eax
		push ebp
		push ecx
		push dx
		mov  eax,time_08

		; ����� � EBP �������� �� 8 �������� �� ������ ������
		; �������������� �������� ����� ����������, ��� ����� ��� ��� ������� my_print_eax(����), ������� ���������� ������� ��� �� �����
		; ������ ���, � �� ������? ������ ��� �����, � ����� ��� �� ��������, ��� ���������, ����������� �������� ������ �������!
		mov ebp,0B8010h
		mov ecx,8
prcyc:
		mov dl,al
		and dl,0Fh
		cmp dl,10
		jl number
		add dl, 'A' - '0' - 10
number:
		add dl,'0'
		mov es:[ebp],dl
		sub ebp,2
		ror eax,4
		loop prcyc

		inc eax
		mov time_08,eax

		; ������, ��������
		pop dx
		pop ecx
		pop ebp

		;������������ ������� �����, ��� ������� ������; ���������� ������� End of Interrupt �������� ����������� ����������
		mov	al,20h
		out	20h,al
		pop eax

		iretd ;������� �� ����������

	; ���������� ���������� ����������
new_int09:
		push	eax							; ��� ���������� ���������� - ��������� �������

		in	al,60h						; ��������� ����-��� ������� ������� �� ����� ����������

		cmp	al,1Ch						; ���������� � ����� Enter
		jne	not_leave					; ���� �� Enter - �� ���������, �������� ������
		mov escape,1					; ���� Enter - ������ ����, ��� ���� �� �����
	not_leave:

		; �� Enter - ��������� ������������ ����������
		in	al,61h
		or	al,80h            ; ����� ��� � ������ - ������� �����, �������� � ��� ��� ������, ������� �������
		out	61h,al

		; ������� EOI (End of Interrupt) ����������� ����������, �������� ��� � ���������� ���������
		mov	al,20h
		out	20h,al

		; ������������ ������� � �����
		pop	eax
		iretd


; ������ ��� �������� ������� ������� (��� �������) �� ������� (7 -> '7', 15 -> 'F')
create_number macro
local number1
	cmp dl,10
	jl number1
	add dl,'A' - '0' - 10
number1:
	add dl,'0'
endm



; ������ ������ �� ����� �������� �������� ��� ����� �����������
my_print_eax macro
local prcyc1 				; ���������, ��� ����� ��������� ��� �������; �� ������ ����������� ��� ������ ���������� �� �������
	push ecx 					; ��������� ������������ ��������
	push dx

	mov ecx,8					; ���������� ��������, ������� �����������
	add ebp,0B8010h 	; ������ � EBP ������ ������ ��������� ������� ������� �� ������, � �������� � ����� ����������� �����
										; 0B8000h - �������� ������������ ������������ ������ ��������.
										; ��� 10h - ��������� 8 ��������, ��������� ����� ���������� ������-������
prcyc1:
	mov dl,al					; ����� � DL ������� �������� AL (����� ������� ���� ���)
	and dl,0Fh				; ��������� �� ���� ���� 16������ ����� (��������� �����)
	create_number 0		; ���������� ��� ����� � ������
	mov es:[ebp],dl		; ���������� ��� � ����������
	ror eax,4					; ���������� ������� ���� � ��� - ����� �������, ����� ���� ������������,
										; ��� �������� ��� �� ��� � � ������, ��� ������������� �� PUSH; POP
	sub ebp,2					; ��������� �� ���� ������ ����� (���������� ����� � ���)
	loop prcyc1				; ����������� 8 ���

	sub ebp,0B8010h		; ���������� � EBP �� �� ��������, ��� ���� � ��� �� ������ � ������������
	pop dx
	pop ecx
endm

; �� ��� ������, ��� ������ ��� ������?

; ����� � ������ (������� �������� ��������� ������)
compute_memory	proc

		push	ds            ; ��������� ������� �������� DS
		mov	ax, SEL_flatDS	; ������ � ���� ������� �� 4 �� - ��� ��������� ����������� ��
		mov	ds, ax					; ���� ��� �������� � DS
		mov	ebx, 100001h		; ���������� ������ �������� ����� ��������
		mov	dl,	10101010b	  ; ������� ������� �������� �� ��������������� ����� ������ ������ ��� ���� (��� ��� �������)
												; � ������ ���� �� ����� �����-�� ��������, � ����� �������, ��� �����������

		mov	ecx, 0FFEFFFFEh	; � ECX ����� ���������� ���������� ������ (�� ���������� ������ � 4��) - ����� �� ���� ������������

		; � ����� ������� ������
check:
		mov	dh, ds:[ebx]		; ��������� � DH ������� �������� �� ���������� ����� ������
												; EBX �� ������ �������� �������� �������� �� 1� �������� ������
												; �������� ���������� ������, ��� � ��������� ������ ����� ���������
												; ������� �������������� ��������� ������������ ����, ��� ���� ������ �� ����
		mov	ds:[ebx], dl		; ����� ��������� �������� (�������� ���� DL) � ���� ����
		cmp	ds:[ebx], dl		; ��������� - ��������� ������� �� �� DL, ��� �����-�� �����
		jnz	end_of_memory		; ���� ��������� ����� - �� �� �������� ���, � �� ��� ����� ����� ������, ������������ �� �����
		mov	ds:[ebx], dh		; ���� ��� �� �������� - ����� ������� ����������� ��������, ����� �� ��������� ������� �� ������
		inc	ebx							; ��������� ��������� ����.... �� �� ������, ����� ������� �������, ������� ���������� ��� � ������
												; � �������, � �������� ������ ����� 16 �� ������, ��� ��� �� �����-�� � ����� �����
												; �������� ����� ������ (������?) ����� �������� ��� 16 �� � ������� ��������
		loop	check
end_of_memory:
		pop	ds							; ���������� ������� � ����������� �����, ������ ��������� - ��������������� ��������
		xor	edx, edx
		mov	eax, ebx				; � EBX ����� ���������� ����������� ������ � ������; ����� ��� � EAX,
		mov	ebx, 100000h		; ����� �� 1 ��, ����� �������� ��������� � ����������
		div	ebx

		push ebp
		mov ebp,20					; ��������� �������� � ����������� ������������ ������ ������ (10 �������� - 1 ���� ������� � 1 ���� ����� )
		my_print_eax 0			; �������� ����-������ �����-������
		pop ebp							; ��������������� ����������� �������� EBP

		ret
	compute_memory	endp


	PM_seg_size = $-GDT
PM_seg	ENDS

; � ���� ���� �������������

stack_seg	SEGMENT  PARA STACK 'STACK'
	stack_start	db	100h dup(?)
	stack_l = $-stack_start							; ����� ����� ��� ������������� ESP
stack_seg 	ENDS


; Real Mode
RM_seg	SEGMENT PARA PUBLIC 'CODE' USE16		; USE16 - ���������� ������ ����� ���������, �� �� ��; ������� ���� E* � �������� ������ ����������
	ASSUME CS:RM_seg, DS:PM_seg, SS:stack_seg

start:
		; �������� �����
		mov	ax,3
		int	10h
		; ��������� ������� ds �� ������� � ���������� �������
		push PM_seg
		pop ds

		; ��������� ���� ��� ���� ������������ ������������ ���������
		xor	eax,eax
		mov	ax,RM_seg
		shl	eax,4		; �������� ��������� ��� PARA, ����� �������� �� 4 ���� ��� ������������ �� ������� ���������
		mov	word ptr gdt_16bitCS.base_l,ax
		shr	eax,16
		mov	byte ptr gdt_16bitCS.base_m,al
		mov	ax,PM_seg
		shl	eax,4
		push eax		; ��� ���������� ������ idt
		push eax		; ��� ���������� ������ gdt
		mov	word ptr GDT_32bitCS.base_l,ax
		mov	word ptr GDT_32bitSS.base_l,ax
		mov	word ptr GDT_32bitDS.base_l,ax
		shr	eax,16
		mov	byte ptr GDT_32bitCS.base_m,al
		mov	byte ptr GDT_32bitSS.base_m,al
		mov	byte ptr GDT_32bitDS.base_m,al

		; �������� �������� ����� GDT
		pop eax
		add	eax,offset GDT 						; � eax ����� ������ �������� ����� GDT (����� �������� + �������� GDT ������������ ����)
		; �������� - ��� ������ � ���������� ������ �����������
		mov	dword ptr gdtr+2,eax			; ����� ������ �������� ����� � ������� 4 ����� ���������� gdtr
		mov word ptr gdtr, gdt_size-1	; � ������� 2 ����� ������� ������ gdt, ��-�� ����������� gdt_size (����� $) ��������� ������ �� 1 ���� ������
		; �������� GDT
		lgdt	fword ptr gdtr

		; ���������� �������� �������� ����� IDT
		pop	eax
		add	eax,offset IDT
		mov	dword ptr idtr+2,eax
		mov word ptr idtr, idt_size-1

		; �������� �������� � ������������ ����������
		mov	eax, offset new_int08 ; ���������� �������
		mov	int08.offs_l, ax
		shr	eax, 16
		mov	int08.offs_h, ax
		mov	eax, offset new_int09 ; ���������� ����������
		mov	int09.offs_l, ax
		shr	eax, 16
		mov	int09.offs_h, ax

		; �������� ����� ���������� ������������
		in	al, 21h							; ��������, 21h - "���������� ���������" - ����� ����, in �� �� ���� ��� ����� ����� (������)
		mov	master, al					; ��������� � ���������� master (����������� ��� ����������� � RM)
		in	al, 0A1h						; �������� - ����������, in ��� ����� ����� ��� ��������
		mov	slave, al

		; ����� ����� (����������������� ������� ����������)
		mov	al, 11h							; ������� "���������������� ������� ����������"
		out	20h, al							; 20h - ������� ������, "���� ���������\����������"
		mov	AL, 20h							; ������� ������ (��������� �������� ��� �����������) ������ 32 (20h)
		out	21h, al							; ���������, ��� ���������� ���������� ����� �������������� ������� � 32�� (20h)
		mov	al, 4								; ���������� � ��� �� ���� ��� ��� ���������� ���������,
														; ������� - �������, ��������� ������� �� �������� ����������
		out	21h, al
		mov	al, 1							  ; ���������, ��� ����� ����� �������� ������� ���������� ����������� ����������
		out	21h, al

		; �������� ��� ���������� � ������� �����������, ����� IRQ0 (������) � IRQ1(����������)
		mov	al, 0FCh
		out	21h, al

		;�������� ������ ��� ���������� � ������� �����������
		;� ��������� ������ ��������� ���������� - ����� ������ ����������, ��� �������� � ��� �� ������� ����������
		mov	al, 0FFh
		out	0A1h, al

		; �������� IDT
		lidt	fword ptr idtr

		; ���� �� ���������� �������� � 32-������ �������, ����� ������� A20
		; �20 - ����� ("����"), ����� ������� �������������� ������ �� ���� ������ �� ��������� ������� ���������
		in	al,92h						; ������� ����� ������
		or	al,2							; �������� � ��� �������� �� 2 ����
		out	92h,al						; ��������� �������

		; ��������� ����������� ����������
		; ���� �� ����� �������� � ���������� ����� � ��� �������� ����� ���� �����-������ ���������� - ����� ��������� ����� �����
		; ��������� �����, � ���������� ������� ��������� ��� ��� ����� ����� � ���� - ���� ����������� ���������� ��� �� ��������, ������ - �٨ �� ��������
		cli
		; ����� �������� � ������������� ����������
		in	al,70h
		or	al,80h
		out	70h,al

		; ������� � ��������������� ���������� ����� ���������� ���������������� ���� �������� CR0
		mov	eax,cr0
		or	al,1
		mov	cr0,eax

		; �������� ��������� SEL_32bitCS � ������� CS �� �� ����� ��-�� �������� ����������� ����������; ������� ������� �����
		db	66h
		db	0EAh
		dd	offset PM_entry
		dw	SEL_32bitCS
		; ������� � ���� �������, ����� ����������� ��� �� ������� PM_entry
		; �����������, ��-�� ^ �����������, ������ MOV CS, offset SEL_32bitCS; jmp PM_entry, ��� ���������� ������������ ��� ����� �������
		; ������, ������� ����, ����� ������� �� ���� ����� ����� �����

RM_return:
		; ������� � �������� �����; ����������� - � ��������-�.
		mov	eax,cr0
		and	al,0FEh 				; ���������� ���� ����������� ������
		mov	cr0,eax

		; �������� ������� � ��������� CS �������� ������
		db	0EAh						; ������ � ������ - ����� ��-�� ����������� ������� � CS
		dw	$+4							; ��� ��� ���� ��� ������� �����
		dw	RM_seg

		; ������������ �������� ��� ������ � �������� ������
		mov	ax,PM_seg				; ��������� � ���������� �������� "����������" (��������) ��������
		mov	ds,ax
		mov	es,ax
		mov	ax,stack_seg
		mov	bx,stack_l
		mov	ss,ax
		mov	sp,bx

		;����������������� ������� ���������� ������� �� ������ 8 - ��������, �� �������� ���������� ����������� ����������� ���������� � ��������
		mov	al, 11h					; �������������
		out	20h, al
		mov	al, 8						; �������� ��������
		out	21h, al
		mov	al, 4						; ��������� �������, "��� - �������!"
		out	21h, al
		mov	al, 1
		out	21h, al

		;��������������� ����������������� ����������� ����� ����� ������������ ����������
		mov	al, master
		out	21h, al
		mov	al, slave
		out	0A1h, al

		; ��������� ������� ������������ ���������� ��������� ������
		lidt	fword ptr idtr_real

		; ��������� ������� ������������� ����������
		in	al,70h
		and	al,07FH
		out	70h,al

    ; � ����� �����������
		sti

		; ��� � ������ ������ ��������� ��������� ����� int 21h �� ������� 4Ch
		mov	ah,4Ch
		int	21h

RM_seg_size = $-start 	; ��������� �������, ��������� ����� ������ ��� ��������
RM_seg	ENDS
END start

; Happy End
; �� ��� ���? ���� ��, �� ����� ��� ��������� ��� ���� ���, �� ���� ������ �� �����, ���������� C:
