        MACRO DEEPTHOUGHT_PROLOG
  ; Start of vertical blank processing

           lda #0
           sta VBLANK

           lda #2
           sta VSYNC
           
              ; 3 scanlines of VSYNCH signal...

               sta WSYNC
               sta WSYNC
               ; (192+37+1)*76/1024 == 17.07....
               lda #17
               sta T1024T
               sta WSYNC

           lda #0
           sta VSYNC           

              ; 37 scanlines of vertical blank...
              ; 192 scanlines of picture...


        ENDM


        MACRO DEEPTHOUGHT_MIDDLE
deeploop
           lda INTIM
           and #$80
           beq deeploop
           sta WSYNC
           
           lda #%01000010
           sta VBLANK                     ; end of screen - enter blanking

              ; 30 scanlines of overscan...
              ; 30*76/64 = 35.625
           lda #35
           sta TIM64T
        ENDM


        MACRO DEEPTHOUGHT_EPILOG
deeploop2
           lda INTIM
           and #$80
           beq deeploop2
           sta WSYNC
           rts
        ENDM
