;Source by Six of Style (Oliver VieBrooks)              _,.-------.,_
;http://style64.org                                 ,;~'             '~;,
;http://thedarkside.ath.cx                        ,;                     ;,
;mailto:six@darklordsofchaos.com                 ;                         ;
;Last Updated 11/29/2006                        ,'       Style 2006        ',
;                                              ,;                           ;,
;                                              ; ;      .           .      ; ;
;                                              | ;   ______       ______   ; |
;                                              |  `/~"     ~" . "~     "~\'  |
;                                              |  ~  ,-~~~^~, | ,~^~~~-,  ~  |
;                                               |   |        }:{        |   |
;                                               |   !       / | \       !   |
;                                               .~  (__,.--" .^. "--.,__)  ~.
;                                               |     ---;' / | \ `;---     |
;                                                \__.       \/^\/       .__/
;                                                 V| \                 / |V
;                                                  | |T~\___!___!___/~T| |
;                                                  | |`IIII_I_I_I_IIII'| |
;                                                  |  \,III I I I III,/  |
;                                                   \   `~~~~~~~~~~'    /
;                                                     \   .       .   /
;                                                       \.    ^    ./
;                                                         ^~~~^~~~^

DISK_DIRECTORY ;clears screen, displays directory of disk
	PRINT CG_CLR
	lda #$01
	ldx $ba
	ldy #$00
	jsr SETLFS
	lda #$01
	ldx #<DIRCHAR ;"$"
	ldy #>DIRCHAR
	jsr SETNAM
	jsr OPEN
	ldx #$01
	jsr CHKIN
	bcs DIREND
	jsr CHRIN
	jsr CHRIN ;discard load address
DIRLOOP
	lda #$0d
	jsr CHROUT
	jsr CHRIN
	jsr CHRIN

	jsr CHRIN ;file size
	tay
	jsr CHRIN
	tax
	jsr READST
	bne DIREND
	tya
	ldy #$0a
	jsr printnum
	lda #$20
	jsr CHROUT
DIRLOOP2
	jsr CHRIN
	tax
	beq DIRLOOP
	jsr CHROUT
	bne DIRLOOP2
DIREND
	lda #$01
	jsr CLOSE
	jsr CLRCHN
	jsr DISK_ERROR
	jsr getanykey
	rts

DISK_OPENFILE ;expects pointer to nts in x:a
	stx D_O0+2
	sta D_O0+1
	;copy filename into buffer
	ldx #$00
D_O0
	lda $ffff,x
	beq D_O1
	sta FNAMEBUFF,x
	inx
	bne D_O0
D_O1
	;copy ,p,w to end of filename
	ldy #$00
D_O2
	lda DFWSUF,y
	sta FNAMEBUFF,x
	iny
	inx
	cpy #$04
	bne D_O2
	txa ;number of chars in a
	ldx #<FNAMEBUFF
	ldy #>FNAMEBUFF
	jsr SETNAM
	lda #$08 ;file#
	ldx $ba ;dev
	ldy #$01 ;sec
	jsr SETLFS
	jsr OPEN
        rts
        
DISK_WRITEBLOCK ;expects pointer to data in x:a
		;expects # of bytes to write on stack
	sta D_W0+1 ;base addr of data l
	stx D_W0+2 ;base addr of data h
	pla
	sta D_Wl ;lo-byte of # of bytes to write
	pla
	sta D_Wh ;hi-byte of # of bytes to write
D_W2
	lda #$ff
	sta D_Wi
	jsr D_W0
	dec D_Wh
	bne D_W2 ;write D_Wh blocks of 255 bytes
D_W3
	lda D_Wl
	sta D_Wi
	jsr D_W0 ;write D_Wl bytes
	
	ldx #$08
	jsr CHKOUT
	
	jsr CLRCHN
	rts

D_W0 ;write D_Wi bytes to file
	lda $ffff
	jsr CHROUT
	inc D_W0+1
	bne D_W01
	inc D_W0+2
D_W01
	dec D_Wi
	bne D_W0
	rts
	
D_Wl	dc.b $00
D_Wh	dc.b $00
D_Wi	dc.b $00  
         
DISK_CLOSEFILE ;expects file # iny
	lda #$08
	jsr CLOSE
	rts
      
DISK_COMMAND
	PRINT CG_CLR
	lda $ba
	ldx #$00
	ldy #$0a
	jsr printnum
	PRINT ">"
	INPUT DISK_COMMAND,40
	PRINT 13
	lda #$0f
	ldx $ba
	ldy #$0f
	jsr SETLFS
	lda #$00
	jsr SETNAM
	jsr OPEN
	bcs DC_ERR
	ldx #$0f
	jsr CHKOUT
	ldy #$00
DC_LOOP
	lda DCOMMAND,y
	beq DC_DONE
	jsr CHROUT
	iny
	bne DC_LOOP
	
DC_ERR
	ERROR "an error has ocurred!"
	jsr getanykey
DC_DONE
	jsr CLRCHN
	lda #$0f
	jsr CLOSE
	jsr CLRCHN
	jsr DISK_ERROR
	jsr getanykey
	rts

DISK_ERROR
	PRINT CRLF
	lda #$0f
	ldx $ba
	ldy #$0f
	jsr SETLFS
	lda #$00
	jsr SETNAM
	jsr OPEN
	bcs DE_ERR
	ldx #$0f
	jsr CHKIN
DE_LOOP	jsr CHRIN
	cmp #$0d
	beq DE_DONE
	jsr CHROUT
	bne DE_LOOP

DE_DONE
	jsr CHROUT
	jsr CHROUT
	lda #$0f
	jsr CLOSE
	jsr CLRCHN
	rts
DE_ERR
	ERROR "could not open drive for input"
	jmp DE_DONE	

DIRCHAR	dc.b #$24 ;$
DCOMMAND ds.b 40,0 ;buffer for disk command entry
DFWSUF dc.b ",p,w",0
FNAMEBUFF ds.b 40,0

;=============================================================================
;DISK MENU
;=============================================================================
MDISK
	jsr draw_header
	jsr prns
	dc.b "         disk menu",CRLF
	dc.b "      ",CG_YEL,"1. ",CG_WHT,"cHANGE dRIVE (",0

	lda $ba
	ldx #$00
	ldy #$0a
	jsr printnum
	
	jsr prns
	dc.b ")",CRLF
	dc.b "      ",CG_YEL,"2. ",CG_WHT,"dIRECTORY",CRLF
	dc.b "      ",CG_YEL,"3. ",CG_WHT,"dISK cOMMAND",CRLF
	dc.b "      ",CG_YEL,"4. ",CG_WHT,"rEAD eRROR cHANNEL",CRLF
	dc.b "      ",CG_YEL,"5. ",CG_WHT,"qUIT TO MAIN",CRLF
	dc.b "      ",158,"SELECT:",5,0 
MDISK_0
	jsr GETIN
	beq MDISK_0
	cmp #$31
	bne MDISK_1
	PRINT CRLF,"dEVICE nUMBER? ",0
	jsr getnum
	sta $ba
	jmp MDISK
MDISK_1
	cmp #$32
	bne MDISK_2
	jsr DISK_DIRECTORY
	jmp MDISK
MDISK_2
	cmp #$33
	bne MDISK_3
	jsr DISK_COMMAND
	jmp MDISK
MDISK_3
	cmp #$34
	bne MDISK_4
	jsr DISK_ERROR
	jsr getanykey
	jmp MDISK
MDISK_4
	cmp #$35
	bne MDISK_0
	jmp MENU
	
	
;