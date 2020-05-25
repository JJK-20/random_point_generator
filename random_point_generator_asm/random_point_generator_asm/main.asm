includelib libcmt.lib
includelib legacy_stdio_definitions.lib

.model flat
.686

extern _ExitProcess@4 : PROC
extern __read : PROC 
extern _printf : PROC

public _main
public init_random_point_generator
public random_point_generator
public _random_number_shift_register

.data
;constans for main program and some variables for outputting uint32 numbers and waiting for enter pressed
get_enter_buffer db 1
uint32_printf_output db "%d     ", 0
endline db 10,0
press_enter_msg db "press enter to continue", 10, 0
ITERATION_COUNTER_END EQU 100000

;constans and variables for shift register
P_CONST EQU 7
Q_CONST EQU 3
INIT_VECTOR_LENGTH_CONST EQU 7
NUMBER_BIT_LENGTH_CONST EQU 32
actual_starting_vector dd 00000045h

;constans and variables for random point generator
POINTS_PROBABILITY_CONST dd 0, 0, 0.1, 0.1, 0.2, 0, 0, 0.2, 0, 0, 0.3, 0, 0, 0.05, 0, 0.05
RAND_MAX_CONST dd 07fffffffh
SIZE_X_CONST EQU 4
SIZE_Y_CONST EQU 4
points_x_probability dd SIZE_X_CONST  dup (0)
points_y_probability dd SIZE_X_CONST*SIZE_Y_CONST dup (0)
point_frequency dd SIZE_X_CONST*SIZE_Y_CONST dup(0)

.code

_random_number_shift_register PROC
	push ebp
	mov ebp,esp
	push ebx
	push ecx

	;calculating formula bi = bi-p  XOR  bi-q	where b is bit in number
	mov eax,actual_starting_vector
	;we set 2 bits in register which will be operands for XOR first
	mov ebx,00000001h
	shl ebx, INIT_VECTOR_LENGTH_CONST - P_CONST
	mov edx,00000001h
	shl edx,INIT_VECTOR_LENGTH_CONST - Q_CONST
	add ebx,edx

	mov ecx,INIT_VECTOR_LENGTH_CONST
	generate_number:
	cmp ecx,NUMBER_BIT_LENGTH_CONST
	je generate_numberend
		;instead of XOR operation of 2 bits we can do AND operation
		;with actual_vector and vector with bits to xor
		;if resault of operation is equal to 0 or equal to vector with bits to xor
		;it's mean XOR operation resault will be 0
		;else XOR operation resault will be 1
		mov edx,eax
		and edx,ebx
		cmp edx,0
		je setzero
		cmp edx,ebx
		je setzero
		bts eax,ecx
		jmp setnotzero
		setzero:
		btr eax,ecx
		setnotzero:
		shl ebx,1	;shift vector with bits to xor by one
	inc ecx
	jmp generate_number
	generate_numberend:
	mov actual_starting_vector,eax
	shr actual_starting_vector,NUMBER_BIT_LENGTH_CONST - INIT_VECTOR_LENGTH_CONST

	pop ecx
	pop ebx
	pop ebp
	ret
_random_number_shift_register ENDP

init_random_point_generator PROC
	push esi
	push edi
	

	finit 

	mov ecx,0
	x_prob_compare_with_x:

		fldz

		mov edx,0
		x_prob_compare_with_y:

		mov esi,ecx
		add esi,esi
		add esi,esi

		mov edi,edx
		add edi,edi
		add edi,edi
		fld dword ptr [POINTS_PROBABILITY_CONST + SIZE_Y_CONST * esi + edi]
		faddp

		inc edx
		cmp	edx, SIZE_Y_CONST
		jb x_prob_compare_with_y

		fstp dword ptr [points_x_probability + ecx*4]


	inc ecx
	cmp	ecx, SIZE_X_CONST
	jb x_prob_compare_with_x


	mov ecx,0
	y_prob_compare_with_x:

		mov edx,0
		y_prob_compare_with_y:

		mov esi,ecx
		add esi,esi
		add esi,esi

		mov edi,edx
		add edi,edi
		add edi,edi
		fld dword ptr [POINTS_PROBABILITY_CONST + SIZE_Y_CONST * esi + edi]
		fld dword ptr [points_x_probability + ecx*4]
		fdivp
		fstp dword ptr [points_y_probability + SIZE_Y_CONST * esi + edi]

		inc edx
		cmp	edx, SIZE_Y_CONST
		jb y_prob_compare_with_y

	inc ecx
	cmp	ecx, SIZE_X_CONST
	jb y_prob_compare_with_x


	pop edi
	pop esi
	ret
