irq_init
	sei
	lda #$01
	sta $d019
	sta $d01a
	lda #$1b
	sta $d011
	lda #$7f
	sta $dc0d
	lda #$31
	sta $d012
	lda #<IRQ
	sta $0314
	lda #>IRQ
	sta $0315
	cli
	rts
IRQ
	inc $d019
	lda #$31
	sta $d012
	dec $d020
	
	jsr CARD_POLL
	beq IRQx
	jsr IRQ_PACKET
IRQx	
	
	inc $d020
	jmp $ea31

	
IRQ_PACKET
	jsr CARD_READ
	jsr MAC_PROCESS	
	rts
	
killirq
	sei
	inc $d019 ;ack any pending vic irq
	jsr $ff81
	lda #$00
	sta $d020
	sta $d021
	lda #$31
	sta $0314
	lda #$ea
	sta $0315
	cli
	jsr prns
	dc.b CRLF,14,"nETirq kILLED.",CRLF,0
	rts
	