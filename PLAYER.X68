; =============================================================================
; PLAYER MANAGEMENT
;
; THE PLAYER X AND Y (WORDS) CAN BE SEEN IN TWO WAYS:
; * AN INTEGER DENOTING THE ABSOLUTE POSITION IN A FINE-GRAINED SCALE.
; * A 8.8 FIXED POINT WHERE THE INTEGER PART REPRESENTS THE MAP CELL AND THE
;   FRACTIONAL PART REPRESENTS THE POSITION WITHIN THE MAP CELL. THUS, EACH
;   MAP CELL CONTAINS 256X256 POSSIBLE POSSITIONS INSIDE.
; THE PLAYER ORIENTATION IS WORD SO THAT 0 DENOTES AN ANGLE OF 0 DEGREES, 128
; DENOTES AN ANGLE OF 180 DEGREES AND SO ON. IT IS STORED AS A WORD TO
; PREVENT DATA ALIGNMENT PROBLEMS.
;
; AUTHOR  : ANTONI BURGUERA BURGUERA
; CONTACT : MY FAMILY NAME FOLLOWED BY THE AT SYMBOL THEN WRITE GMAIL AND END
;           WITH A DOT AND A COM.
; DATE    : 6-DEC-2018
; =============================================================================

; -----------------------------------------------------------------------------
PLRINIT
; INITIALIZES THE PLAYER
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.W  D0,-(A7)
            MOVE.W  (MAPPLRIX),D0
            MOVE.W  D0,(PLRPOSX)            ; INITIAL X COORDINATE
            MOVE.W  (MAPPLRIY),D0
            MOVE.W  D0,(PLRPOSY)            ; INITIAL Y COORDINATE
            MOVE.W  #PLRINIA,(PLRANGLE)     ; INITIAL ANGLE
            JSR     PLRGETDL                ; INITIALIZE DELTAS
            MOVE.W  #PLRMAXOX,(PLROXYG)     ; INITIAL OXYGEN
            CLR.W   (PLRPICKF)              ; INITIAL FUEL
            CLR.B   (PLRARGTM)              ; CLEAR ARGH TIMER
            MOVE.W  (A7)+,D0
            RTS

; -----------------------------------------------------------------------------
PLRUPD
; UPDATES THE PLAYER
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; NOTE     - ASSUMES DELTAX AND DELTAY ARE STORED CONSECUTIVELY AS WELL AS
;            PLRPOSX AND PLRPOSY
; -----------------------------------------------------------------------------
            MOVEM.L D0-D3/A0,-(A7)
            SUBQ.B  #1,(PLRARGTM)           ; DECREASE ARGH TIMER
            BCC     .ARGTDONE
            CLR.B   (PLRARGTM)
.ARGTDONE   MOVE.L  #$00010004,D2           ; HWORD: ANGULAR SPEED, LWORD:SPEED
            MOVE.B  (KBDVAL),D0
            BTST    #KBDBITF1,D0            ; SPEED BUTTON PRESSED?
            BEQ     .CONT                   ; NO: CONTINUE
            MOVE.L  #$00020003,D2           ; YES: INCREASE SPEEDS
.CONT       JSR     PLRGETDL                ; COMPUTE DELTAS
            BTST    #KBDBITDN,D0
            BNE     .DOWN
.CHKUP      BTST    #KBDBITUP,D0
            BNE     .UP
.CHKRT      SWAP    D2
            BTST    #KBDBITRT,D0
            BNE     .RIGHT
.CHKLF      BTST    #KBDBITLF,D0
            BNE     .LEFT
.END        MOVEM.L (A7)+,D0-D3/A0
            RTS
.DOWN       MOVE.L  (PLRDELTX),D3           ; TRY TO MOVE BACKWARDS
            NEG.L   D3
            JSR     PLRMOVE
            BRA     .CHKUP
.UP         MOVE.L  (PLRDELTX),D3           ; TRY TO MOVE FORWARD
            JSR     PLRMOVE
            BRA     .CHKRT
.RIGHT      SUB.W   D2,(PLRANGLE)           ; TURN RIGHT
            AND.W   #$FF,(PLRANGLE)
            BRA     .CHKLF