init_random_point_generator ENDP

random_point_generator PROC
	push ebp
	mov ebp,esp
	push esi
	push edi
	push ebx

	;random float - esi
	call _random_number_shift_register
	and eax, 07fffffffh
	push eax
	fild dword ptr [esp]
	fild RAND_MAX_CONST
	fdivp
	fstp dword ptr [esp]
	pop esi

	mov ecx,0
	compare_with_prob_x:
		;here we compare floats, sign bit is always set on 0
		;if exponent (more significant bits) is greater, then number is greater
		;in case of exponent equal
		;if mantysa (less significant bits) is greater, then number is greater
		cmp	esi,[points_x_probability + ecx*4]
		jb compare_with_prob_x_end

			push esi
			fld dword ptr [esp]
			fld dword ptr [points_x_probability + ecx*4]
			fsubp
			fstp dword ptr [esp]
			pop esi

		inc ecx
	jmp compare_with_prob_x
	compare_with_prob_x_end:



	;random float - ebx
	push ecx ;we use that register
	call _random_number_shift_register
	pop ecx ;we use that register
	and eax, 07fffffffh
	push eax
	fild dword ptr [esp]
	fild RAND_MAX_CONST
	fdivp
	fstp dword ptr [esp]
	pop ebx

	mov edx,0
	compare_with_prob_y:
		;here we compare floats, sign bit is always set on 0
		;if exponent (more significant bits) is greater, then number is greater
		;in case of exponent equal
		;if mantysa (less significant bits) is greater, then number is greater
		mov esi,ecx
		add esi,esi
		add esi,esi

		mov edi,edx
		add edi,edi
		add edi,edi
		cmp	ebx, [points_y_probability + SIZE_Y_CONST * esi + edi]
		jb compare_with_prob_y_end

			push ebx
			fld dword ptr [esp]
			mov esi,ecx
			add esi,esi
			add esi,esi

			mov edi,edx
			add edi,edi
			add edi,edi
			fld dword ptr [points_y_probability + SIZE_Y_CONST * esi + edi]
			fsubp
			fstp dword ptr [esp]
			pop ebx

		inc edx
	jmp compare_with_prob_y
	compare_with_prob_y_end:

	mov esi,ecx
	add esi,esi
	add esi,esi

	mov edi,edx
	add edi,edi
	add edi,edi
	inc [point_frequency + SIZE_Y_CONST * esi + edi]

	pop ebx
	pop esi
	pop edi
	pop ebp
	ret
random_point_generator ENDP

_main PROC

	call init_random_point_generator

	;100000 iteration of generating pairs of numbers
	mov ecx,ITERATION_COUNTER_END
	loop1:
		push ecx
		call random_point_generator
		pop ecx
	loop loop1


	mov esi, OFFSET point_frequency
	mov ecx,0
	print_x:

		mov edx,0
		print_y:

			push ecx;we use that value
			push edx;we use that value
			mov eax,[esi]
			push eax
			push OFFSET uint32_printf_output
			call _printf
			add esp,8
			pop edx;we use that value
			pop ecx;we use that value
			add esi,4

		inc edx
		cmp	edx, SIZE_Y_CONST
		jb print_y


		push ecx;we use that value
		push edx;we use that value
		push OFFSET endline
		call _printf
		add esp,4
		pop edx;we use that value
		pop ecx;we use that value

	inc ecx
	cmp	ecx, SIZE_X_CONST
	jb print_x
	


	;waiting for pressing enter
	push OFFSET press_enter_msg
	call _printf
	add esp,4
	push dword ptr 1
	push dword ptr OFFSET get_enter_buffer
	push dword ptr 0
	call __read
	add esp,12



	push 0
	call _ExitProcess@4

_main ENDP

END