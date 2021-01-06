	processor 6502

	include "vcs.h"

	include "macro.h"

	SEG
	ORG $F000

; asymmetric playfield
; board is 10x10 (interior 8x8)
; a symbol is 16x16 pixels
; this leaves 32 spare scanlines at the bottom

;;;;;
; ram assignments
PlayfieldData = $80 ; 64 bytes cleared, only 60 are used
DrawCounter = $BE ; 1 byte
BoardY = $BF ; 1 byte
LevelPointer = $C0 ; two bytes
LeftButtonState = $C2 ; one byte

;;;;;
; Clear the playfield area, setting everything to 0
ClearPF
	ldx #$00
	lda #$00
ClearPFLoop
	sta PlayfieldData,X
	inx
	cpx #$40
	bne ClearPFLoop
	rts

;;;;;
; Populate the playfield area based on current level
PopulatePF
	jsr ClearPF

	ldx #$00 ; our spot in the playfield data
	ldy #$00 ; our spot in the ROM
PopulatePFLoop
	inx

	; abcdefgh ->
	; 00000000 aaaabbbb ddddcccc eeee0000 ffffgggg 0000hhhh

PPF_A	; a
	lda (LevelPointer),Y
	and #$80
	beq PPF_B
	lda #$F0
	sta PlayfieldData,X

PPF_B
	lda (LevelPointer),Y
	and #$40
	beq PPF_C
	lda PlayfieldData,X
	ora #$0F
	sta PlayfieldData,X

PPF_C
	inx

	lda (LevelPointer),Y
	and #$20
	beq PPF_D
	lda #$0F
	sta PlayfieldData,X

PPF_D
	lda (LevelPointer),Y
	and #$10
	beq PPF_E
	lda PlayfieldData,X
	ora  #$F0
	sta PlayfieldData,X

PPF_E
	inx

	lda (LevelPointer),Y
	and #$08
	beq PPF_F
	lda #$F0
	sta PlayfieldData,X

PPF_F
	inx

	lda (LevelPointer),Y
	and #$04
	beq PPF_G
	lda #$F0
	sta PlayfieldData,X

PPF_G
	lda (LevelPointer),Y
	and #$02
	beq PPF_H
	lda PlayfieldData,X
	ora #$0F
	sta PlayfieldData,X

PPF_H
	inx

	lda (LevelPointer),Y
	and #$01
	beq PPF_CONTINUE
	lda #$0F
	sta PlayfieldData,X

PPF_CONTINUE
	inx
	iny
	cpy #$0A
	bne PopulatePFLoop

	; fill the left side
	ldx #$F0
	ldy #$A
	lda (LevelPointer),Y
LeftFill0
	asl
	bcc LeftFill1
	stx $86
LeftFill1
	asl
	bcc LeftFill2
	stx $8C
LeftFill2
	asl
	bcc LeftFill3
	stx $92
LeftFill3
	asl
	bcc LeftFill4
	stx $98
LeftFill4
	asl
	bcc LeftFill5
	stx $9E
LeftFill5
	asl
	bcc LeftFill6
	stx $A4
LeftFill6
	asl
	bcc LeftFill7
	stx $AA
LeftFill7
	asl
	bcc LeftFill8
	stx $B0
LeftFill8
	; there is no bit 8 =)

	; fill the right side
	ldy #$B
	lda (LevelPointer),Y
RightFill0
	asl
	bcc RightFill1
	tax
	lda $8B
	ora #$F0
	sta $8B
	txa
RightFill1
	asl
	bcc RightFill2
	tax
	lda $91
	ora #$F0
	sta $91
	txa
RightFill2
	asl
	bcc RightFill3
	tax
	lda $97
	ora #$F0
	sta $97
	txa
RightFill3
	asl
	bcc RightFill4
	tax
	lda $9D
	ora #$F0
	sta $9D
	txa
RightFill4
	asl
	bcc RightFill5
	tax
	lda $A3
	ora #$F0
	sta $A3
	txa
RightFill5
	asl
	bcc RightFill6
	tax
	lda $A9
	ora #$F0
	sta $A9
	txa
RightFill6
	asl
	bcc RightFill7
	tax
	lda $AF
	ora #$F0
	sta $AF
	txa
RightFill7
	asl
	bcc RightFill8
	tax
	lda $B5
	ora #$F0
	sta $B5
	txa
