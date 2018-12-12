; =============================================================================
; UTILITY SUBROUTINES
;
; AUTHOR  : ANTONI BURGUERA BURGUERA
; CONTACT : MY FAMILY NAME FOLLOWED BY THE AT SYMBOL THEN WRITE GMAIL AND END
;           WITH A DOT AND A COM.
; DATE    : 11-DEC-2018
; =============================================================================

; -----------------------------------------------------------------------------
UTLSTRLN
; COMPUTES THE LENGTH OF A ZERO-TERMINATED STRING
; INPUT    - A1 POINTER TO THE STRING
; OUTPUT   - D0.W STRING LENGTH
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.L  A1,-(A7)
            CLR.W   D0
.LOOP       TST.B   (A1)+
            BEQ     .END
            ADDQ.W  #1,D0
            BRA     .LOOP
.END        MOVE.L  (A7)+,A1
            RTS