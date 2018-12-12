; =============================================================================
; GAME OVER MANAGEMENT
;
; AUTHOR  : ANTONI BURGUERA BURGUERA
; CONTACT : MY FAMILY NAME FOLLOWED BY THE AT SYMBOL THEN WRITE GMAIL AND END
;           WITH A DOT AND A COM.
; DATE    : 11-DEC-2018
; =============================================================================

; -----------------------------------------------------------------------------
GOVINIT
; INITIALIZES THE GAME OVER
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.W  #SCRWIDTH/2,(GOVCUROF)  ; INITIAL OFFSET
            RTS

; -----------------------------------------------------------------------------
GOVUPD
; UPDATES THE GAME OVER
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            SUBQ.W  #4,(GOVCUROF)           ; ADVANCE CURTAIN
            RTS

; -----------------------------------------------------------------------------
GOVPLOT
; PLOTS THE GAME OVER
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7,-(A7)
            CLR.L   D7
            MOVE.W  (GOVCUROF),D7
            JSR     GENCURT
            TST.W   (GOVCUROF)
            BPL     .END
            BTST    #5,(GENFRMCT)
            BEQ     .END
            LEA     STRBLKGV,A0
            JSR     GENFPLOT
.END        MOVEM.L (A7)+,D0-D7
            RTS