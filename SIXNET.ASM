;Sixnet network code test shell
;
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
;DEFINES
TFTP_ENABLED = 1
ICMP_ENABLED = 1
CHAT_ENABLED = 0
NO_IRQ = 0
FCLIENT_ENABLED = 0

	processor 6502
	org $0801
	
	;zeropage addresses and equates
	include "equates.asm"
	;macros
	include "macros.asm"

BASIC   ;6 sys 2064
	dc.b $0c,$08,$06,$00,$9e,$20,$32,$30
	dc.b $36,$34,$00,$00,$00,$00,$00
	
START
;	jsr LOAD_CONFIG
	jsr setupscreen
	jsr initTOD
	jsr net_init
	bcs S_1
	jsr irq_init
	PRINT 13,"aUTOCONFIGURE WITH dhcp? "
	jsr yesno
	beq S_2
	cmp #$02
	beq S_1
	PRINT "dhcp iNIT"
	jsr DHCP_DISCOVER
	jsr getanykey
	
S_2	jsr get_macs
	bcc S_0
	ERROR "could not resolve gateway mac!"
	jmp S_1	
S_0
	jsr MENU
S_1	PRINT 13,"eXITING.",13
	rts
	
net_init
	jsr CARD_DETECT
	bcs detect_ERROR
	cmp #$01
	bne f_RR
	PRINT CG_WHT,"eth64 DETECTED",CRLF
	jmp init
f_RR	PRINT CG_WHT,"rrnET DETECTED",CRLF
init	jsr CARD_INIT
	bcs init_ERROR
	PRINT 5,"cARD INITIALIZED",CRLF
	clc
	rts
	
detect_ERROR
	ERROR "no card was detected!"
	sec
	rts
init_ERROR
	ERROR "error during initialization!"
	sec
	rts

get_macs ;returns carry clear if success, set if error
	;get MAC for gateway
	lda #<CARD_GATE
	ldx #>CARD_GATE
	jsr GET_ARP
	bcs getmacs_ERR
	;copy gateway mac
	ldx #$00
gm_0
	lda ARP_MAC,x
	sta CARD_GATE_MAC,x
	inx
	cpx #$06
	bne gm_0
	clc
	rts
getmacs_ERR
	sec
	rts
	
initTOD
	lda $dc0f
	and #$7f
	sta $dc0f
	lda #$00
	sta $dc08
	rts
	
setupscreen
	lda #$0b
	sta $d020
	lda #$00
	sta $d021
	PRINT CG_WHT,CG_CLR,CG_DCS,CG_LCS ;clear screen, white, lowercase, no c=+shift
	PRINT CG_RED,"     c64 nETLIB ",CG_YEL,"1.0",CG_WHT," (c)",CG_YEL,"2006",CG_WHT," sIX/sTYLE",CRLF,"iNITIALIZING...",CRLF
	rts
;============================================================================
;MAIN MENU
;=============================================================================
MENU
	jsr MENU_drawscreen
MENU0	
	jsr GETIN
	beq MENU0
;	sta $0400
	cmp #$31
	bne MENU_0a
	jmp MSETTINGS
MENU_0a
	cmp #$32
	bne MENU_0b
	jmp MARP
MENU_0b
	cmp #$33
	bne MENU_0c
	jmp MPING
MENU_0c
	cmp #$34
	beq MENUX
	cmp #$35
	beq MENUX1
	
	cmp #$36
	bne MENU_0d
	jmp MDNS
MENU_0d
	cmp #$37
	bne MENU_0e
	jmp MDHCP
MENU_0e
	cmp #$38
	bne MENU_0f
	jsr TFTP_GETFILE
	jmp MENU
MENU_0f
	cmp #$39
	bne MENU_10
MENU_10
	cmp #$30
	bne MENU_11
	jmp MDISK
MENU_11
MENUX
	rts
MENUX1
	jsr killirq
	jmp MENUX

