        processor 6502
        include "../vcs.h"
        include "../macro.h"
        include "pusher.h"
        include "logo.h"
        include "levels.h"
        include "../deepthought.h"

        SEG
        ORG $F000

Reset
        lda $1FF4 ; get in the correct bank
        CLEAN_START

        ; initialize level pointer
        ldx #0
        stx Level
        ldx #$f6
        stx Level+1

        ; init switch debounce registerss
        lda SWCHB
        sta lSWCHB
        lda SWCHA
        sta lSWCHA

        ; set initial playfield colors
        ldx #%01011010
        stx eCOLUPF
        ldx #%00000000
        stx COLUBK

        ; and the player's color why not
        lda #$F8
        sta COLUP0
        lda #$88
        sta COLUP1

        ; shimmer color
        lda #$0F
        sta SHIMMER
        lda #$02
        sta SHIMMERT

        ; configure playfield
        lda #$04
        sta CTRLPF

        ; very dirty trick to set initial P0
        sta WSYNC
        sta RESP0
        sta RESP1
        lda #$D0
        sta HMP0
        sta WSYNC
        sta HMOVE
        sta WSYNC
        sta HMCLR
        lda #$01
        sta rPLAYERX
        sta GRP1

        ; flag for map set up
        lda #$ff
        sta MAP

StartOfFrame

        lda MAP
        cmp #$ff
        bne whoop
        jsr SetupMap
whoop

        ; Start of vertical blank processing

        lda #0
        sta VBLANK

        lda #2
        sta VSYNC

        ; 3 scanlines of VSYNCH signal...

        ; this is where we adjust the player position
        sta WSYNC
        sta HMOVE
        sta WSYNC
        sta HMOVE
        sta WSYNC
        sta HMCLR

        lda #0
        sta VSYNC

        ; 37 scanlines of vertical blank...

        sta WSYNC

        ;lda #41 ; 76 * 35 / 64
        lda #40 ; 76 * 35 / 64
        sta TIM64T

audio
        ldx AUDT
        beq no_audio
        dex
        stx AUDT
        txa
        sec
        sbc #15
        bmi audio_down
        ; audio up
        lda #30
        sec
        sbc AUDT
        sta AUDV0
        jmp audio_fini
audio_down
        clc
        adc #15
        sta AUDV0
        jmp audio_fini
no_audio
        lda #$0
        sta AUDV0
audio_fini
        lda SHIMMER
        sta tmp0

        ldy #$1f
        sty BLOCKCOUNTDOWN ; block count

        ldx #0
        stx LEVELOFFSET ; Level offset

        ldx #$00
        stx MAPSPOT

vblank_wait ; wait for timer to expire
        lda INTIM
        and #$80
        beq vblank_wait

        lda MOVECOUNTER
        cmp #$0
        bne SixLinesScore
        jmp SixLinesLogo

        ; 192 scanlines of picture...
SixLinesLogo
        lda #$00
        sta NUSIZ1
        ldy #$FF
        ldx #$00
        stx tmp1

;;        LOGO
        ldx tmp0          ; 67 + 3
        stx COLUPF        ; 3 + 3

        ldx tmp1          ; 77 + 3

        ;jmp SixLinesLogo2
        ;align 256
SixLinesLogo2
        sta WSYNC

        lda logo,X        ; 0 + 4
        sta PF0           ; 4 + 3
        lda logo+1,X      ; 7 + 4
        sta PF1           ; 11 + 3
        lda logo+2,X      ; 14 + 4
        sta PF2           ; 18 + 3

        nop               ; 21 + 2
        nop               ; 23 + 2

        lda logo+3,X      ; 27 + 4
        sta PF0           ; 31 + 3 ; after 28 before 49

        iny               ; 47 + 2
        lda (LevelEnd),Y  ; 49 + 5
        sta GRP1          ; 54 + 3


        lda logo+4,X      ; 40 + 4
        sta PF1           ; 44 + 3 ; after 39 before 54

        lda logo+5,X      ; 51 + 4
        sta PF2           ; 55 + 3 ; before 65

        txa               ; 58 + 2
        clc               ; 60 + 2
        adc #$6           ; 62 + 2
        sta tmp1          ; 64 + 2
        tax               ; 66 + 2

        cmp #36           ; 68 + 2
        bne SixLinesLogo2 ; 70 + 3
