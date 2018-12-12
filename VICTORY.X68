; =============================================================================
; VICTORY MANAGEMENT
;
; AUTHOR  : ANTONI BURGUERA BURGUERA
; CONTACT : MY FAMILY NAME FOLLOWED BY THE AT SYMBOL THEN WRITE GMAIL AND END
;           WITH A DOT AND A COM.
; DATE    : 11-DEC-2018
; =============================================================================

; -----------------------------------------------------------------------------
VICINIT     EQU     GOVINIT
; INITIALIZES THE VICTORY
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; NOTE     - USES THE SAME CODE AND VARIABLES THAT GAME OVER. SO, VICINIT
;            IS JUST A PLACEHOLDER FOR GOVINIT.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
VICUPD      EQU     GOVUPD
; UPDATES THE VICTORY
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; NOTE     - USES THE SAME CODE AND VARIABLES THAT GAME OVER. SO, VICUPD
;            IS JUST A PLACEHOLDER FOR GOVUPD.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
VICPLOT
; PLOTS THE VICTORY
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D7/A0,-(A7)
            MOVE.L  #$00020000,D7
            MOVE.W  (GOVCUROF),D7
            JSR     GENCURT
            TST.W   (GOVCUROF)
            BPL     .END
            LEA     STRBLKVI,A0
            JSR     GENFPLOT
.END        MOVEM.L (A7)+,D7/A0
            RTS