.LEFT       ADD.W   D2,(PLRANGLE)           ; TURN LEFT
            AND.W   #$FF,(PLRANGLE)
            BRA     .END

; -----------------------------------------------------------------------------
PLRPLOT
; PLOT THE SCOREBOARD
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D4,-(A7)

            ; PLOT OXYGEN

            MOVE.L  #MAPOXYCO,D1            ; PREPARE COLORS
            MOVE.B  #80,D0
            TRAP    #15
            ADDQ.B  #1,D0
            TRAP    #15

            MOVE.W  #PLROXYX0+1,D1          ; PLOT CURRENT OXYGEN
            MOVE.W  D1,D3
            ADD.W  (PLROXYG),D3
            MOVE.W  #PLROXYY0+1,D2
            MOVE.W  #PLROXYY1-1,D4
            MOVE.B  #87,D0
            TRAP    #15

            MOVE.L  #$00FFFFFF,D1           ; PREPARE COLORS
            MOVE.B  #80,D0
            TRAP    #15

            MOVE.W  #PLROXYX0,D1            ; PLOT OXYGEN FRAME
            MOVE.W  #PLROXYY0,D2
            MOVE.W  #PLROXYX1,D3
            MOVE.W  #PLROXYY1,D4
            MOVE.B  #90,D0
            TRAP    #15

            ; PLOT FUEL

            MOVE.L  #MAPFUECO,D1            ; PREPARE COLORS
            MOVE.B  #80,D0
            TRAP    #15
            ADDQ.B  #1,D0
            TRAP    #15

            MOVE.W  #PLRFUEX0,D1            ; TOP LEFT COORDINATES
            MOVE.W  #PLRFUEY0,D2
            MOVE.W  (PLRPICKF),D3           ; NUMBER OF FUEL TANKS
            MULU    #PLRMAXFU,D3            ; TIMES MAXIMUM WIDTH
            DIVU    (MAPNUMTR),D3           ; SIZE OF BAR
            ADD.W   #PLRFUEX0+1,D3          ; X RIGHT
            MOVE.W  #PLRFUEY1,D4            ; Y BOTTOM
            MOVE.B  #87,D0
            TRAP    #15

            MOVE.L  #$00FFFFFF,D1           ; PREPARE COLORS
            MOVE.B  #80,D0
            TRAP    #15

            MOVE.W  #PLRFUEX0,D1            ; PLOT FUEL FRAME
            MOVE.W  #PLRFUEY0,D2
            MOVE.W  #PLRFUEX1,D3
            MOVE.W  #PLRFUEY1,D4
            MOVE.B  #90,D0
            TRAP    #15

            MOVEM.L (A7)+,D0-D4
            RTS

; -----------------------------------------------------------------------------
PLRMOVE
; MOVES PLAYER IF POSSIBLE
; INPUT    - D3.L PROPOSED MOTION (HIGH WORD X, LOW WORD Y)
; OUTPUT   - NONE
; MODIFIES - NONE
; NOTE     - THIS IS A VERY SIMPLISTIC APPROACH TO CHECK COLLISIONS. IT JUST
;            STOPS THE PLAYER IF MOTION IS NOT POSSIBLE. ALSO, SINCE IT CONSI-
;            DERS THE PLAYER AS A POINT, IT MAY FAIL BETWEEN TWO DIAGONALLY
;            PLACED BLOCKS.
; -----------------------------------------------------------------------------
            MOVEM.L D0-D3/A0,-(A7)
            MOVE.L  (PLRPOSX),D2
            ADD.L   D3,D2
            MOVE.W  D2,D1
            ASR.W   #8,D1                   ; INT(Y)
            SWAP    D2
            MOVE.W  D2,D0
            ASR.W   #8,D0                   ; INT(X)
            SWAP    D2
            JSR     MAPADDR
            MOVE.B  (A0),D0
            BEQ     .STORE                  ; 0->MOVE
            CMP.B   #MAPWALID,D0            ; IS IT A WALL?
            BNE     .CHKFUE
            TST.B   (PLRARGTM)              ; TIME TO PLAY SOUND EFFECT?
            BNE     .END                    ; NO: DO NOTHING
            MOVE.B  #AUDMSKNL|AUDARGID,D1   ; YES: PREPARE SOUND
            JSR     AUDPLAY                 ; PLAY ARGH SOUND
            MOVE.B  #PLRARGTI,(PLRARGTM)    ; RESTART TIMER
            BRA     .END                    ; DO NOT MOVE