;;        LOGO

EndLogo
        sta WSYNC
        ldx #$0
        stx PF0
        stx PF1
        stx PF2
        jmp SbSPre

SixLinesScore
        lda #$04
        sta NUSIZ1
        ldy #0
SixLinesScoreLoop
        sta WSYNC
        ldx tmp0                        ;; [0] + 3 = *3*
        stx COLUP1                      ;; [3] + 3 = *6*
        ldx #$0                         ;; [6] + 2 = *8*
        stx PF0                         ;; [8] + 3 = *11*
        lda (LevelEnd),Y                ;; [11] + 5 = *16*
        sta GRP1                        ;; [16] + 3 = *19*
        stx PF1                         ;; [19] + 3 = *22*
        stx PF2                         ;; [22] + 3 = *25*

        lda (tmp1),Y                    ;; [25] + 5 = *30*
        sta GRP1                        ;; [30] + 3 = *33*

        lda tmp0                        ;; [33] + 3 = *36*
        clc                             ;; [36] + 2 = *38*
        adc #$F0                        ;; [38] + 2 = *40*
        ora #$0F                        ;; [40] + 2 = *42*
        sta tmp0                        ;; [42] + 3 = *45*

        iny                             ;; [45] + 2 = *47*
        tya                             ;; [47] + 2 = *49*
        cmp #$06                        ;; [49] + 2 = *51*
        bne SixLinesScoreLoop           ;; [51] + 2 = *53*

        sta WSYNC

        ;align 256

SbSPre ; ScanlineBlockSetupPre

        ldy #$05                        ;; [0] + 2 = *2*
        sty LINECOUNTER                 ;; [2] + 3 = *5*
        ldx #0                          ;; [5] + 2 = *7*
        stx GRP1                        ;; [7] + 3 = *10*

SbS ; ScanlineBlockSetup
        sta WSYNC

        stx PF0                         ;; [0] + 3 = *3*
        stx PF1                         ;; [3] + 3 = *6*
        stx PF2                         ;; [6] + 3 = *9*

        ldy LEVELOFFSET                 ;; [9] + 3 = *12*

        lda (Level),Y                   ;; [12] + 5 = *17*
        sta eLPF0                       ;; [17] + 3 = *20*
        iny                             ;; [20] + 2 = *22*

        lda (Level),Y                   ;; [22] + 5 = *27*
        sta eLPF1                       ;; [27] + 3 = *30*
        iny                             ;; [30] + 2 = *32*

        lda (Level),Y                   ;; [32] + 5 = *37*
        sta eLPF2                       ;; [37] + 3 = *40*
        iny                             ;; [40] + 2 = *42*

        lda (Level),Y                   ;; [42] + 5 = *47*
        sta eRPF0                       ;; [47] + 3 = *50*
        iny                             ;; [50] + 2 = *52*

        lda (Level),Y                   ;; [52] + 5 = *57*
        sta eRPF1                       ;; [57] + 3 = *60*
        iny                             ;; [60] + 2 = *62*

        lda (Level),Y                   ;; [62] + 5 = *67*
        sta eRPF2                       ;; [67] + 3 = *70*
        iny                             ;; [70] + 2 = *72*

        sta WSYNC

        sty LEVELOFFSET                 ;; [72] + 3 = *75*

        ; we're out of cycles.  if we fall through
        ; to the next sta WSYNC, we actually skip
        ; an entire scanline.  therefore, we need
        ; to jump around it.
        jmp SbM2                        ;; [75] + 3 = *78*

SbM ; ScanlineBlockMap
        sta WSYNC
