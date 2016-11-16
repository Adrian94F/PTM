;-----------------------------------
; STALE
;-----------------------------------
									; adresy do:
WR_CMD	EQU 	0FF2CH	  			; zapisu komendy
WR_DAT	EQU	 	0FF2DH	  			; zapisu danych
RD_ST	EQU	 	0FF2EH	 			; odczytu stanu
RD_DAT	EQU 	0FF2FH				; odczytu danych
TIME	EQU		50					; odpowiada za 50ms, ktore liczy timer
LOAD	EQU		(65536-TIME*1000)	; odpowiada za liczbe, ktora nalezy wsadzic do timera po wyzerowaniu

COUNT	EQU		30H					; nazwanie miejsca w pamieci, w którym przechowujemy licznik 0,05s
SEC		EQU		31H					; nazwanie miejsca w pamieci, w którym przechowujemy licznik sekund
MIN		EQU		32H					; nazwanie miejsca w pamieci, w którym przechowujemy licznik minut
HRS		EQU		33H					; nazwanie miejsca w pamieci, w którym przechowujemy licznik godzin

SEC_F	EQU		0

ORG 0
	LJMP	main
;-----------------------------------
; OBSLUGA PRZERWANIA
; na liczniku t0
;-----------------------------------
ORG 0BH
	PUSH	ACC						; zapamietanie - przeniesienie na stos
	PUSH	PSW						; akumulatora i banku rejestrow

	MOV		TL0, #LOW(LOAD)			; do licznika kopiujemy wartosc, od ktorej ma odmierzac czas
	MOV		TH0, #HIGH(LOAD)		; osobno starsza i mlodsza czesc kopiujemy

	DJNZ 	COUNT, CONTINUE			; zmiejszamy COUNT i skaczemy do CONTINUE, jesli nie zero
	MOV 	COUNT, #20				; jesli jednak zero, przywracamy mu wartosc 20
	INC 	SEC						; zwiekszamy licznik sekund
	SETB	SEC_F
	MOV		A, SEC					; dla porownania kopiujemy jego wartosc do akumulatora
	CJNE	A, #60,	CONTINUE		; i jesli nie jest rowny 60, to skaczemy do CONTINUE
	MOV		SEC, #0					; jesli jednak 60, to zmieniamy na 0
	INC 	MIN						; zwiekszamy licznik minut
	MOV		A, MIN					; dla porownania kopiujemy jego wartosc do akumulatora
	CJNE	A, #60,	CONTINUE		; i jesli nie jest rowny 60, to skaczemy do CONTINUE
	MOV		MIN, #0					; jesli jednak 60, to zmieniamy na 0
	INC		HRS						; zwiekszamy licznik godzin
	MOV		A, HRS					; dla porownania kopiujemy jego wartosc do akumulatora
	CJNE	A, #24, CONTINUE		; i jesli nie jest rowny 24, to skaczemy do CONTINUE
	MOV		HRS, #0					; jesli jednak 24, to zmieniamy na 0
		
CONTINUE:
	POP		PSW						; prywracamy ze stosu bank rejestrow i akumulator
	POP		ACC						; w odwrotnej kolejnosci, niz wrzucalismy na stos
	RETI							; koniec przerwania

;-----------------------------------
; MAIN
;-----------------------------------
main:
	LCALL 	INIT_TIMER
	LCALL	init					; na poczatek inicjujemy timer

main_loop:
	JNB		SEC_F,$
	CLR		SEC_F
	LCALL	showTime
	SJMP	main_loop				; powrót do poczatku petli

;-----------------------------------
; SHOW TIME
;-----------------------------------
showTime:
	MOV		A, HRS					; dla porownania kopiujemy jego wartosc do akumulatora
	LCALL	showHours
	MOV		A, MIN					; dla porownania kopiujemy jego wartosc do akumulatora
	LCALL	showMinutes
	MOV		A, SEC					; dla porownania kopiujemy jego wartosc do akumulatora
	LCALL	showSeconds
	RET

;-----------------------------------
; SHOW SECONDS	A - SEKUNDY
;-----------------------------------
showSeconds:
	PUSH	ACC
	CJNE	A, #60, continueSec
	MOV		A, #0
continueSec:
	MOV		B, #10					; dzielimy sekundy przez 10
	DIV		AB						; otrzymamy dwie liczby-  pozycje dziesiatek i jednosci
	ADD		A, #'0'
									; wyswiietlamy dziesiatki
	PUSH	ACC						
	MOV		A, #6
	LCALL	lcdGoTo					; kursor na 6 miejscu
	POP		ACC
	LCALL	wrDat
									; wyswietlamy  jednosci
	MOV		A, B
	ADD		A, #'0'
	PUSH	ACC
	MOV		A, #7
	LCALL	lcdGoTo					; kursor na 7 miejscu
	POP		ACC
	LCALL wrDat

	POP		ACC
	RET
;-----------------------------------
; SHOW MINUTES	A - MINUTY
;-----------------------------------
showMinutes:						; robimy analogicznie, jak sekundy, tylko dla innych miejsc
	PUSH	ACC

	CJNE	A, #60, continueMin
	MOV		A, #0
