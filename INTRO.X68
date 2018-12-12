; =============================================================================
; INTRO MANAGEMENT
;
; AUTHOR  : ANTONI BURGUERA BURGUERA
; CONTACT : MY FAMILY NAME FOLLOWED BY THE AT SYMBOL THEN WRITE GMAIL AND END
;           WITH A DOT AND A COM.
; DATE    : 11-DEC-2018
; =============================================================================

; -----------------------------------------------------------------------------
INTPLOT
; PLOTS THE INTRO LOGO
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L A0/D0-D7,-(A7)

            ; DRAW THE LOGO. SIZE OF THE PIC IS 304X160
            MOVE.W  #(SCRWIDTH-304)/2,D5    ; CENTER X
            MOVE.W  #SCRHEIGH/2-160,D6      ; PIC BOTTOM AT SCREEN CENTER
            MOVE.W  #26,D7
            MOVE.B  (GENFRMCT),D0
            AND.L   #$F,D0
            SUB.W   D0,D6
            LEA     GFXLOGO,A1
            JSR     GFXDRPIC                ; DRAW PIC

            ; DRAW THE SUBTITLE
            MOVE.L  #$00FFFFFF,D1
            MOVE.B  #80,D0
            TRAP    #15                     ; PEN TO WHITE
            CLR.L   D1
            ADDQ.B  #1,D0
            TRAP    #15                     ; FILL TO BLACK
            LEA     STRTIT0,A1
            MOVE.W  #260,D2
            JSR     .PRTCTR
            MOVE.W  #400,D2
            LEA     STRTIT1,A1
            BTST    #4,(GENFRMCT)
            BEQ     .PRT
            LEA     STRTIT2,A1
.PRT        JSR     .PRTCTR
            MOVEM.L (A7)+,A0/D0-D7
            RTS
.PRTCTR     JSR     UTLSTRLN                ; COMPUTE THE TITLE STRING LENGTH
            MOVE.W  D0,D3
            MULU.W  #GENCHRW,D3             ; CONVERT TO PIXELS
            JSR     GENCENTX                ; GET CENTERED COORDINATE
            MOVE.B  #95,D0
            TRAP    #15
            RTS