SbM2 ; ScanlineBlockMap2

        ; 68 pixel horizontal blank, then...
        ; 22.6
        ;
        ; 68   84       116      148  164      196
        ; 22.6 28       38.6     49.3 54.6     65.3
        ; 4..7 7......0 0......7 4..7 7......0 0......7 REF = 0
        ; PF0  PF1      PF2      PF0  PF1      PF2

        ldx eCOLUPF                     ;; [0] + 3 = *3*
        stx COLUPF                      ;; [3] + 3 = *6*
        ldx eLPF0                       ;; [6] + 3 = *9*
        stx PF0                         ;; [9] + 3 = *12* ;; < 22
        ldx eLPF1                       ;; [12] + 3 = *15*
        stx PF1                         ;; [15] + 3 = *18* ;; < 28
        ldx eLPF2                       ;; [18] + 3 = *21*
        stx PF2                         ;; [21] + 3 = *24* ;; < 38

        nop                             ;; [24] + 2 = *26*

        ldx eRPF0                       ;; [26] + 3 = *29*
        stx PF0                         ;; [29] + 3 = *32* ;; >= 28, < 49
        ldx eRPF1                       ;; [32] + 3 = *35*
        stx PF1                         ;; [35] + 3 = *38* ;; >= 39, < 54
        ldx eRPF2                       ;; [38] + 3 = *41*

        nop                             ;; [41] + 2 = *43*
        nop                             ;; [43] + 2 = *45*

        stx PF2                         ;; [45] + 3 = *48* ;; >= 50 < 63

        dec LINECOUNTER                 ;; [48] + 5 = *53*
        bne chooser                     ;; [53] + 2 = *55*

        dec BLOCKCOUNTDOWN              ;; [55] + 5 = *60*
        bne SbSPre                      ;; [60] + 2 = *62*
        jmp Endofscreen                 ;; [62] + 3 = *65*

chooser
        lda BLOCKCOUNTDOWN              ;; [65] + 3 = *68*
        and #$01                        ;; [68] + 2 = *70*
        bne SbGE                        ;; [70] + 2 = *72*

SbGO ; ScanlineBlockGoalOdd
        sta WSYNC
        ldx #0                          ;; [0] + 2 = *2*
        stx PF0                         ;; [2] + 3 = *5*
        stx PF1                         ;; [5] + 3 = *8*
        stx PF2                         ;; [8] + 3 = *11*
        ldx fGRP0                       ;; [11] + 3 = *14*
        stx GRP0                        ;; [14] + 3 = *17* ;; < 22

        ; draw a sprite
        ldy #$00                        ;; [17] + 2 = *19*
        ;
        lda BLOCKCOUNTDOWN              ;; [19] + 3 = *22*
        cmp DRAWY                       ;; [22] + 3 = *25*
        bne skippers                    ;; [25] + 2 = *27*
        ;
        lda PLAYERX                     ;; [27] + 3 = *30*
        cmp rPLAYERX                    ;; [30] + 3 = *33*
        bne skippers                    ;; [33] + 2 = *35*
        ;
        ldy #$ff                        ;; [35] + 2 = *37*
skippers
        sty fGRP0                       ;; [37] + 3 = *40*
        ; end draw a sprite

        dec LINECOUNTER                 ;; [40] + 5 = *45*

        lda LINECOUNTER                 ;; [45] + 3 = *48*
        cmp #$01                        ;; [48] + 2 = *50*
        bne SbM                         ;; [50] + 2 = *52*

        clc                             ;; [52] + 2 = *54*
        lda #$06                        ;; [54] + 2 = *56*
        adc MAPSPOT                     ;; [56] + 3 = *59*
        sta MAPSPOT                     ;; [59] + 3 = *62*

        jmp SbM                         ;; [62] + 3 = *65*