MENU_drawscreen
	jsr draw_header
	jsr prns
	dc.b "         main menu",CRLF
	dc.b "      ",CG_YEL,"1. ",CG_WHT,"cHANGE sETTINGS",CRLF
	dc.b "      ",CG_YEL,"2. ",CG_WHT,"arp rESOLVE",CRLF
	dc.b "      ",CG_YEL,"3. ",CG_WHT,"pING ip",CRLF
	dc.b "      ",CG_YEL,"4. ",CG_WHT,"qUIT, kEEP nETirq",CRLF 
	dc.b "      ",CG_YEL,"5. ",CG_WHT,"qUIT, kILL nETirq",CRLF
	dc.b "      ",CG_YEL,"6. ",CG_WHT,"dns QUERY",CRLF
	dc.b "      ",CG_YEL,"7. ",CG_WHT,"dhcp rEQUEST",CRLF
	dc.b "      ",CG_YEL,"8. ",CG_WHT,"tftp GET",CRLF
;	dc.b "      ",CG_YEL," . ",CG_WHT,"tftp SEND",CRLF
	dc.b "      ",CG_YEL,"0. ",CG_WHT,"dISK tOOLS",CRLF
	dc.b "      ",CG_YEL,"SELECT:",CG_WHT,0 
	rts

MENU_NYI
	PRINT CRLF,CRLF,28,18,"nOT yET iMPLEMENTED",146,CRLF
	jsr getanykey
	rts

MDHCP
	jsr DHCP_DISCOVER
	jsr getanykey
	jmp MENU

MDNS
	jsr DNS_RESOLVER
	jmp MENU

MPING	
	jsr PING_DOPING
	jmp MENU
MARP
	jsr ARP_GETARP
	jmp MENU


;=============================================================================
;MISC MENU ROUTINES
;=============================================================================
draw_header
	jsr $e544
	PRINT CG_RED,"    c64 nETLIB ",CG_YEL,"1.0",CG_WHT," (c)",CG_YEL,"2006",CG_WHT," sIX/sTYLE",CRLF
	PRINT CG_GR1,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
	PRINT CG_LGN,"ip:",CG_WHT
	lda #<CARD_IP
	ldx #>CARD_IP
	jsr printip

	PRINT CS_HOM,CS_D,CS_D
	jsr p20cr
	PRINT CG_LGN," msk:",CG_WHT
	lda #<CARD_MASK
	ldx #>CARD_MASK
	jsr printip

	PRINT CRLF,CG_LGN,"gw:",CG_WHT
	lda #<CARD_GATE
	ldx #>CARD_GATE
	jsr printip
	
	PRINT CS_HOM,CS_D,CS_D,CS_D
	jsr p20cr
	PRINT CG_LGN," dns:",CG_WHT
	lda #<CARD_NS1
	ldx #>CARD_NS1
	jsr printip
	PRINT CRLF,CG_GR1,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
	rts
p20cr
	PRINT CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R,CS_R
	rts

;=============================================================================
;VARIABLES AND DATA
TIMEOUT	dc.b $00
TICKER  dc.b $00
;=============================================================================
;INCLUDES
	include "checksum.asm"
	include "utils.asm"

	include "DISK.ASM"
	
	include "CONFIG.ASM"
	
	include "IRQ.ASM"
	
	include "ETH64.ASM"
	include "RRNET.ASM"
	include "CARD.ASM"
	include "PACKET.ASM"
	include "MAC.ASM"
	include "ARP.ASM"
	include "IP.ASM"
	include "ICMP.ASM"
	include "UDP.ASM"
	include "TCP.ASM"

	include "DHCP.ASM"
	include "DNS.ASM"
	
	include "tools\ping\PING.ASM"
;	include "tools\udpchat\UDPCHAT.ASM"
	include "tools\tftp\TFTP.ASM"

;BUFFER=======================================================================

BUFSTART
	org $cfff
BUFFEND
