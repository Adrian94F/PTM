;---------------------------------------
; stale
;---------------------------------------
										; adresy do:
WR_CMD	EQU 0FF2CH	  					; zapisu komendy
WR_DAT	EQU 0FF2DH	  					; zapisu danych
RD_ST	EQU 0FF2EH	 					; odczytu stanu
RD_DAT	EQU 0FF2FH						; odczytu danych

ORG 0
start:
	lcall init
	MOV		A, #'H'
	LCALL wrDat
	MOV		A, #'e'
	LCALL wrDat
	MOV		A, #'y'
  	LCALL wrDat
	MOV		A, #' '
	LCALL wrDat
	MOV		A, #':'
	LCALL wrDat
	MOV		A, #'-'
	LCALL wrDat
	MOV		A, #')'
	LCALL wrDat

	MOV		DPTR, #hello
	LCALL 	putStr
	SJMP	$

;---------------------------------------
; PUT STRING	 DPTR - string, R1- licznik
;---------------------------------------
putStr:
	PUSH	ACC							; zachowanie zawartosci akumulatora
putStrLoop:
	CLR		A							; wyzerowanie akumulatora
	MOVC	A,@A+DPTR					; skopiowanie elementu spod adresu w dptr
	JZ		continue					; jesli 0, to koniec
	LCALL	wrDat						; wywolanie wypisania na ekranie znaku
	INC		DPTR						; zwiekszenie adresu w dptr
	JMP		putStrLoop					; powrot do oczatku petli
continue:	
	POP ACC
	RET
;---------------------------------------
; GOTO
;---------------------------------------
lcdGoTo:
	SETB ACC.7							; modyfikacja 7 bitu dla komendy 
										; set DD RAM Address
	LCALL cBusy							; zaczekanie, az wyswietlacz nei bedzie zajety
	LCALL wrCmd							; wyslanie komendy
	RET
;---------------------------------------
; INIT LCD
;---------------------------------------
init:
	MOV		A, #038H
	LCALL	wrCmd
	MOV		A, #01H			
	LCALL	wrCmd
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

hello:
	DB 'Never gonna give you up!',0

END