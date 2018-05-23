;=============================================================================
;SETTINGS MENU
;=============================================================================
MSETTINGS
	jsr SETTINGS_drawscreen
MSET0	
	jsr GETIN
	beq MSET0
	cmp #$31
	bne MSET_0a
	jmp SET_IP
MSET_0a
	cmp #$32
	bne MSET_0b
	jmp SET_NETMASK
MSET_0b
	cmp #$33
	bne MSET_0c
	jmp SET_GATEWAY
MSET_0c
	cmp #$34
	bne MSET_0d
	jmp SET_MAC
MSET_0d
	cmp #$35
	bne MSET_0e
	jmp SET_SCFG
MSET_0e
	cmp #$36
	bne MSET_0f
	jmp SET_LCFG
MSET_0f
	cmp #$37
	beq MSETX ;exit, keeping IRQ
	jmp MSETTINGS
MSETX
	jmp MENU

SETTINGS_drawscreen
	jsr draw_header
	jsr prns
	dc.b "         settings",CRLF
	dc.b "      1. ",5,"cHANGE ip",CRLF
	dc.b "      ",158,"2. ",5,"cHANGE nETMASK",CRLF
	dc.b "      ",158,"3. ",5,"cHANGE gATEWAY",CRLF 
	dc.b "      ",158,"4. ",5,"cHANGE mac",CRLF
	dc.b "      ",158,"5. ",5,"sAVE CONFIG",CRLF
	dc.b "      ",158,"6. ",5,"lOAD CONFIG",CRLF
	dc.b "      ",158,"7. ",5,"qUIT TO MAIN",CRLF
	dc.b "      ",158,"SELECT:",5,0 
	rts	

SET_IP
	jsr $e544
	PRINT "eNTER NEW ip",CRLF
	jsr getip
	;verify
	PRINT CRLF
	lda #<gotip
	ldx #>gotip
	jsr printip
	PRINT ", "
	jsr yesno
	beq SET_IP
	cmp #$01
	beq SET_IP_a
	jmp SET_IP_x
SET_IP_a
	;copy gotip into pingip
	lda gotip
	sta CARD_IP
	lda gotip+1
	sta CARD_IP+1
	lda gotip+2
	sta CARD_IP+2
	lda gotip+3
	sta CARD_IP+3
SET_IP_x
	jmp MSETTINGS
	
SET_NETMASK
	jsr $e544
	PRINT "eNTER NEW NETMASK",CRLF
	jsr getip
	;verify
	PRINT CRLF
	lda #<gotip
	ldx #>gotip
	jsr printip
	PRINT ", "
	jsr yesno
	beq SET_NETMASK
	cmp #$01
	beq SET_NETMASK_a
	jmp SET_NETMASK_x
SET_NETMASK_a
	;copy gotip into pingip
	lda gotip
	sta CARD_MASK
	lda gotip+1
	sta CARD_MASK+1
	lda gotip+2
	sta CARD_MASK+2
	lda gotip+3
	sta CARD_MASK+3
SET_NETMASK_x
	jmp MSETTINGS
	
SET_GATEWAY
	jsr $e544
	PRINT "eNTER NEW GATEWAY",13
	jsr getip
	;verify
	PRINT 13
	lda #<gotip
	ldx #>gotip
	jsr printip
	PRINT ", "
	jsr yesno
	beq SET_GATEWAY
	cmp #$01
	beq SET_GATEWAY_a
	jmp SET_GATEWAY_x
SET_GATEWAY_a
	;copy gotip into pingip
	lda gotip
	sta CARD_GATE
	lda gotip+1
	sta CARD_GATE+1
	lda gotip+2
	sta CARD_GATE+2
	lda gotip+3
	sta CARD_GATE+3
SET_GATEWAY_x
	jmp MSETTINGS

SET_MAC
	jsr $e544
	PRINT "eNTER NEW mac",CRLF
	jsr getmac
	;verify
	PRINT CRLF
	lda #<gotmac
	ldx #>gotmac
	jsr printmac
	PRINT ", "
	jsr yesno
	beq SET_MAC
	cmp #$01
	beq SET_MAC_a
	jmp SET_MAC_x
SET_MAC_a
	lda gotmac
	sta CARD_MAC
	lda gotmac+1
	sta CARD_MAC+1
	lda gotmac+2
	sta CARD_MAC+2
	lda gotmac+3
	sta CARD_MAC+3
	lda gotmac+4
	sta CARD_MAC+4
	lda gotmac+5
	sta CARD_MAC+5
SET_MAC_x
	jmp MSETTINGS

SET_LCFG
	jsr LOAD_CONFIG
	jmp MSETTINGS
SET_SCFG
	jsr SAVE_CONFIG
	jmp MSETTINGS
	

;=============================================================================
;CONFIG file format:
; byte   description
; 0-1    nulled load address    
; 2      flag for config loaded
; 3      card type 1=eth64 2=rr-net
; 4      0=dhcp, 1=static
; 5-10   MAC Address
; 11-14  IP Address
; 15-18  NetMask
; 19-22  Gateway
; 23-26  DNS Server

LOAD_CONFIG
	lda #$06
	ldx #<CFGNAME
	ldy #>CFGNAME
	jsr SETNAM
	lda #$08
	ldx $BA
	ldy #$00
	jsr SETLFS
	lda #$00
	ldx #<CONFIGURATION
	ldy #>CONFIGURATION
	jsr LOAD
	rts

SAVE_CONFIG
	lda #$08
	ldx #<SAVECFGNAM
	ldy #>SAVECFGNAM
	jsr SETNAM
	lda #$08
	ldx $BA
	ldy #$00
	jsr SETLFS
	lda #$67
	lda #<CONFIGURATION
	sta $67
	lda #>CONFIGURATION
	sta $68
	ldx #<CONFIG_END
	ldy #>CONFIG_END
	jsr SAVE
	rts
SAVECFGNAM	dc.b "@:"
CFGNAME	dc.b "NETCFG"
