; this code returns in W 7 segment code for
; hex digit passed to it in W

led_code
	andlw	B'00001111'
	addwf	PC
	retlw	B'00111111'	; code for 0
	retlw	B'00000011'	; code for 1
	retlw	B'01101101'	; code for 2
	retlw	B'01100111'	; code for 3
	retlw	B'01010011'	; code for 4
	retlw	B'01110110'	; code for 5
	retlw	B'01111110'	; code for 6
	retlw	B'00100011'	; code for 7
	retlw	B'01111111'	; code for 8
	retlw	B'01110111'	; code for 9
	retlw	B'01111011'	; code for a
	retlw	B'01011110'	; code for b
	retlw	B'00111100'	; code for c
	retlw	B'01001111'	; code for d
	retlw	B'01111100'	; code for e
	retlw	B'01111000'	; code for f

