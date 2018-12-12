; =============================================================================
; GAME STATE MANAGEMENT
;
; AUTHOR  : ANTONI BURGUERA BURGUERA
; CONTACT : MY FAMILY NAME FOLLOWED BY THE AT SYMBOL THEN WRITE GMAIL AND END
;           WITH A DOT AND A COM.
; DATE    : 11-DEC-2018
; =============================================================================

; -----------------------------------------------------------------------------
STAINIT
; INITALIZES THE STATE MANAGER
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.W  #STANONE,(STACUR)
            MOVE.W  #STAINTR,(STANEXT)
            CLR.B   (GENFRMCT)              ; INIT FRAME COUNTER
            BRA     AUDINIT                 ; INIT AUDIO SYSTEM

; -----------------------------------------------------------------------------
STAUPD
; PERFORMS STATE UPDATE AND INIT IF NECESSARY
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            ADDQ.B  #1,(GENFRMCT)           ; INCREASE FRAME COUNTER
            MOVEM.L D0/A0,-(A7)
            CLR.L   D0
            MOVE.W  (STANEXT),D0
            CMP.W   (STACUR),D0
            BEQ     .DOUPD
            MOVE.W  D0,(STACUR)             ; IF STATE CHANGED, DO INIT
            LSL.L   #2,D0
            MOVE.L  D0,A0
            MOVE.L  .INITBL(A0),A0
            JSR     (A0)
.DOUPD      CLR.L   D0                      ; IN ANY CASE, DO UPDATE
            MOVE.W  (STACUR),D0
            LSL.L   #2,D0
            MOVE.L  D0,A0
            MOVE.L  .UPDTBL(A0),A0
            JSR     (A0)
            MOVEM.L (A7)+,D0/A0
            RTS
.INITBL     DC.L    STAINTRI,STAPLAYI,STAGOVRI,STAATRI,STAVICI
.UPDTBL     DC.L    STAINTRU,STAPLAYU,STAGOVRU,STAATRU,STAVICU

; -----------------------------------------------------------------------------
STAPLOT
; PERFORMS STATE PLOT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0/A0,-(A7)
            CLR.L   D0
            MOVE.W  (STACUR),D0
            LSL.L   #2,D0
            MOVE.L  D0,A0
            MOVE.L  .PLTTBL(A0),A0
            JSR     (A0)
            MOVEM.L (A7)+,D0/A0
            RTS
.PLTTBL     DC.L    STAINTRP,STAPLAYP,STAGOVRP,STAATRP,STAVICP

; =============================================================================
; PLAY STATE
; =============================================================================

; -----------------------------------------------------------------------------
STAPLAYI
; PLAY STATE INITIALIZATION.
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            JSR     MAPINIT
            IFNE    ATRSAVE
            JSR     ATRINIT
            ENDC
            BRA     PLRINIT

; -----------------------------------------------------------------------------
STAPLAYU
; PLAY STATE UPDATE
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            TST.W   (PLROXYG)               ; CHECK OXYGEN
            BNE     .CONT                   ; IS ZERO?
            MOVE.W  #STAGOVR,(STANEXT)      ; YES: GAME OVER
.CONT       MOVE.W  (PLRPICKF),D0           ; CHECK PICKED FUEL TANKS
            CMP.W   (MAPNUMTR),D0           ; ARE THEY ALL?
            BNE     .CONT2
            MOVE.W  #STAVICT,(STANEXT)      ; YES: VICTORY
.CONT2
            IFNE    ATRSAVE
            JSR     ATRUPD                  ; ONLY IN ATTRACT RECORD MODE
            ENDC
            JSR     PLRUPD
            BRA     RCTUPD

; -----------------------------------------------------------------------------
STAPLAYP
; PLAY STATE PLOT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            JSR     RCTPLOT
            JSR     MAPPLOT
            JSR     PLRPLOT
            IFNE    ATRSAVE
            JSR     ATRPLOT
            ENDC
            RTS

; =============================================================================
; ATTRACT MODE STATE
; =============================================================================

; -----------------------------------------------------------------------------
STAATRI
; ATTRACT MODE INIT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.L  D1,-(A7)
            JSR     MAPINIT
            IFEQ    ATRSAVE
            JSR     ATRINIT                 ; ONLY IN ATTRACT PLAY MODE
            ENDC
            MOVE.B  #AUDMSKLP|AUDMU1ID,D1
            JSR     AUDPLAY                 ; PLAY ATTRACT MUSIC
            MOVE.B  #AUDACCN,(AUDACCSN)     ; REJECT SOUND EFFECTS
            JSR     PLRINIT
            MOVE.L  (A7)+,D1
            RTS

