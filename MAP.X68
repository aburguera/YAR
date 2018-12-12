; =============================================================================
; MAP MANAGEMENT
;
; AUTHOR  : ANTONI BURGUERA BURGUERA
; CONTACT : MY FAMILY NAME FOLLOWED BY THE AT SYMBOL THEN WRITE GMAIL AND END
;           WITH A DOT AND A COM.
; DATE    : 6-DEC-2018
; =============================================================================

; -----------------------------------------------------------------------------
MAPINIT
; COPIES MAPDATAO TO MAPDATA. THIS IS NECESSARY (THOUGH IT COULD BE OPTIMIZED)
; SINCE MAPDATA IS MODIFIED WHILE PLAYING WHEN OBJECTS ARE PICKED.
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0/A0-A1,-(A7)
            MOVE.W  #MAPWIDTH*MAPWIDTH,D0
            LEA     MAPDATAO,A0
            LEA     MAPDATA,A1
            ASR.W   #1,D0                   ; LET US COPY WORD BY WORD
.LOOP       MOVE.W  (A0)+,(A1)+
            DBRA    D0,.LOOP
            MOVEM.L (A7)+,D0/A0-A1
            RTS

; -----------------------------------------------------------------------------
MAPPLOT
; PLOTS THE MINIMAP AND THE PLAYER OVERLAYED TO IT
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            IFNE    CASMINIM
            MOVEM.L D0-D4,-(A7)
            MOVE.W  (PLRPOSY),D0            ; GET PLAYER Y
            JSR     .CNTCOORD               ; GET TOP MAP Y TO PLOT MINIMAP
            MOVE.W  D0,D1
            MOVE.W  (PLRPOSX),D0            ; GET PLAYER X
            JSR     .CNTCOORD               ; GET LEFT MAP X TO PLOT MINIMAP
            JSR     MAPPLOTM                ; PLOT MINIMAP
            JSR     MAPPLOTP                ; OVERLAY PLAYER OVER MINIMAP

            ; COVER BORDERS. JUST COMMENT FROM THE NEXT LINE TO THE LINE
            ; BEFORE THE MOVEM TO SEE THE MAGIC OF SMOOTH MINIMAP SCROLLING :P

            CLR.L   D1                      ; PREPARE COLORS
            MOVE.B  #80,D0
            TRAP    #15
            ADDQ.B  #1,D0
            TRAP    #15

            ; COVER LEFT BORDER

            MOVE.W  #MAPMINPX-MAPMINCS*2,D1
            MOVE.W  #MAPMINPY-MAPMINCS*2,D2
            MOVE.W  #MAPMINPX+MAPMINCS/2,D3
            MOVE.W  #MAPMINPY+MAPMINCS*MAPMINNC+MAPMINCS*2,D4
            MOVE.B  #87,D0
            TRAP    #15

            ; COVER TOP BORDER

            MOVE.W  #MAPMINPX-MAPMINCS*2,D1
            MOVE.W  #MAPMINPY-MAPMINCS*2,D2
            MOVE.W  #MAPMINPX+MAPMINCS*MAPMINNC+MAPMINCS*2,D3
            MOVE.W  #MAPMINPY+MAPMINCS/2,D4
            MOVE.B  #87,D0
            TRAP    #15

            ; COVER RIGHT BORDER

            MOVE.W  #MAPMINPX+MAPMINCS*MAPMINNC-MAPMINCS/2,D1
            MOVE.W  #MAPMINPY-MAPMINCS,D2
            MOVE.W  #MAPMINPX+MAPMINCS*MAPMINNC+MAPMINCS*2,D3
            MOVE.W  #MAPMINPY+MAPMINCS*MAPMINNC+MAPMINCS*2,D4
            MOVE.B  #87,D0
            TRAP    #15

            ; COVER BOTTOM BORDER

            MOVE.W  #MAPMINPX-MAPMINCS,D1
            MOVE.W  #MAPMINPY+MAPMINCS*MAPMINNC-MAPMINCS/2,D2
            MOVE.W  #MAPMINPX+MAPMINCS*MAPMINNC+MAPMINCS*2,D3
            MOVE.W  #MAPMINPY+MAPMINCS*MAPMINNC+MAPMINCS*2,D4
            MOVE.B  #87,D0
            TRAP    #15

            ; PLOT INNER FRAME

            MOVE.L  #$00FFFFFF,D1
            MOVE.B  #80,D0
            TRAP    #15
            MOVE.W  #MAPMINPX+MAPMINCS/2,D1
            MOVE.W  #MAPMINPY+MAPMINCS/2,D2
            MOVE.W  #MAPMINPX+MAPMINCS*MAPMINNC-MAPMINCS/2,D3
            MOVE.W  #MAPMINPY+MAPMINCS*MAPMINNC-MAPMINCS/2,D4
            MOVE.B  #90,D0
            TRAP    #15
            MOVEM.L (A7)+,D0-D4
            ENDC
            RTS
            ; TRIES TO CENTER THE MAP IN THE SPECIFIED COORDINATE.
