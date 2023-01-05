            processor 6502
            include "../vcs.h"
            include "../macro.h"
            include "../deepthought.h"

            SEG
            ORG $F000

Reset
        CLEAN_START
Again
        jsr Yo
        jmp Again

Yo
        DEEPTHOUGHT_PROLOG
        DEEPTHOUGHT_MIDDLE
        DEEPTHOUGHT_EPILOG

            ORG $FFFC

            .word Reset          ; RESET
            .word Reset          ; IRQ

    	END
