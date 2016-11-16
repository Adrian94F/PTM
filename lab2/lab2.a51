ORG 0
	MOV		R0,	#30H		; w R0 ustawiamy wartosc 30hex - poczatek bloku zrodlowego
	MOV		R1, #40H		; w R1 40hex - poczatek docelowego
	MOV		R2, #5			; w R2 5 - dlugosc bloku pamieci do przekopiowania
	LCALL	iram_iram		; wywolujemy odpowiednia procedure

	MOV		R0, #30H		; w R0 ustawiamy wartosc 30hex - poczatek bloku zrodlowego
	MOV		DPTR, #8000H	; w DPTR 8000hex - poczatek docelowego
	MOV		R2, #5			; w R2 5 - dlugosc bloku pamieci do przekopiowania
	LCALL 	iram_xram		; wywolujemy odpowiednia procedure
	
	LCALL	count_not_zeros	; wywolujemy procedure liczaca niezerowe elementy w pamieci
							;  od adresu 30 
							;  w rejestrze R2 pozostanie ich liczba
							
	MOV		R3, #80H		; w R3 i R4 ustawiamy 
	MOV		R4, #0H			;  poczatek bloku zrodlowego
	MOV		R5, #0		; w R3 i R4 ustawiamy 
	MOV		R6, #5H			;  poczatek bloku docelowego
	MOV		R2, #0EEH			; w R2 5 - dlugosc bloku pamieci do przekopiowania
	LCALL 	xram_xram		; wywolujemy odpowiednia procedure
	
	SJMP	$				; "skok" w miejsce tego polecenia - wykonuje sie bez przerwy

;----------------------------------------------------------------
; kopiowanie bloku w obrebie pamieci wewnetrznej
; R0 - src	R1 - dest	R2 - cnt
;
; nie mozemy kopiowac bezposrednio z pamieci 
; do pamieci, wiec posluzymy sie akumulatorem
;----------------------------------------------------------------
iram_iram:
loopii:
	MOV		A, @r0			; wartosc pod adresem zrodlowym w R0 skopiowana do A
	MOV		@R1, A			; wartosc z A skopiowana pod adres w R1
	INC 	R0				; inkrementacja R0 i R1
	INC		R1				;  - adresow w pamieci
	DJNZ	R2, loopii		; dekrementacja R2, jesli nie 0, skok na poczatek petli	
	ret
;----------------------------------------------------------------
; kopiowanie bloku z pamieci wewnetrznej do zewnetrznej
; R0 - src	DPTR - dest	R2 - cnt
;
; nie mozemy kopiowac bezposrednio z pamieci wewnetrznej
; do zewnetrznej, wiec posluzymy sie akumulatorem
;----------------------------------------------------------------
iram_xram:
loopix:
	MOV		A, @R0			; wartosc pod adresem zrodlowym w R0 skopiowana do A
	MOVX	@DPTR, A		; wartosc z A skopiowana pod adres w DPTR
	INC		R0				; inkrementacja R0 i DPRT
	INC		DPTR			;  - adresow w pamieciach wewnetrznej i zewnetrznej
	DJNZ	R2, loopix		; dekrementacja R2, jesli nie 0, skok na poczatek petli
	ret
;----------------------------------------------------------------
; liczenie niezerowych w pamieci wewnetrznej
; R0 - addr	R2 - cnt	
;----------------------------------------------------------------
count_not_zeros:
	MOV		R0, #30			; idziemy po pamieci od 30
	MOV		R2, #0			; poczatkowa wartosc licznika wynosi 0
loopc:
	MOV		A, @R0			; wartosc pod adresem w R0 skopiowana do A
	JZ		continue		; jesli = 0, nic nie rob; jesli nie, to:
	INC 	R2				;  zwieksz licznik
continue:
	INC		R0				; inkrementacja adresu w R0
	MOV 	A, R0			; skopiowanie adresu do akumulatora
	JNZ		loopc			; petla sie wykonuje, poki adres sie nie przepelni
							;  i z powroten nie wyzeruje
	ret
;----------------------------------------------------------------
; kopiowanie bloku w obrebie pamieci zewnetrznej
; R3|R4 - src	R5|R6 - dest	R2 - cnt
;----------------------------------------------------------------
xram_xram:
loopxx:
	MOV		DPH, R3			; z R3 i R4 kopiujemy adres do DPTR
	MOV		DPL, R4			;  DPTR jest dwubajtowy, dzieli sie na DPH i DPL
	MOVX	A, @DPTR		; wartosc pod adresem zrodlowym w DPTR skopiowana do A
	INC		DPTR			; inkrementujemy adres w DPTR
	MOV		R3, DPH			; zwracamy adres w DPTR do R3 i R4
	MOV		R4, DPL
	
	MOV		DPH, R5			; z R5 i R6 kopiujemy adres do DPTR
	MOV		DPL, R6
	MOVX	@DPTR, A		; wartosc z A skopiowana pod adres docelowy w DPTR
	INC		DPTR			; inkrementujemy adres w DPTR
	MOV		R5, DPH			; zwracamy adres w DPTR do R3 i R4
	MOV		R6, DPL	
	
	DJNZ	R2, loopxx		; dekrementacja R2, jesli nie 0, skok na poczatek petli
	ret
END