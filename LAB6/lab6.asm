$NOMOD51
$include (reg517.inc) 
WR_CMD	EQU 	0FF2CH	  		; zapisu komendy
WR_DAT	EQU	 	0FF2DH	  		; zapisu danych
RD_ST	EQU	 	0FF2EH	 		; odczytu stanu
RD_DAT	EQU 	0FF2FH			; odczytu danych
ORG 0
main:
LCALL	init_lcd				; inicjalizacja LCD
main_loop:
LCALL keyboard_check
MOV A, #0
LCALL lcdGoTo
MOV A, B
LCALL zamien
LCALL wrDat
JMP main_loop

;-------------------------------
; KEYBOARD CHECK
; B - zwraca numer klawisza
;-------------------------------
keyboard_check:
	;SPRAWDZANIE 1szego wiersza	
	MOV P5, #01111111B
	MOV A, P7
	CJNE A, #0F7H, dwojka
	MOV B, #0
	;SPRAWDZANIE 2giego wiersza
check2nd:
	MOV P5, #10111111B		
	MOV A, P7
	CJNE A, #0F7H, piatka
	MOV B, #4
	;SPRAWDZANIE 3ciego wiersza
check3rd:
	MOV P5, #11011111B		
	MOV A, P7	
	CJNE A, #0F7H, osemka
	MOV B, #8
	;SPRAWDZANIE 4tego wiersza
check4th:
	MOV P5, #11101111B			
	MOV A, P7
	CJNE A, #0F7H, zero
	MOV B, #12
	back:
	RET
dwojka:
	CJNE A, #0FBH, trojka
	MOV B, #1
	RET
trojka:
	CJNE A, #0FDH, litera_A
	MOV B, #2
	RET
litera_A:
	CJNE A, #0FEH, check2nd
	MOV B, #3
	RET
piatka:
	CJNE A, #0FBH, szostka
	MOV B, #5
	RET
szostka:
	CJNE A, #0FDH, litera_B
	MOV B, #6
	RET
litera_B:
	CJNE A, #0FEH, check3rd
	MOV B, #7
	RET
osemka:
	CJNE A, #0FBH, dziewiatka
	MOV B, #9
	RET
dziewiatka:
	CJNE A, #0FDH, litera_C
	MOV B, #10
	RET
litera_C:
	CJNE A, #0FEH, check4th
	MOV B, #11
	RET
zero:
	CJNE A, #0FBH, hasz
	MOV B, #13
	RET
hasz:
	CJNE A, #0FDH, litera_D
	MOV B, #14
	RET
litera_D:
	CJNE A, #0FEH, back
	MOV B, #15
	RET
zamien:
ADD A, #'0'
RET
;---------------------------------------
; INIT LCD
;---------------------------------------
init_lcd:
	MOV		A, #038H
	LCALL	wrCmd
	MOV		A, #01H			
	LCALL	wrCmd
	RET
;---------------------------------------
; GOTO	 A - POZYCJA KURSORA
;---------------------------------------
lcdGoTo:
	SETB	ACC.7						; modyfikacja 7 bitu dla komendy 
										; set DD RAM ADDress
	LCALL	cBusy						; zaczekanie, az wyswietlacz nei bedzie zajety
	LCALL	wrCmd						; wyslanie komendy
	RET
;---------------------------------------
; SPRAWDZENIE CZY ZAJETY
;---------------------------------------
cBusy:
	PUSH 	ACC							; zachowanie akumulatora
cBusy_w:
	MOVX	A, @DPTR					; sprawdenie czy zajety przez
	JB		ACC.7, cBusy_w				;  sprawdzenie 7 bitu stanu
	POP		ACC
	RET
;---------------------------------------
; WYSLANIE KOMENDY	  A - komenda
;---------------------------------------
wrCmd:
	PUSH	DPL							; zachowanie dptr
	PUSH	DPH
	MOV		DPTR, #RD_ST				; RD_ST do dptr, by odczytac stan
	LCALL 	cBusy						; i sprawdzenie, czy zajety
	MOV		DPTR, #WR_CMD   			; WR_CMD do dptr
	MOVX	@DPTR, A					; komenda z akumulatora pod adres z dptr
	POP		DPH
	POP		DPL
	RET
;---------------------------------------
; WYSLANIE DANYCH	  A - dane
;---------------------------------------
wrDat:
	PUSH	DPL	
	PUSH	DPH
	MOV		DPTR, #RD_ST
	LCALL 	cBusy
	MOV		DPTR, #WR_DAT				; to samo, co powyzej, tylko zamiast
	MOVX	@DPTR, A					; WR_CMD jest WR_DAT
	POP		DPH
	POP		DPL
	RET
;---------------------------------------
; ODCZYT STANU	  A - stan
;---------------------------------------
rdCmd:
	PUSH	ACC							; zachowanie akumulatora
	MOV		DPTR, #RD_ST				; RD_ST do dptr
	LCALL 	cBusy						; sprawdzenie, czy zajety
	POP		ACC
	MOV		DPTR, #RD_ST				; znów RD_ST
	MOVX	A, @DPTR					; stan do akumulatora
	RET

END
	