.CNTCOORD   MOVE.W  D0,D2                   ; COPY THE COORDINATE
            SUB.W   #(MAPMINNC/2)<<8,D0     ; PROPOSE INITIAL COORDINATE
            BGT     .CHKMAX                 ; IF LEFT BOUNDARY OK, CHK RIGHT
            CLR.W   D0                      ; IF LEFT BOUNDARY NOT OK, OUT=0
.END        RTS
.CHKMAX     ADD.W   #(MAPMINNC/2)<<8,D2     ; CHECK RIGHT BOUNDARY
            CMP     #MAPWIDTH<<8,D2         ; IS IT WITHIN LIMITS?
            BLT     .END                    ; YES: ACCEPT PROPOSED COORDINATE
            MOVE.W  #(MAPWIDTH-MAPMINNC+1)<<8,D0 ; NO: USE MAX. COORDINATE
            RTS

; -----------------------------------------------------------------------------
MAPPLOTM
; PLOTS A MINIMAP OF 15X15 CELLS BEGINNING AT THE SPECIFIED CELL
; INPUT    - D0.W   X (8.8 FIXED POINT)
;            D1.W   Y (8.8 FIXED POINT)
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------

            MOVEM.L D0-D7/A0-A1,-(A7)
            EXG     D0,D6                   ; STORE D0 AND D1
            EXG     D1,D7

            ; PLOT MINIMAP FRAME

            MOVE.L  #$00FFFFFF,D1
            MOVE.B  #80,D0
            TRAP    #15
            ADDQ.B  #1,D0
            CLR.L   D1
            TRAP    #15
            MOVE.W  #MAPMINPX-2*MAPMINCS-1,D1
            MOVE.W  #MAPMINPY-2*MAPMINCS-1,D2
            MOVE.W  #MAPMINPX+MAPMINCS*MAPMINNC+2*MAPMINCS+1,D3
            MOVE.W  #MAPMINPY+MAPMINCS*MAPMINNC+2*MAPMINCS+1,D4
            MOVE.B  #87,D0
            TRAP    #15
            EXG     D0,D6
            EXG     D1,D7

            ; PREPARE OFFSETS

            MOVE.W  D0,D4
            MOVE.W  D1,D3
            ASR.W   #8-MAPMINSH,D4          ; PREPARE FRACTIONAL PART TO BE
            ASR.W   #8-MAPMINSH,D3          ; USED AS AN OFFSET.
            AND.W   #MAPMINCS-1,D4          ; PICK ONLY THE BITS THAT DEFINE
            AND.W   #MAPMINCS-1,D3          ; AN OFFSET.
            SUB.W   #MAPMINCS/2,D3          ; SUB HALF THE CELL SIZE TO KEEP
            SUB.W   #MAPMINCS/2,D4          ; THE MINIMAP CENTERED.
            ASR.W   #8,D0                   ; GET INT PART (TO ACCESS MAP CELL)
            ASR.W   #8,D1
            SWAP    D4

            ; PLOT MINIMAP

            JSR     MAPADDR                 ; GET INITIAL ADDRESS
            MOVE.W  #MAPMINPY,D4            ; INITIAL Y
            SUB.W   D3,D4
            MOVE.W  #MAPMINNC-1,D7          ; D7=ROW ITERATOR
.LOOPY      MOVE.W  D4,D2                   ; UPDATE YINI
            ADD.W   #MAPMINCS,D4            ; UPDATE YEND
            MOVE.W  #MAPMINPX,D3            ; INITIAL X
            SWAP    D4
            SUB.W   D4,D3
            SWAP    D4
            MOVE.W  #MAPMINNC-1,D6          ; D6=COLUMN ITERATOR
.LOOPX      MOVE.W  D3,D1                   ; UPDATE XINI
            ADD.W   #MAPMINCS,D3            ; UPDATE XEND
            MOVE.B  (A0)+,D5                ; GET VALUE
            BEQ     .CONT                   ; ZERO? PLOT NOTHING
            AND.L   #$FF,D5                 ; ENSURE IS CORRECT ADDRESS
            ASL.L   #2,D5                   ; PREPARE TO ACCESS LONG ARRAY
            LEA     .COLS,A1
            MOVE.L  (A1,D5),D5              ; GET COLOR
            EXG     D5,D1                   ; PUT IT IN D1
            MOVE.B  #80,D0                  ; PEN COLOR
            TRAP    #15
            ADDQ.B  #1,D0                   ; FILL COLOR
            ADD.L   #$00333333,D1
            TRAP    #15
            EXG     D5,D1                   ; RESTORE D1
            MOVE.B  #87,D0                  ; OTHERWISE, PLOT SQUARE
            TRAP    #15
.CONT       DBRA    D6,.LOOPX               ; LOOP FOR EVERY COLUMN
            ADD.L   #MAPWIDTH-MAPMINNC,A0   ; UPDATE ADDRESS FOR NEXT ROW
            DBRA    D7,.LOOPY               ; LOOP FOR EVERY ROW
            MOVEM.L (A7)+,D0-D7/A0-A1
            RTS
