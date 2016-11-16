;-----------------------------------
; STALE
;-----------------------------------
TIME	EQU		50					; odpowiada za 50ms, ktore liczy timer
LOAD	EQU		(65536-TIME*1000)	; odpowiada za liczbe, ktora nalezy wsadzic do timera po wyzerowaniu
COUNT	EQU		30H					; nazwanie miejsca w pamieci, w którym przechowujemy licznik 0,05s
SEC		EQU		31H					; nazwanie miejsca w pamieci, w którym przechowujemy licznik sekund
MIN		EQU		32H					; nazwanie miejsca w pamieci, w którym przechowujemy licznik minut
HRS		EQU		33H					; nazwanie miejsca w pamieci, w którym przechowujemy licznik godzin
ORG 0
		JMP 	START				; skok do startu, 
									; najpierw zdefiniujemy obsluge przerwania
									
;-----------------------------------
; OBSLUGA PRZERWANIA
; na liczniku t0
;-----------------------------------
ORG 0BH
		PUSH	ACC					; zapamietanie - przeniesienie na stos
		PUSH	PSW					; akumulatora i banku rejestrow

		MOV		TL0, #LOW(LOAD)		; do licznika kopiujemy wartosc, od ktorej ma odmierzac czas
		MOV		TH0, #HIGH(LOAD)	; osobno starsza i mlodsza czesc kopiujemy

		DJNZ 	COUNT, CONTINUE		; zmiejszamy COUNT i skaczemy do CONTINUE, jesli nie zero
		MOV 	COUNT, #20			; jesli jednak zero, przywracamy mu wartosc 20
		INC 	SEC					; zwiekszamy licznik sekund
		MOV		A, SEC				; dla porownania kopiujemy jego wartosc do akumulatora
		CJNE	A, #60,	CONTINUE	; i jesli nie jest rowny 60, to skaczemy do CONTINUE
		MOV		SEC, #0				; jesli jednak 60, to zmieniamy na 0
		INC 	MIN					; zwiekszamy licznik minut
		MOV		A, MIN				; dla porownania kopiujemy jego wartosc do akumulatora
		CJNE	A, #60,	CONTINUE	; i jesli nie jest rowny 60, to skaczemy do CONTINUE
		MOV		MIN, #0				; jesli jednak 60, to zmieniamy na 0
		INC		HRS					; zwiekszamy licznik godzin
		MOV		A, HRS				; dla porownania kopiujemy jego wartosc do akumulatora
		CJNE	A, #24, CONTINUE	; i jesli nie jest rowny 24, to skaczemy do CONTINUE
		MOV		HRS, #0				; jesli jednak 24, to zmieniamy na 0
		
CONTINUE:
		POP		PSW					; prywracamy ze stosu bank rejestrow i akumulator
		POP		ACC					; w odwrotnej kolejnosci, niz wrzucalismy na stos
		RETI						; koniec przerwania
		
;-----------------------------------
; WLASCIWY PROGRAM
;-----------------------------------
START:
		LCALL	INIT_TIMER			; na poczatek inicjujemy timer

LOOP:	MOV		A,SEC				; nieskonczona petla do wyswietlania sekund, minut i godzin
									; sekundy  do akumulatora
		CPL		A					; zanegowane
		MOV		P1,A				; i wyswietlone na P1
		MOV		A,MIN				; minuty skopiowane do akumulatora
		CPL		A					; zanegowane
		MOV		P2,A				; i wyswietlone na P2
		MOV		A,HRS				; minuty skopiowane do akumulatora
		CPL		A					; zanegowane
		MOV		P3,A				; i wyswietlone na P3
		
		SJMP	LOOP				; powrót do poczatku petli

;-----------------------------------
INIT_TIMER:
		MOV		SEC, #0				; zerowanie licznika sekund
		MOV		MIN, #0				; zerowanie licznika minut
		MOV		HRS, #0				; zerowanie licznika godzin
		MOV		COUNT, #20			; w liczniku 20 - 20*50ms=1s


		CLR		TR0					; czyscimy TR0
		MOV		TMOD, #1			; ustawiamy tryb na 1
		MOV		TL0, #LOW(LOAD)		; do licznika kopiujemy wartosc, od ktorej ma odmierzac czas
		MOV		TH0, #HIGH(LOAD)	; osobno starsza i mlodsza czesc kopiujemy

		SETB	ET0					; ustawiamy bity ET0
		SETB	EA					; i EA

		CLR		TF0					; czyscimy flage TF0
		SETB	TR0					; startujemy timer T0
		
		RET

END