; -----------------------------------------------------------------------------
STAATRU
; ATTRACT MODE UPDATE
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.L  D1,-(A7)
            BTST    #KBDBITF1,(KBDEDGE)     ; CHECK USER INITIATED EXIT
            BNE     .EXIT
            IFEQ    ATRSAVE
            JSR     ATRUPD                  ; ONLY IN ATTRACT PLAY MODE
            ENDC
            BTST    #KBDBITPS,(KBDEDGE)     ; CHECK END OF RECORD
            BNE     .EXIT
            JSR     PLRUPD
            JSR     RCTUPD
            BRA     .END
.EXIT       MOVE.B  #AUDACCY,(AUDACCSN)     ; ALLOW NEW SOUNDS
            MOVE.B  #AUDENDID,D1            ; STOP MUSIC
            JSR     AUDPLAY
            MOVE.W  #STAINTR,(STANEXT)
.END        MOVE.L  (A7)+,D1
            RTS

; -----------------------------------------------------------------------------
STAATRP
; ATTRACT MODE PLOT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            JSR     STAPLAYP                ; PLOT GAME
            BRA     ATRPLOT                 ; OVERLAY TUTORIAL

; =============================================================================
; INTRO STATE
; =============================================================================

; -----------------------------------------------------------------------------
STAINTRI
; INTRO STATE INIT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            CLR.B   (GENFRMCT)              ; INIT FRAME COUNTER
            RTS

; -----------------------------------------------------------------------------
STAINTRU
; INTRO STATE UPDATE
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            CMP.B   #$FF,(GENFRMCT)
            BNE     .CHKK
            MOVE.W  #STAATTR,(STANEXT)
            RTS
.CHKK       BTST.B  #KBDBITF1,(KBDEDGE)
            BEQ     .END
            MOVE.L  D1,-(A7)
            MOVE.B  #AUDMSKNL|AUDARNID,D1
            JSR     AUDPLAY                 ; PLAY START SOUND
            MOVE.L  (A7)+,D1
            MOVE.W  #STAPLAY,(STANEXT)
.END        RTS

; -----------------------------------------------------------------------------
STAINTRP    EQU     INTPLOT
; INTRO STATE PLOT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; NOTE     - JUST A PLACEHOLDER FOR INTPLOT
; -----------------------------------------------------------------------------

; =============================================================================
; GAME OVER STATE
; =============================================================================

; -----------------------------------------------------------------------------
STAGOVRI
; GAME OVER STATE INIT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.L  D1,-(A7)
            MOVE.B  #AUDMSKLP|AUDMU2ID,D1
            JSR     AUDPLAY                 ; PLAY GAME OVER MUSIC
            MOVE.L  (A7)+,D1
            BRA     GOVINIT

; -----------------------------------------------------------------------------
STAGOVRU
; GAME OVER STATE UPDATE
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            TST.W   (GOVCUROF)              ; ARE CURTAINS FULLY CLOSED?
            BMI     .WAIT                   ; YES: DO NOT MOVE THEM MORE
            JSR     GOVUPD                  ; MOVE CURTAINS
            RTS
.WAIT       BTST    #KBDBITF1,(KBDEDGE)     ; IF CLOSED, CHECK FIRE 1
            BEQ     .END                    ; NOT PRESSED: NOTHING
            MOVE.W  #STAINTR,(STANEXT)      ; PRESSED: GO TO INTRO STATE
            MOVE.B  #AUDENDID,D1            ; STOP MUSIC
            JSR     AUDPLAY
.END        RTS

; -----------------------------------------------------------------------------
STAGOVRP
; GAME OVER STATE PLOT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            JSR     STAPLAYP                ; PLOT GAME
            BRA     GOVPLOT                 ; PLOT GAME OVER (CURTAIN)

; =============================================================================
; VICTORY STATE
; =============================================================================

; -----------------------------------------------------------------------------
STAVICI
; VICTORY STATE INIT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.L  D1,-(A7)
            MOVE.B  #AUDMSKLP|AUDMU3ID,D1
            JSR     AUDPLAY                 ; PLAY VICTORY MUSIC
            MOVE.L  (A7)+,D1
            BRA     VICINIT

; -----------------------------------------------------------------------------
STAVICU
; VICTORY STATE UPDATE
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            TST.W   (GOVCUROF)              ; ARE CURTAINS FULLY CLOSED?
            BMI     .WAIT                   ; YES: DO NOT MOVE THEM MORE
            JSR     VICUPD                  ; MOVE CURTAINS
            RTS
.WAIT       BTST    #KBDBITF1,(KBDEDGE)     ; IF CLOSED, CHECK FIRE 1
            BEQ     .END                    ; NOT PRESSED: NOTHING
            MOVE.W  #STAINTR,(STANEXT)      ; PRESSED: GO TO INTRO STATE
            MOVE.B  #AUDENDID,D1            ; STOP MUSIC
            JSR     AUDPLAY
.END        RTS

; -----------------------------------------------------------------------------
STAVICP
; GAME OVER STATE PLOT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            JSR     STAPLAYP                ; PLOT GAME
            BRA     VICPLOT                 ; PLOT VICTORY (CURTAIN)