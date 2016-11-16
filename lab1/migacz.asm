ORG 0
	mov R0, #5
	LCALL mainloop	
	
res:
	MOV A, r0
	MOV R1, A
	MOV R2, A
	ret
	
mainloop:
	LCALL res
	MOV A, P1
	DEC A
	MOV P1, A
	JZ krok
pokroku:
	LCALL delay
	LCALL res
	JMP mainloop
	ret
	
delay:
	MOV A, R0
	MOV R2, A
	LCALL delay2
	MOV A, R1
	DEC A
	MOV R1, A
	JNZ delay
	ret
delay2:
	MOV A, R2
	DEC A
	MOV R2, A
	JNZ delay2
	ret
krok:
	INC R3
	JMP pokroku 
END