SbGE ; ScanlineBlockGoalEven
        sta WSYNC
        ; 68 pixel horizontal blank, then...
        ; 22.6
        ;
        ; 68   84       116      148  164      196
        ; 22.6 28       38.6     49.3 54.6     65.3
        ; 4..7 7......0 0......7 4..7 7......0 0......7 REF = 0
        ; PF0  PF1      PF2      PF0  PF1      PF2

        ldx MAPSPOT                     ;; [0] + 3 = *3*
        lda SHIMMER                     ;; [3] + 3 = *6*
        sta COLUPF                      ;; [6] + 3 = *9*
        lda MAP+0,X                     ;; [9] + 4 = *13*
        sta PF0                         ;; [13] + 3 = *16* ;; < 22
        lda MAP+1,X                     ;; [16] + 4 = *20*
        sta PF1                         ;; [20] + 3 = *23* ;; < 28
        lda MAP+2,X                     ;; [23] + 4 = *27*
        sta PF2                         ;; [27] + 3 = *30* ;; < 38

        lda MAP+3,X                     ;; [30] + 4 = *34*
        sta PF0                         ;; [34] + 3 = *37* ;; >= 28, < 49
        lda MAP+4,X                     ;; [37] + 4 = *41*
        sta PF1                         ;; [41] + 3 = *44* ;; >= 39, < 54
        lda MAP+5,X                     ;; [44] + 4 = *48*
        sta PF2                         ;; [48] + 3 = *51* ;; >= 50, < 63

        dec LINECOUNTER                 ;; [51] + 5 = *56*
        jmp SbM                         ;; [56] + 3 = *59*

Endofscreen
        sta WSYNC

        lda #%01000010
        sta VBLANK                     ; end of screen - enter blanking

        ; 30 scanlines of overscan...
        lda #35 ; 76*30/64 = 35.625
        sta TIM64T

        ldx #0
        stx PF0
        stx PF1
        stx PF2

        clc
        lda SWCHB
        cmp lSWCHB
        beq no_select
        lda SWCHB
        sta lSWCHB
        and #$02
        bne no_select
advance_level
        ldx Level+1
        inx
        stx Level+1
        txa
        clc
        cmp #$00 ; last level was at xff00
        bne yes_select
        lda #$f6 ; first level is at xf600
        sta Level+1
        lda NEXTBANK
yes_select
        ; flag for map setup
        lda #$ff
        sta MAP
no_select

        clc
        lda SWCHA
        cmp lSWCHA
        beq no_joy

        lda SWCHA
        sta lSWCHA
        and #$40 ; TODO FIX disagrees with documentation?
        bne no_left

        ; left
        ldx PLAYERX
        ldy PLAYERY
        dex
        stx tmp6
        sty tmp7
        dex
        stx tmp8
        sty tmp9
        jsr DoMove

        jmp yes_joy
no_left
        lda lSWCHA
        and #$80 ; TODO FIX disagrees with documentation?
        bne no_right

        ;right
        ldx PLAYERX
        ldy PLAYERY
        inx
        stx tmp6
        sty tmp7
        inx
        stx tmp8
        sty tmp9
        jsr DoMove

        jmp yes_joy
no_right
        lda lSWCHA
        and #$20
        bne no_down

        ;down
        ldx PLAYERX
        ldy PLAYERY
        iny
        stx tmp6
        sty tmp7
        iny
        stx tmp8
        sty tmp9
        jsr DoMove

        jmp yes_joy
no_down
        lda lSWCHA
        and #$10
        bne no_joy

        ;up
        ldx PLAYERX
        ldy PLAYERY
        dey
        stx tmp6
        sty tmp7
        dey
        stx tmp8
        sty tmp9
        jsr DoMove

yes_joy
        jsr CheckWin
        cmp #$00
        beq no_joy
        jmp advance_level

no_joy

        ; check for LR motion
        lda rPLAYERX
        sec
        sbc PLAYERX
        beq no_lr_move
        bmi go_right
        ; go left
        lda #$40
        sta HMP0
        dec rPLAYERX
        jmp no_lr_move
go_right
        ; go right
        lda #$C0
        sta HMP0
        inc rPLAYERX
no_lr_move
        lda INPT4
        and #$80
        bne notrig

        ; flag for map set up
        lda #$ff
        sta MAP
notrig
        dec SHIMMERT
        bne no_shimmer
        lda SHIMMER
        clc
        adc #$10
        sta SHIMMER
        lda #$02
        sta SHIMMERT
no_shimmer

overscan_wait ; wait for timer to expire
        lda INTIM
        and #$80
        beq overscan_wait

        sta WSYNC

        jmp StartOfFrame

SetupMap
        DEEPTHOUGHT_PROLOG ; this gone take a while

        ldx #16
        ldy #$04
        jsr note ; 882 Hz

        ldx #$0
        lda #$0
        sta MOVECOUNTER