continueMin:
	
	MOV		B, #10
	DIV		AB	
	ADD		A, #'0'
	
	PUSH	ACC
	MOV		A, #3
	LCALL	lcdGoTo					; kursor na 3 miejscu
	POP		ACC
	LCALL	wrDat
	
	MOV		A, B
	ADD		A, #'0'
	PUSH	ACC
	MOV		A, #4
	LCALL	lcdGoTo					; kursor na 4 miejscu
	POP		ACC
	LCALL	wrDat

	POP		ACC
	RET
;-----------------------------------
; SHOW HOURS	A - GODZINY
;-----------------------------------
showHours:							; robimy analogicznie, jak sekundy, tylko dla innych miejsc
	PUSH ACC
	
	MOV		B, #10
	DIV		AB	
	ADD		A, #'0'
	
	PUSH	ACC
	MOV		A, #0
	LCALL	lcdGoTo					; kursor na 0 miejscu
	POP		ACC
	LCALL	wrDat
	
	MOV		A, B
	ADD		A, #'0'
	PUSH	ACC
	MOV		A, #1
	LCALL	lcdGoTo					; kursor na 1 miejscu
	POP		ACC
	LCALL	wrDat

	POP		ACC
	RET
;-----------------------------------
; INIT TIMER
;-----------------------------------
INIT_TIMER:
	MOV		SEC, #0					; zerowanie licznika sekund
	MOV		MIN, #0					; zerowanie licznika minut
	MOV		HRS, #0					; zerowanie licznika godzin
	MOV		COUNT, #20				; w liczniku 20 - 20*50ms=1s


	CLR		TR0						; czyscimy TR0
	MOV		TMOD, #1				; ustawiamy tryb na 1
	MOV		TL0, #LOW(LOAD)			; do licznika kopiujemy wartosc, od ktorej ma odmierzac czas
	MOV		TH0, #HIGH(LOAD)		; osobno starsza i mlodsza czesc kopiujemy

	SETB	ET0						; ustawiamy bity ET0
	SETB	EA						; i EA
	
	CLR		TF0						; czyscimy flage TF0
	SETB	TR0						; startujemy timer T0
	
	RET
;---------------------------------------
; GOTO	 A - POZYCJA KURSORA
;---------------------------------------
lcdGoTo:
	SETB	ACC.7					; modyfikacja 7 bitu dla komendy 
									; set DD RAM ADDress
	LCALL	cBusy					; zaczekanie, az wyswietlacz nei bedzie zajety
	LCALL	wrCmd					; wyslanie komendy
	RET
;---------------------------------------
; PUT STRING	 DPTR - string, R1- licznik
;---------------------------------------
putStr:
	PUSH	ACC						; zachowanie zawartosci akumulatora
putStrLoop:
	CLR		A						; wyzerowanie akumulatora
	MOVC	A,@A+DPTR				; skopiowanie elementu spod adresu w dptr
	JZ		continuelcd				; jesli 0, to koniec
	LCALL	wrDat					; wywolanie wypisania na ekranie znaku
	INC		DPTR					; zwiekszenie adresu w dptr
	JMP		putStrLoop				; powrot do oczatku petli
continuelcd:	
	POP		ACC
	RET
;---------------------------------------
; INIT LCD
;---------------------------------------
init:
	MOV		A, #038H
	LCALL	wrCmd
	MOV		A, #01H			
	LCALL	wrCmd
	MOV		DPTR, #czas
	LCALL	putStr
	RET
;---------------------------------------
; SPRAWDZENIE CZY ZAJETY
;---------------------------------------
cBusy:
	PUSH 	ACC						; zachowanie akumulatora
cBusy_w:
	MOVX	A, @DPTR				; sprawdenie czy zajety przez
	JB		ACC.7, cBusy_w			;  sprawdzenie 7 bitu stanu
	POP		ACC
	RET
;---------------------------------------
; WYSLANIE KOMENDY	  A - komenda
;---------------------------------------
wrCmd:
	PUSH	DPL						; zachowanie dptr
	PUSH	DPH
	MOV		DPTR, #RD_ST			; RD_ST do dptr, by odczytac stan
	LCALL 	cBusy					; i sprawdzenie, czy zajety
	MOV		DPTR, #WR_CMD   		; WR_CMD do dptr
	MOVX	@DPTR, A				; komenda z akumulatora pod adres z dptr
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
	MOV		DPTR, #WR_DAT			; to samo, co powyzej, tylko zamiast
	MOVX	@DPTR, A				; WR_CMD jest WR_DAT
	POP		DPH
	POP		DPL
	RET
;---------------------------------------
; ODCZYT STANU	  A - stan
;---------------------------------------
rdCmd:
	PUSH	ACC						; zachowanie akumulatora
	MOV		DPTR, #RD_ST			; RD_ST do dptr
	LCALL 	cBusy					; sprawdzenie, czy zajety
	POP		ACC
	MOV		DPTR, #RD_ST			; znów RD_ST
	MOVX	A, @DPTR				; stan do akumulatora
	RET

czas:
	DB '00:00:00',0					; do wypisania zerowego czasu na poczatek

END
	