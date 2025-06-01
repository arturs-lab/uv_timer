	TITLE	"UV eraser timer"
	LIST	P = PIC16C54
;	INCLUDE <P16C54.INC>

ind0    equ     00h             ; index register
rtcc    equ     01h             ; RTTC register
pc	equ	02h		; program counter
status  equ     03h             ; status register
fsr     equ     04h             ; file select register
porta   equ     05h             ; port A
portb   equ     06h             ; port B
intcon  equ     0bh             ; interrupt control register
opt     equ     01h             ; option register
trisa   equ     05h
trisb   equ     06h
rp0     equ     5
W	equ	0
F       equ     1
Z	equ	2		; zero flag bit


min	equ	0ch		; minute counter
sec	equ	min + 1		; seconds counter
kbdstat	equ	sec + 1		; keyboard status
kbdtmr	equ	kbdstat + 1	; keyboard timer
tmp	equ	kbdtmr + 1	; temporary register
led0	equ	tmp + 1		; display code for LED 0
led1	equ	led0 + 1	; display code for LED 1
lastcnt	equ	led1 + 1	; previous rtcc value


optval	equ	B'00100000'	; value of option register
trisa_val equ	B'00010100'	; value of tris A register

	org	01ffh
begin	goto	start

	org	000h

start	clrw
        clrf    intcon          ; disable interrupts
	clrf	porta		; reset port a
	bsf	porta,0		; set bit 0
        clrf    portb           ; reset port b
        bsf     status,rp0	; select upper memory bank
	movlw	optval
        movwf   opt
        clrf    trisa
        bsf     trisa,2         ; set bit 2 as input
        clrf    trisb
        bsf     trisb,7         ; set bit 7 as input
        bcf     status,rp0	; select lower memory bank
reset
	clrf	min
	clrf	sec
	clrf	kbdstat
	clrf	kbdtmr
	clrf	led0
	clrf	led1
	clrf	lastcnt
	clrf	rtcc

main	movf	rtcc,w		; get current RTCC value
	subwf	lastcnt,W	; see if it changed
	btfsc	status,Z	; yes
;	btfss	status,Z	; for testing
	goto	main		; no, continue loop
	movf	rtcc,W
	movwf	lastcnt
	sublw	1eh		; see if rtcc reached 30 cycles
	btfss	status,Z	; reset RTCC and decrement time counters if yes
;	btfsc	status,Z	; for testing
	goto	kbdscan		; otherwise just scan keyboard and update display

	clrf	rtcc		; reset RTCC
	movf	sec,W		; fetch seconds counter
	btfss	status,Z	; see if already zero
	goto	secdecr		; no, just decrement seconds
	movlw	.59		; set seconds to 59 (dec)
	movwf	sec		; store in counter before adjusting minutes

	movf	min,W		; fetch minutes counter after seconds went past 0
	btfsc	status,Z	; see if already zero
	bcf	porta,3		; yes, turn off the lamp
	goto	disp_adj	; scan the keyboard and update the display

	decf	min,F		; decrement minutes
	goto	disp_adj	; scan the keyboard and update the display

secdecr	decf	sec,F		; decrement seconds counter

disp_adj			; adjust the display data
	movf	min,W		; get minute count
	btfss	status,Z	; see if it reached zero
	goto	getcode		; no, continue
	movf	sec,W		; yes, display seconds instead
getcode	movwf	tmp		; save data for later
	call	led_code	; convert lower digit to display code
	movwf	led0		; store in display memory
	swapf	tmp,W		; fetch second digit
	call	led_code	; convert
	movwf	led1		; store

kbdscan	
	; add tray switch test here

	clrf	portb		; turn off display
	movf	porta,W		; fetch display enable bits
	btfsc	portb,7		; see if key pushed
	goto	key1
	iorwf	kbdstat,F	; set bit for currently pushed key
key1	xorlw	03h		; reverse bits 0 and 1 of port A
	movwf	porta
	btfsc	portb,7
	goto	display
	iorwf	kbdstat,W	; set bit for currently pushed key
	andlw	03h		; strip extra bits
	movwf	kbdstat		; store result in status byte
	btfsc	status,Z	; check if any keys pressed
	goto	display		; no, display data
	incf	kbdtmr,F	; increment keyboard counter
	btfss	kbdtmr,4	; see if counted 16 periods
	goto	display		; no, continue debouncing keys
; we have a key(s) pressed!
k_press
	decf	kbdstat,F
	btfss	status,Z	; was it key #1?
	goto	key2		; no, check key #2
	incf	min,F		; yes, increment minutes counter
	goto	display
key2	decf	kbdstat,F
	btfss	status,Z	; was it key #2?
	goto	key3		; no, it's both! reset counters
	movlw	.10		; add 10(dec) to minutes counter
	addwf	min,F
	goto	display
key3	goto	reset


display
	btfss	porta,0		; see which digit is to be displayed
	goto	disp1
	movf	led0,W
	movwf	portb
	goto	done
disp1	movf	led1,W
	movwf	portb

done	goto	main

; this code returns in W 7 segment code for
; hex digit passed to it in W

led_code
	andlw	B'00001111'
	addwf	pc,F
	retlw	B'11000000'	; code for 0
	retlw	B'11111100'	; code for 1
	retlw	B'10010010'	; code for 2
	retlw	B'10011000'	; code for 3
	retlw	B'10101100'	; code for 4
	retlw	B'10001001'	; code for 5
	retlw	B'10000001'	; code for 6
	retlw	B'11011100'	; code for 7
	retlw	B'10000000'	; code for 8
	retlw	B'10001000'	; code for 9
	retlw	B'10000100'	; code for a
	retlw	B'10100001'	; code for b
	retlw	B'11000011'	; code for c
	retlw	B'10110000'	; code for d
	retlw	B'10000011'	; code for e
	retlw	B'10000111'	; code for f


	END