SetupMap_Clearloop
        sta MAP,X
        inx
        cpx #96
        bne SetupMap_Clearloop

        ldy #$BA ; 31 * 6 = 186 = $BA
SetupMap_Setloop
        lda (Level),Y
        iny
        sta tmp0
        lda (Level),Y
        iny
        sta tmp1
        lda (Level),Y
        iny
        sta tmp2
        lda (Level),Y
        iny
        sta tmp3
        lda tmp3
        cmp #$ff
        beq SetupMap_PostSetloop

        ; tmp0, tmp1 are x,y for a box
        ; we need to turn on corresponding bits in map

        ; tmp1->map offset is easy; multiply by 6
        lda tmp1
        asl
        asl tmp1
        asl tmp1
        clc
        adc tmp1
        sta tmp1
        ; offset tables used to be here, but we moved them...
        ldx tmp0
        lda offset_table,X
        clc
        adc tmp1
        sta tmp1
        ldx tmp0
        lda mask_table,X
        sta tmp3
        ldx tmp1
        lda MAP,X
        ora tmp3
        sta MAP,X

        jmp SetupMap_Setloop

SetupMap_PostSetloop

        ; save the end
        sty LevelEnd
        ldy Level+1
        sty LevelEnd+1

        ; save player position and draw values
        lda tmp0
        sta PLAYERX
        lda tmp1
        sta PLAYERY
        asl
        sta tmp0
        lda #$20 ; top draw BLOCKCOUNTDOWN
        sec
        sbc tmp0
        sta DRAWY

        DEEPTHOUGHT_MIDDLE

        lda PLAYERX
        clc
        adc PLAYERY
        asl
        asl
        asl
        clc
        adc #$0E
        sta eCOLUPF
        adc #$80
        sta COLUP0

        DEEPTHOUGHT_EPILOG

DoMove
        ldx tmp6
        ldy tmp7
        jsr Peek
        sta tmp0
        cmp #$02
        beq l00002

        lda tmp0
        cmp #$01
        bne l00001

        ; there is a box there
        ldx tmp8
        ldy tmp9
        jsr Peek
        cmp #$00
        beq l00003
        cmp #$80
        beq l00004

l00002
        ; there is something there
        ldx #31
        ldy #$0F
        jsr note ; 156 Hz

        rts

l00004
        ldx #9
        ldy #$04
        jsr note ; 1578 Hz
        jmp l00005

l00003
        ldx #18
        ldy #$04
        jsr note ; 789 Hz

l00005
        ldx tmp6
        ldy tmp7
        lda #$00
        jsr Poke

        ldx tmp8
        ldy tmp9
        lda #$01
        jsr Poke

        inc MOVECOUNTER

        jmp l00006
l00001
        ldx #31
        ldy #$0C
        jsr note ; 156 Hz
l00006
        ldx tmp6
        stx PLAYERX
        lda tmp7
        sta PLAYERY

        asl
        sta tmp7
        lda #$20 ; top draw BLOCKCOUNTDOWN
        sec
        sbc tmp7
        sta DRAWY


        rts

numbers_table_0
        dc.b #%0111, #%0001, #%0111, #%0111, #%0101, #%0111, #%0111, #%0111, #%0111, #%0111
numbers_table_1
        dc.b #%0101, #%0001, #%0001, #%0001, #%0101, #%0100, #%0100, #%0001, #%0101, #%0101
numbers_table_2
        dc.b #%0101, #%0001, #%0111, #%0111, #%0111, #%0111, #%0111, #%0001, #%0111, #%0111
numbers_table_3
        dc.b #%0101, #%0001, #%0100, #%0001, #%0001, #%0001, #%0101, #%0001, #%0101, #%0001
numbers_table_4
        dc.b #%0111, #%0001, #%0111, #%0111, #%0001, #%0111, #%0111, #%0001, #%0111, #%0111

Peek
        ; x and y hold a position, returns a=0 (empty), a=1 (block), a=2 (wall), a=x80 (goal)
        stx tmp0
        sty tmp1

        ; find positions in offset tables
        lda offset_table,X
        sta tmp2
        lda mask_table,X
        sta tmp3

        ; tmp5 = a = tmp3 * 6
        tya
        sta tmp4
        asl
        asl tmp4
        asl tmp4
        clc
        adc tmp4
        sta tmp5 ; for later

        ; a = tmp3 * 6 + offset
        adc tmp2
        tax
        lda MAP,X
        and tmp3
        beq nextup1
        ; it's a block
        lda #$01
        rts