.CHKFUE     CMP.B   #MAPOXYID,D0            ; IS IT OXYGEN?
            BNE     .CHKTRE
            MOVE.W  #PLROXYBN,D0            ; YES: ADD OXYGEN
            JSR     PLRADDO
            MOVE.B  #AUDMSKNL|AUDPK1ID,D1   ; PREPARE PICK OXYGEN SOUND
            JSR     AUDPLAY                 ; PLAY SOUND EFFECT
            BRA     .CLRBLK
.CHKTRE     CMP.B   #MAPFUEID,D0            ; IS IT FUEL?
            BNE     .CLRBLK
            ADDQ.W  #1,(PLRPICKF)           ; YES? INCREASE PICKED FUEL TANKS
            MOVE.B  #AUDMSKNL|AUDPK2ID,D1   ; PREPARE PICK FUELE SOUND
            JSR     AUDPLAY                 ; PLAY SOUND EFFECT
.CLRBLK     CLR.B   (A0)                    ; REMOVE BLOCK
.STORE      MOVE.L  D2,(PLRPOSX)            ; STORE POSITION
            MOVE.W  #7,D2                   ; PROPOSE CONSUMPTION EVERY 8 FRMS
            BTST    #KBDBITF1,(KBDVAL)
            BEQ     .NOGAS
            ASR.W   #1,D2                   ; IF FIRE1, DOUBLE RATE
.NOGAS      MOVE.B  (GENFRMCT),D1
            AND.B   D2,D1
            BNE     .END                    ; IS IT THE MOMENT TO CONSUME?
            MOVE.W  #-1,D0                  ; YES: DO IT.
            JSR     PLRADDO
.END        MOVEM.L (A7)+,D0-D3/A0
            RTS

; -----------------------------------------------------------------------------
PLRGETDL
; COMPUTES THE DELTAX AND DELTA Y
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; NOTE     - ASSUMES DELTAX AND DELTAY ARE CONSECUTIVELY STORED
; -----------------------------------------------------------------------------
            MOVEM.L D0-D1/A0,-(A7)
            MOVE.W  (PLRANGLE),D0           ; GET ANGLE
            AND.L   #$FF,D0                 ; ENSURE SINGLE BYTE
            NOT.B   D0                      ; COMPUTE 360-ANGLE
            ADD.L   D0,D0                   ; TIMES TWO TO ACCESS WORD TABLE
            MOVE.L  D0,A0                   ; PREPARE FOR ADDRESSING
            MOVE.W  RCTSINTB(A0),D0         ; DELTAY UNSCALED
            ADD.L   #64*2,A0                ; OFFSET TO COSINUS TABLE
            SWAP    D0                      ; PREPARE TO STORE DELTAX
            MOVE.W  RCTSINTB(A0),D0         ; DELTAX UNSCALED
            ASR.W   D2,D0                   ; DELTAX SCALED
            SWAP    D0                      ; PREPARE TO MODIFY DELTAY
            ASR.W   D2,D0                   ; DELTAY SCALED
            MOVE.L  D0,(PLRDELTX)           ; STORE DELTAS
            MOVEM.L (A7)+,D0-D1/A0
            RTS

; -----------------------------------------------------------------------------
PLRADDO
; ADDS/SUBSTRACTS OXYGEN TO THE PLAYER
; INPUT    - D0.W   AMOUNT TO ADD
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.W  D1,-(A7)
            MOVE.W  (PLROXYG),D1
            ADD.W   D0,D1
            BPL     .CONT
            CLR.W   D1
.CONT       CMP.W   #PLRMAXOX,D1
            BLE     .STORE
            MOVE.W  #PLRMAXOX,D1
.STORE      MOVE.W  D1,(PLROXYG)
            MOVE.W  (A7)+,D1
            RTS