RightFill8
	; there is no bit 8 =)

	; fill the corners side
	ldy #$C
	lda (LevelPointer),Y
CornerFill0
	asl
	bcc CornerFill1
	ldx #$F0
	stx $80
CornerFill1
	asl
	bcc CornerFill2
	tax
	lda $85
	ora #$F0
	sta $85
	txa
CornerFill2
	asl
	bcc CornerFill3
	ldx #$F0
	stx $B6
CornerFill3
	asl
	bcc CornerFill4
	tax
	lda $BB
	ora #$F0
	sta $BB
	txa
CornerFill4
	; there is no bit 4 =)

	rts

NextLevel
	ldy #$0D
NextLevelNonzero
	iny
	lda (LevelPointer),Y
	cmp #$0
	bne NextLevelNonzero
NextLevelZero
	iny
	lda (LevelPointer),Y
	cmp #$0
	beq NextLevelZero
NextLevelAddition
	clc
	tya
	adc LevelPointer
	sta LevelPointer
	lda #$0
	adc LevelPointer+1
	sta LevelPointer+1
	jsr PopulatePF 
	rts



Reset
	; set the stack pointer
	ldx #$ff
	txs

	; set the level pointer
	lda #<Levels
	sta LevelPointer
	lda #>Levels
	sta LevelPointer+1

	; set up the playfield data
	jsr PopulatePF

	; set up colors
	lda #$00
	sta COLUBK
	sta CTRLPF
	lda #$7F
	sta COLUPF

	; initialize joystick button state
	lda INPT4
	and #$80
	sta LeftButtonState

StartOfFrame

	; Start of vertical blank processing
	lda #0
	sta VBLANK

	lda #2
	sta VSYNC

	; 3 scanlines of VSYNCH signal...
	sta WSYNC
	sta WSYNC
	sta WSYNC

	lda #0
	sta VSYNC           

	; 37 scanlines of vertical blank...
	ldx #36
VerticalBlankLoop
	sta WSYNC
	dex
	bne VerticalBlankLoop

	ldx #0
	ldy #0
	stx BoardY
	stx DrawCounter

	jmp Scanline

	ALIGN 256

	; 192 scanlines of picture...
Scanline
	sta WSYNC ; this is the last WSYNC in vertical blank AND the start of the scanline

	ldx DrawCounter      ; [ 0, 3 ]
	lda PlayfieldData,X  ; [ 3, 4 ]
	sta PF0	             ; [ 7, 3 ]
	inx                  ; [ 10, 2 ]
	lda PlayfieldData,X  ; [ 12, 4 ]
	sta PF1              ; [ 16, 3 ]
	inx                  ; [ 19, 2 ]
	lda PlayfieldData,X  ; [ 21, 4 ]
	sta PF2              ; [ 25, 3 ]
	inx                  ; [ 28, 2 ]
	lda PlayfieldData,X  ; [ 30, 4 ]
	sta PF0	             ; [ 34, 3 ]
	inx                  ; [ 37, 2 ]
	lda PlayfieldData,X  ; [ 39, 4 ]
	sta PF1              ; [ 43, 3 ]
	inx                  ; [ 46, 2 ]
	lda PlayfieldData,X  ; [ 48, 4 ]
	sta PF2              ; [ 52, 3 ]
	inx                  ; [ 55, 2 ]
	iny                  ; [ 57, 2 ]
	cpy #$10             ; [ 59, 2 ]
	bne Scanline         ; [ 61, 2/3/4 ]
	stx DrawCounter      ; [ 63, 3 ]
	ldy #$0              ; [ 66, 2 ]
	cpx #$3C             ; [ 68, 2 ]
	bne Scanline         ; [ 70, 2/3/4 ]

ScanlineComplete

	sta WSYNC

	lda #$00
	sta PF0
	sta PF1
	sta PF2


	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	

	lda #%01000010
	sta VBLANK                     ; end of screen - enter blanking



	; 30 scanlines of overscan...
	sta WSYNC

	lda INPT4
	and #$80
	cmp LeftButtonState
	beq JoystickDone
	sta LeftButtonState
	cmp #$0
	bne JoystickDone
	jsr NextLevel
JoystickDone


	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC

	jmp StartOfFrame

	ALIGN 256
Levels
	include "levels.h"



	ORG $FFFA



	.word Reset          ; NMI

	.word Reset          ; RESET

	.word Reset          ; IRQ



END