nextup1
        ; is it a goal?
        ldy #$BA ; 31 * 6

nextup1loop
        iny
        iny
        lda (Level),Y
        sta tmp2
        iny
        lda (Level),Y
        iny
        sta tmp3

        lda tmp2
        cmp #$ff
        beq nextup1loopout

        cmp tmp0
        bne nextup1loop

        lda tmp3
        cmp tmp1
        bne nextup1loop

        ; it's a goal, not a wall
        lda #$80
        rts

nextup1loopout
        ; is it a wall?

        ldx tmp0
        ldy tmp1

        ; find positions in offset tables
        lda offset_table,X
        sta tmp2
        lda mask_table,X
        sta tmp3

        lda tmp1
        asl
        sta tmp1
        asl tmp1
        asl
        asl
        adc tmp1
        adc tmp2
        tay

        lda (Level),Y
        and tmp3
        bne nextup2
        lda #$00
        rts

nextup2
        ; must be a wall
        lda #$02
        rts

Poke ; x and y hold position, a=0 for on, a=1 for off
        stx tmp0
        sty tmp1
        sta tmp5

        ; find positions in offset tables
        lda offset_table,X
        sta tmp2
        lda mask_table,X
        sta tmp3

        ; a = tmp3 * 6
        tya
        sta tmp4
        asl
        asl tmp4
        asl tmp4
        clc
        adc tmp4

        ; a = tmp3 * 6 + offset
        adc tmp2
        tax
        lda MAP,X

        ldy tmp5
        beq PokeClr
        ; PokeSet
        ora tmp3
        sta MAP,X
        rts
PokeClr
        lda tmp3
        eor #$FF
        sta tmp3

        lda MAP,X
        and tmp3
        sta MAP,X
        rts

CheckWin ; a=1 for win, 0 otherwise
        ldy #$BA ; see comments above, i'm lazy right now
        sty tmp6
CheckWinLoop
        ldy tmp6
        iny
        iny
        lda (Level),Y
        tax
        iny
        lda (Level),Y
        iny
        sty tmp6
        tay

        cmp #$FF
        bne L1234
        lda #$01
        rts
L1234
        jsr Peek
        cmp #$01
        beq CheckWinLoop
        lda #$00
        rts

note
        lda SWCHB
        and #$40
        bne note_return
        stx AUDF0
        sty AUDC0
        lda #$01
        sta AUDV0
        lda #21
        sta AUDT
note_return
        rts

; For some obscure reason i cannot understand, commenting out the
; movecount stuff with ;X threw off all kinds of timing.  i had
; to put an "align 256" right before SbSPre to fix it.  Rather than
; waste those bytes, i moved some lookup tables here instead,
; which has the same effect of pushing SbSPre into the next page.

        ; for tmp0, we need an offset and a bit mask.  ugh
        ; 20 possible values, lookup table
offset_table
        dc.b #0,#0,#1,#1,#1,#1,#2,#2,#2,#2,#3,#3,#4,#4,#4,#4,#5,#5,#5,#5
mask_table
        dc.b #$10,#$40
        dc.b #$80,#$20,#$08,#$02
        dc.b #$01,#$04,#$10,#$40
        dc.b #$10,#$40
        dc.b #$80,#$20,#$08,#$02
        dc.b #$01,#$04,#$10,#$40

logo
        LOGO

        dc.b "Game Code Copyright (C) 2022 Adam Wozniak", 0

        BANKLEVEL

        ; reserve bank switching hotspots
        ORG $FFF4
        dc.b 0,1,2,3,4,5,6,7

        ; our hardware does not NMI, and those addresses
        ; are needed as per above for bank switching
        ; ORG $FFFA
        ; word Reset          ; NMI

        ; these are necessary
        ORG $FFFC

        .word Reset          ; RESET
        .word Reset          ; IRQ

        END