.COLS       DC.L    $00000000,MAPOBSCO-$00000033,MAPFUECO-$00003300
            DC.L    MAPOXYCO-$00330000

; -----------------------------------------------------------------------------
MAPPLOTP
; PLOTS THE PLAYER ON THE MINIMAP AREA, ASSUMING THE MINIMAP IS PLOTTED STAR-
; TING AT THE SPECIFIED COORDINATES.
; INPUT    - D0.W   X (8.8 FIXED POINT)
;            D1.W   Y (8.8 FIXED POINT)
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7/A0,-(A7)
            MOVE.W  (PLRPOSX),D3            ; GET PLAYER POSITION
            MOVE.W  (PLRPOSY),D4
            SUB.W   D0,D3                   ; GET COORDINATES RELATIVE TO MI-
            SUB.W   D1,D4                   ; NIMAP ORIGIN.
            ASR.W   #8-MAPMINSH,D3          ; SCALE TO MINIMAP SIZE
            ASR.W   #8-MAPMINSH,D4
            ADD.W   #MAPMINPX,D3            ; TRANSLATE TO MINIMAP PLOT COORD.
            ADD.W   #MAPMINPY,D4

            MOVE.L  #$0000FF00,D1           ; DEFINE PEN COLOR
            MOVE.B  #80,D0
            TRAP    #15
            MOVE.L  #$000000FF,D1           ; DEFINE FILL COLOR
            ADDQ.B  #1,D0
            TRAP    #15
            MOVE.W  D3,D1
            MOVE.W  D4,D2
            MOVEM.L D1-D4,-(A7)             ; STORE THEM FOR FURTHER USE

            ; PLOT PLAYER ORIENTATION

            ADD.W   #MAPMINCS/2,D1          ; CENTRAL COORDINATES
            ADD.W   #MAPMINCS/2,D2
            MOVE.W  (PLRANGLE),D0           ; GET PLAYER ORIENTATION
            NOT.W   D0
            SUB.W   #32,D0
            AND.L   #$FF,D0                 ; ENSURE IT IS AN ADDRESS
            ADD     D0,D0                   ; TIMES TWO TO ACCESS WORD TABLE
            LEA     RCTSINTB,A0
            MOVE.W  (A0,D0),D4              ; SIN ANGLE
            ADD.W   #64*2,D0
            MOVE.W  (A0,D0),D3              ; COS ANGLE
            ASR.W   #8-MAPMINSH-2,D3        ; SCALE TO HAVE THE DESIRED LENGTH
            ASR.W   #8-MAPMINSH-2,D4
            ADD.W   D1,D3
            ADD.W   D2,D4
            MOVE.B  #84,D0
            TRAP    #15
            EXG     D3,D5                   ; STORE END COORDINATES
            EXG     D4,D6
            MOVE.W  (PLRANGLE),D0           ; GET PLAYER ORIENTATION
            NOT.W   D0
            ADD.W   #32,D0
            AND.L   #$FF,D0                 ; ENSURE IT IS ADDRESS
            ADD     D0,D0                   ; TIMES TWO TO ACCESS WORD TABLE
            LEA     RCTSINTB,A0
            MOVE.W  (A0,D0),D4              ; SIN ANGLE
            ADD.W   #64*2,D0
            MOVE.W  (A0,D0),D3              ; COS ANGLE
            ASR.W   #8-MAPMINSH-2,D3        ; SCALE TO HAVE THE DESIRED LENGTH
            ASR.W   #8-MAPMINSH-2,D4
            ADD.W   D1,D3
            ADD.W   D2,D4
            MOVE.B  #84,D0
            TRAP    #15
            EXG     D5,D1
            EXG     D6,D2                   ; PUT PREVIOUS END COORD IN D1,D2
            TRAP    #15                     ; JOIN THE TWO ENDS
            MOVEM.L (A7)+,D1-D4             ; RESTORE PREVIOUSLY SAVED
            MOVE.B  (GENFRMCT),D5           ; MAKE THE PLAYER PLOT INCREASE...
            ASR.W   #2,D5                   ; AND DECREASE SIZE WITH TIME.
            AND.W   #3,D5
            SUB.W   D5,D1
            SUB.W   D5,D2
            ADD.W   D5,D3
            ADD.W   D5,D4
            ADD.W   #MAPMINCS,D3
            ADD.W   #MAPMINCS,D4
            MOVE.B  #88,D0                  ; PLOT SMALL CIRCLE
            TRAP    #15
            MOVEM.L (A7)+,D0-D7/A0
            RTS

; -----------------------------------------------------------------------------
MAPADDR
; GETS THE MAP ADDRESS OF THE SPECIFIED CELL
; INPUT    - D0.W   X (8 BIT, INTEGER)
;            D1.W   Y (8 BIT, INTEGER)
; OUTPUT   - A0 ADDRESS
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D1,-(A7)
            LEA     MAPDATA,A0
            ASL.W   #MAPWSHFT,D1
            ADD.W   D1,D0
            AND.L   #$FFFF,D0
            LEA     (A0,D0),A0
            MOVEM.L (A7)+,D0-D1
            RTS