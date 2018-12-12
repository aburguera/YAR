; =============================================================================
; RAYCASTER MANAGEMENT
;
; THIS RAYCASTER WORKS SIMILARY TO WOLFENSTEIN 3D WITH A FEW DIFFERENCES:
; * WE USE 8.8 FIXED POINT INSTEAD OF 16.16 TO EASE AND SPEED UP MULTIPLICA-
;   TIONS. THIS LEADS TO 256 PLAYER POSITIONS WITHIN EACH GRID CELL INSTEAD OF
;   65536 BUT, ANYWAY, 256 IS MORE THAN ENOUGH. THE ONLY REAL PROBLEM OF THIS
;   SIMPLIFICATION IS IN THE TANGENTS TABLE IN RCTDATA.X68. VALUES FOR ANGLES
;   CLOSE TO 90 HAVE BEEN TRIMMED SINCE THEY DIDN'T FIT IN 8.8 FIXED POINT. THIS
;   IS RESPONSIBLE FOR SOME GLITCHES IN THE RENDERED WALLS.
; * OUR VERSION ONLY USES "LINEAR" TEXTURES. THAT IS, A TEXTURE DEFINES A WHOLE
;   VERTICAL STRIPE. USING BIDIMENSIONAL TEXTURES WOULD NOT BE DIFFICULT TO
;   ADD, BUT PAINFULLY SLOW GIVEN THE WAY IN WHICH EASY68K HANDLES DRAWING.
; * SPRITE RENDERER IS NOT IMPLEMENTED.
;
; THIS RAYCASTER RELIES ON THE PRECOMPUTED SIN/COS, TANGENTS AND SCREEN ANGLES
; WITHIN RCTDATA.X68.
; * ANGLES ARE CODED AS ONE BYTE VALUE, SO THAT 0 DENOTES AN ANGLE OF 0 DEGREES
;   128 DENOTES AN ANGLE OF 180 AND SO ON.
; * THE COMMENTS IN RCTDATA.X68 ARE SELF-EXPLANATORY.
; * RCTDATA.X68 HAS BEEN GENERATED WITH THE PYTHON SCRIPT CREATE_DATA.PY
; * A FINE SCALE IS USED TO ALLOW MORE RESOLUTION IN TANGENT COMPUTATION
;   SINCE NO HUGE SPACE IS REQUIRED AS TANGENTS TAKE PROFIT OF QUADRANTS.
; * THE TABLE OF SINUS CONTAINS MORE THAN 360 DEGREES TO TAKE PROFIT OF THE
;   RELATIONSHIP BETWEEN SINUS AND COSINUS.
;
; THE FOLLOWING LINKS ARE HIGHLY RECOMMENDED:
; * SIMPLE RAYCASTING
;   http://retro-system.com/raycast2.htm
;   A REALLY NICE C IMPLEMENTATION OF A RAYCASTER WHICH SERVED AS BASIS FOR
;   THIS MC68000 CODE.
; * LODE'S COMPUTER GRAPHICS TUTORIAL - RAYCASTING.
;   https://lodev.org/cgtutor/raycasting.html
;   A COMPLETE AND COMPREHENSIVE TUTORIAL ON RAYCASTING WITH C SOURCE CODE.
; * WOLFENSTEIN 3D'S MAP RENDERER
;   https://youtu.be/eOCQfxRQ2pY
;   A DETAILED EXPLANATION OF HOW THE ACTUAL WOLFENSTEIN 3D WORKS.
; * WOLFENSTEIN 3D SOURCE CODE
;   https://github.com/id-Software/wolf3d
;   THE SOURCE CODE.
;
; AUTHOR  : ANTONI BURGUERA BURGUERA
; CONTACT : MY FAMILY NAME FOLLOWED BY THE AT SYMBOL THEN WRITE GMAIL AND END
;           WITH A DOT AND A COM.
; DATE    : 6-DEC-2018
; =============================================================================

; -----------------------------------------------------------------------------
RCTUPD
; UPDATES THE RAYCASTER.
; INPUT    - NONE BY REGISTER
;            THE RENDERER INPUT ARE THREE VARIABLES:
;            * (PLRPOSX) AND (PLRPOSY) ARE THE CAMERA POSITION IN FIX. PNT. 8.8
;              THE INTEGER PART DENOTES THE CELL WITHIN THE MAP AND THE FRAC-
;              TIONARY PART DENOTES THE POSITION WITHIN THE CELL.
;            * (PLRANGLE) IS THE CAMERA ORIENTATION. THE ANGLE IS EXPRESSED
;              IN 0-255 FORMAT. THE VARIABLE IS 16 BIT INSTEAD OF 8 FOR
;              DATA ALIGNMENT CONVENIENCE.
; OUTPUT   - NONE BY REGISTER
;            THE RAYCASTER UPDATES THREE ARRAYS. EACH POSITION OF THE ARRAY IS
;            RELATED TO ONE COLUMN IN THE SCREEN.
;            * RCTHVEC IS AN ARRAY OF WORDS. EACH WORD STATES THE HEIGHT OF ONE
;              PIXELS COLUMN.
;            * RCTDVEC IS AN ARRAY OF WORDS. EACH WORD STATES THE PERPENDICULAR
;              DISTANCE FROM THE CAMERA TO THE DETECTED WALL.
;            * RCTCVEC IS AN ARRAY OF LONGS. EACH LONG IS THE COLOR OF THE COR-
;              RESPONDING COLUMN. THE MSB, WHICH IS UNUSED FOR THE COLOR, IS
;              SET TO FF OR 00 DEPENDING OF THE HIT BEING HORIZONTAL OR VER-
;              TICAL.
; MODIFIES - NONE
; NOTE     - EXCEPT FOR THE INPUT AND THE OUTPUT, THE REMAINING VARIABLES ARE
;            LOCAL. THEY ARE NOT ALLOCATED IN THE STACK TO INCREASE SPEED.
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7/A0-A6,-(A7)       ; STORE REGISTERS

            ; PRECOMPUTE SOME PARAMETERS

            MOVE.W  (PLRPOSX),(RCTXPL)
            AND.W   #$00FF,(RCTXPL)         ; DISTANCE TO THE LEFT SIDE OF CELL
            MOVE.W  #RCTCELLS,D0
            SUB.W   (RCTXPL),D0
            MOVE.W  D0,(RCTXPR)             ; DISTANCE TO THE RIGHT SIDE OF CELL
            MOVE.W  (PLRPOSY),(RCTYPU)
            AND.W   #$00FF,(RCTYPU)         ; DISTANCE TO THE TOP SIDE OF CELL
            MOVE.W  #RCTCELLS,D0
            SUB.W   (RCTYPU),D0
            MOVE.W  D0,(RCTYPD)             ; DISTANCE TO BOTTOM SIDE OF CELL

            CLR.L   D0                      ; PREPARE FOR ADDRESSING
            MOVE.W  (PLRANGLE),D0           ; VIEW ANGLE
            ADD.W   D0,D0                   ; TIMES TO TO ACCESS RCTSINTB
            MOVE.L  D0,A0
            MOVE.W  RCTSINTB(A0),(RCTVSIN)  ; SIN(VIEW ANGLE)
            MOVE.W  RCTCOSTB(A0),(RCTVCOS)  ; COS(VIEW ANGLE)

            ASL.W   #RCTA2FSH-1,D0          ; ANGLE TO FINEANGLE
            MOVE.W  D0,(RCTMIDA)            ; MIDANGLE IN FINE SCALE

            LEA     RCTPXANG,A0             ; POINTER TO SCREEN ANGLES
            LEA     RCTFNTAN,A1             ; POINTER TO FINE TANGENT
            LEA     MAPDATA,A2              ; POINTER TO THE MAP
            LEA     RCTHVEC,A3              ; HEIGHTS VECTOR (OUTPUT)
            LEA     RCTDVEC,A4              ; DISTANCE VECTOR (OUTPUT)
            LEA     RCTCVEC,A5              ; COLOR VECTOR (OUTPUT)
            MOVE.W  #SCRWIDTH-1,D7          ; COLUMN ITERATOR

            ; LOOP FOR EVERY SCREEN COLUMN

.LOOPSCR    MOVE.W  (RCTMIDA),D0
            ADD.W   (A0)+,D0                ; ABSOLUTE ANGLE OF CURRENT COLUMN
            AND.L   #RCTFINAN-1,D0          ; NORMALIZE AND PREPARE FOR ADDR.

            ; PREPARE PARAMETERS ACCORDING TO QUADRANT. THIS PART COULD HAVE BEEN
            ; OPTIMIZED TO REDUCE SPACE BY USING TABLES OF VALUES AND POINTERS,
            ; BUT SPEED IS MORE IMPORTANT HERE.

            CMP.W   #$1FF,D0
            BLE     .QUAD1                  ; BELOW 90 DEGREES
            CMP.W   #$3FF,D0
            BLE     .QUAD2                  ; BELOW 180 DEGREES
            CMP.W   #$5FF,D0
            BLE     .QUAD3                  ; BELOW 270 DEGREES

            ; FOURTH QUADRANT (ANGLE>270 DEGREES)

.QUAD4      MOVE.W  #1,D1                   ; D1.W=GRIDSTEP.X
            MOVE.W  #1,D2                   ; D2.W=GRIDSTEP.Y
            MOVE.W  #$7FF,D4
            SUB.W   D0,D4                   ; 360DEG-1-ANGLE
            ADD.W   D4,D4                   ; TIMES 2 TO ACCESS A WORD TABLE
            AND.L   #$FFFF,D4               ; ENSURE IT IS A POINTER
            MOVE.W  (A1,D4),D4              ; D4.W=YSTEP
            SUB.W   #$5FF+1,D0              ; ANGLE-270DEG
            ADD.W   D0,D0                   ; TIMES 2 TO ACCESS WORD TABLE
            MOVE.W  (A1,D0),D3              ; D3.W=XSTEP
            MOVE.W  (RCTXPR),D5             ; D5.W=XPARTIAL
            MOVE.W  (RCTYPD),D6             ; D6.W=YPARTIAL
            BRA     .CONT0

            ; THIRD QUADRANT (180<ANGLE<=270 DEGREES)

.QUAD3      MOVE.W  #-1,D1                  ; D1.W=GRIDSTEP.X
            MOVE.W  #1,D2                   ; D2.W=GRIDSTEP.Y
            MOVE.L  #$5FF,D3
            SUB.L   D0,D3                   ; 270DEG-1-ANGLE
            ADD.W   D3,D3                   ; TIMES 2 TO ACCESS WORD TABLE
            MOVE.W  (A1,D3),D3
            NEG.W   D3                      ; D3.W=XSTEP
            SUB.W   #$3FF+1,D0              ; ANGLE-180DEG
            ADD.W   D0,D0                   ; TIMES 2 TO ACCESS WORD TABLE
            MOVE.W  (A1,D0),D4              ; D4.W=YSTEP
            MOVE.W  (RCTXPL),D5             ; D5.W=XPARTIAL
            MOVE.W  (RCTYPD),D6             ; D6.W=YPARTIAL
            BRA     .CONT0

            ; SECOND QUADRANT (90<ANGLE<=180 DEGREES)

.QUAD2      MOVE.W  #-1,D1                  ; D1.W=GRIDSTEP.X
            MOVE.W  #-1,D2                  ; D2.W=GRIDSTEP.Y
            MOVE.W  #$3FF,D4
            SUB.W   D0,D4                   ; 180DEG-1-ANGLE
            ADD.W   D4,D4                   ; TIMES 2 TO ACCESS A WORD TABLE
            AND.L   #$FFFF,D4               ; ENSURE IT IS A POINTER
            MOVE.W  (A1,D4),D4
            NEG.W   D4                      ; D4.W=YSTEP
            SUB.W   #$1FF+1,D0              ; ANGLE-90DEG
            ADD.W   D0,D0                   ; TIMES 2 TO ACCESS WORD TABLE
            MOVE.W  (A1,D0),D3
            NEG.W   D3                      ; D3.W=XSTEP
            MOVE.W  (RCTXPL),D5             ; D5.W=XPARTIAL
            MOVE.W  (RCTYPU),D6             ; D6.W=YPARTIAL
            BRA     .CONT0

            ; FIRST QUADRANT (ANGLE<=90 DEGREES)

.QUAD1      MOVE.W  #1,D1                   ; D1.W=GRIDSTEP.X
            MOVE.W  #-1,D2                  ; D2.W=GRIDSTEP.Y
            MOVE.L  #$1FF,D3
            SUB.L   D0,D3                   ; 90DEG-1-ANGLE
            ADD.W   D3,D3                   ; TIMES 2 TO ACCESS WORD TABLE
            MOVE.W  (A1,D3),D3              ; D3.W=XSTEP
            ADD.W   D0,D0                   ; TIMES 2 TO ACCESS WORD TABLE
            MOVE.W  (A1,D0),D4
            NEG.W   D4                      ; D4.W=YSTEP
            MOVE.W  (RCTXPR),D5             ; D5.W=XPARTIAL
            MOVE.W  (RCTYPU),D6             ; D6.W=YPARTIAL

            ; PRECOMPUTE SOME COLUMN-RELATED PARAMETERS

.CONT0      MOVE.W  D4,D0                   ; D0.W=YSTEP
            MULS    D5,D0                   ; D0.L=YSTEP*XPARTIAL
            ASR.L   #8,D0                   ; READJUST FIXED POINT
            ADD.W   (PLRPOSY),D0            ; D0.W=YSTEP*XPARTIAL+PLAYERY
            MOVE.W  D0,(RCTYINT)            ; Y INTERCEPT
            ASR.W   #8-MAPWSHFT,D0
            AND.W   #~(MAPWIDTH-1),D0       ; INT(YINTERCEPT)*MAPW
            MOVE.W  D0,(RCTXSPOT)           ; PARTIAL XSPOT
            MOVE.W  (PLRPOSX),D0
            ROR.W   #8,D0
            AND.W   #$FF,D0                 ; INT(PLRPOSX)
            ADD.W   D1,D0                   ; INT(PLRPOSX)+GRIDSTEP.X
            MOVE.W  D0,(RCTXGRID)           ; XGRID
            ADD.W   D0,(RCTXSPOT)           ; XSPOT
            MOVE.W  D3,D0                   ; D0.W=XSTEP
            MULS    D6,D0                   ; D0.L=XSTEP*YPARTIAL
            ASR.L   #8,D0                   ; READJUST FIXED POINT
            ADD.W   (PLRPOSX),D0            ; D0.W=XSTEP*YPARTIAL+PLAYERX
            MOVE.W  D0,(RCTXINT)            ; X INTERCEPT
            ASR.W   #8,D0                   ; INT(XINTERCEPT)
            MOVE.W  D0,(RCTYSPOT)           ; PARTIAL YSPOT
            MOVE.W  (PLRPOSY),D0
            ROR.W   #8,D0
            AND.W   #$FF,D0                 ; INT(PLRPOSY)
            ADD.W   D2,D0                   ; INT(PLRPOSY)+GRIDSTEP.Y
            MOVE.W  D0,(RCTYGRID)           ; YGRID
            ASL.W   #MAPWSHFT,D0            ; YGRID*MAPWIDTH
            ADD.W   D0,(RCTYSPOT)           ; Y SPOT

            ; LOOP CONSIDERING VERTICAL TRANSITIONS IN MAP

.LOOPVERT   MOVE.W  (RCTYINT),D0
            ASR.W   #8,D0                   ; D0.W=INT(YINTERCEPT)
            CMP.W   #-1,D2                  ; IF GRIDSTEP.Y==-1 AND
            BNE     .CHKV0                  ; INT(YINTERC)<=YGRID GO HORENTRY
            CMP.W   (RCTYGRID),D0
            BLE     .HORENTRY
.CHKV0      CMP.W   #1,D2                   ; IF GRIDSTEP.Y==1 AND
            BNE     .VERENTRY               ; INT(YINTERC)>=YGRID GO HORENTRY
            CMP.W   (RCTYGRID),D0
            BGE     .HORENTRY
.VERENTRY
            CLR.L   D0
            MOVE.W  (RCTXSPOT),D0
            MOVE.B  (A2,D0),D0              ; D0.B=MAPDATA[XSPOT]
            BEQ     .NOHIT
            OR.B    #RCTMSKVC,D0            ; STATE VERTICAL COLLISION
            MOVE.B  D0,D3                   ; STORE ID
            MOVE.W  (RCTXGRID),D0
            ASL.W   #8,D0
            MOVE.W  D0,(RCTXINT)            ; INT(XINTERCEPT)=XGRID
            MOVE.W  (RCTYINT),D0
            ASR.W   #8,D0
            MOVE.W  D0,(RCTYGRID)           ; YGRID=INT(YINTERCEPT)
            JSR     .HITVWALL               ; HIT WALL!
            DBRA.W  D7,.LOOPSCR             ; HIT: NEXT COLUMN
            BRA     .END                    ; FINISHED? END
.NOHIT      ADD.W   D1,(RCTXGRID)           ; XGRID+=GRIDSTEP.X
            ADD.W   D4,(RCTYINT)            ; YINTERCEPT+=YSTEP
            MOVE.W  (RCTYINT),D0
            ASR.W   #8-MAPWSHFT,D0
            AND.W   #~(MAPWIDTH-1),D0       ; INT(YINTERCEPT)*MAPW
            AND.W   #$0FFF,D0
            ADD.W   (RCTXGRID),D0
            MOVE.W  D0,(RCTXSPOT)           ; XSPOT=INT(YINTERCEPT)*MAPW+XGRID
            BRA     .LOOPVERT

            ; LOOP CONSIDERING HORIZONTAL TRANSITIONS IN MAP

.LOOPHOR    MOVE.W  (RCTXINT),D0
            ASR.W   #8,D0                   ; D0.W=INT(XINTERCEPT)
            CMP.W   #-1,D1                  ; IF GRIDSTEP.X==-1 AND
            BNE     .CHKV1                  ; INT(XINTERC)<=XGRID GO VERENTRY
            CMP.W   (RCTXGRID),D0
            BLE     .VERENTRY
.CHKV1      CMP.W   #1,D1                   ; IF GRIDSTEP.X==1 AND
            BNE     .HORENTRY               ; INT(XINTERC)>=XGRID GO VERENTRY
            CMP.W   (RCTXGRID),D0
            BGE     .VERENTRY
.HORENTRY   CLR.L   D0
            MOVE.W  (RCTYSPOT),D0
            MOVE.B  (A2,D0),D0              ; D0.B=MAPDATA[YSPOT]
            BEQ     .NOHHIT
            OR.B    #RCTMSKHC,D0            ; STATE HORIZONTAL COLLISION
            MOVE.B  D0,D3                   ; STORE ID
            MOVE.W  (RCTYGRID),D0
            ASL.W   #8,D0
            MOVE.W  D0,(RCTYINT)            ; INT(YINTERCEPT)=YGRID
            MOVE.W  (RCTXINT),D0
            ASR.W   #8,D0
            MOVE.W  D0,(RCTXGRID)           ; XGRID=INT(XINTERCEPT)
            JSR     .HITHWALL               ; HIT WALL
            DBRA.W  D7,.LOOPSCR
            BRA     .END
.NOHHIT     ADD.W   D2,(RCTYGRID)           ; YGRID+=GRIDSTEP.Y
            ADD.W   D3,(RCTXINT)            ; XINTERCEPT+=XSTEP
            MOVE.W  (RCTXINT),D0
            ASR.W   #8,D0
            AND.W   #$00FF,D0
            MOVE.W  D0,(RCTYSPOT)           ; PARTIAL YSPOT
            MOVE.W  (RCTYGRID),D0
            ASL.W   #MAPWSHFT,D0
            ADD.W   D0,(RCTYSPOT)           ; YSPOT=INT(XINTERCEPT)+YGRID*MAPWIDTH
            BRA     .LOOPHOR

            ; RAY HIT IN MAP

.HITHWALL   MOVE.B  (RCTXINT+1),D4          ; HIT POINT
            CMP.W   #-1,D2
            BNE     .CALCH
            ADD.W   #$0100,(RCTYINT)        ; INT(YINTERCEPT)++
            BRA     .CALCH
.HITVWALL   MOVE.B  (RCTYINT+1),D4          ; HIT POINT
            CMP.W   #-1,D1
            BNE     .CALCH
            ADD.W   #$0100,(RCTXINT)

            ; COMPUTE THE PERPENDICULAR DISTANCE AND THE HEIGHT

.CALCH      MOVE.W  (RCTXINT),D0
            SUB.W   (PLRPOSX),D0
            MULS    (RCTVCOS),D0            ; D0=(XINT-PLAYERX)*VIEWCOS
            MOVE.W  (RCTYINT),D1
            SUB.W   (PLRPOSY),D1
            MULS    (RCTVSIN),D1            ; D1=(YINT-PLAYERY)*VIEWSIN
            SUB.L   D1,D0                   ; D0=PERPENDICULAR DISTANCE
            ASR.L   #8,D0                   ; CORRECT FIXED POINT
            TST.W   D0
            BEQ     .ZERODIST               ; IF DISTANCE=0 AVOID DIV
            MOVE.L  #RCTPROJR<<8,D1         ; PREPARE FOR FIX POINT
            DIVU    D0,D1                   ; COMPUTE HEIGHT
            CMP.W   #SCRHEIGH,D1            ; IF LARGER THAN SCREEN...
            BLE     .STORE
.ZERODIST   MOVE.W  #SCRHEIGH,D1
.STORE      MOVE.W  D1,(A3)+                ; STORE HEIGHT
            MOVE.W  D0,(A4)+                ; STORE DISTANCE
            CLR.L   D5
            BCLR    #7,D3                   ; HOR OR VERT HIT?
            BEQ     .NOB7
            MOVE.L  #$FF000000,D5

.NOB7       AND.B   #3,D3                   ; CHECK VALID ID JUST IN CASE...
            BEQ     .STORCOL                ; ... RAYCASTER WENT OUT OF MAP.
.CONTNOB7   SUBQ.B  #1,D3
            AND.L   #$FF,D3                 ; GET ID
            ASL.L   #2,D3                   ; ACCESS TO LONG LIST

            IFNE    CASCLRTX                ; IF TEXTURE ENABLED
            LEA     TEXDATA,A6
            MOVE.L  (A6,D3),A6              ; GET TEXTURE POINTER
            AND.L   #$FF,D4                 ; GET TEXTURE COLUMN
            ASL.L   #2,D4                   ; PREPARE FOR LONG ACCESS
            MOVE.L  (A6,D4),D4              ; GET COLOR
            OR.L    D5,D4
.STORCOL    MOVE.L  D4,(A5)+                ; STORE COLOR
            RTS
            ENDC
            IFEQ CASCLRTX                   ; IF TEXTURE DISABLED
            LEA     .COLORS,A6              ; LIST OF COLORS
            MOVE.L  (A6,D3),D4
            OR.L    D5,D4                   ; PUT HOR/VERT INFO
.STORCOL    MOVE.L  D4,(A5)+                ; STORE COLOR
            RTS
.COLORS     DC.L    MAPOBSCO,MAPFUECO,MAPOXYCO
            ENDC
.END        MOVEM.L (A7)+,D0-D7/A0-A6       ; RESTORE REGISTERS
            RTS

; -----------------------------------------------------------------------------
RCTPLOT
; PLOTS THE RAYCASTER OUTPUT
; INPUT    - NONE BY REGISTER
;            THE OUTPUT VECTORS OF RCTUPD ARE USED
; OUTPUT   - NONE
; MODIFIES - NONE
; NOTE     - CELL AND FLOOR ARE FIXED BACKGROUDN RECTANGLES. VERTICAL LINES
;            CENTERED AND WITH THE HEIGHT COMPUTED BY UPDATE ARE PLOT AT EACH
;            SCREEN COLUMN. THE COLOR DEPENDS ON THE DISTANCE, THE ID AND THE
;            HIT SIDE.
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7/A0-A6,-(A7)

            ; PLOT CEIL

            MOVE.L  #RCTCEILC,D1
            MOVE.B  #80,D0
            TRAP    #15
            ADDQ.B  #1,D0
            TRAP    #15
            CLR.W   D1
            CLR.W   D2
            MOVE.W  #SCRWIDTH-1,D3
            MOVE.W  #SCRHEIGH/2,D4
            MOVE.B  #87,D0
            TRAP    #15

            ; PLOT STARS

            IFNE    CASSTARB
            MOVE.L  #RCTSTARC,D1
            MOVE.B  #80,D0
            TRAP    #15
            ADDQ.B  #1,D0
            TRAP    #15
            LEA     RCTSTAR,A0
            MOVE.B  #RCTSTARN-1,D5
            MOVE.W  (PLRANGLE),D6
            ASL.W   #2,D6
.LOOPS      MOVE.W  (A0)+,D1
            MOVE.W  (A0)+,D2
            MOVE.W  (A0)+,D4
            ADD.W   D6,D1
            AND.W   #RCTSTARM-1,D1
            CMP.W   #SCRWIDTH,D1
            BGE     .NEXTS
            MOVE.W  D1,D3
            ADD.W   D4,D3
            ADD.W   D2,D4
            MOVE.B  #88,D0
            TRAP    #15
.NEXTS      DBRA    D5,.LOOPS
            ENDC

            ; PLOT FLOOR

            MOVE.L  #RCTFLOOC,D1
            MOVE.B  #80,D0
            TRAP    #15
            ADDQ.B  #1,D0
            TRAP    #15
            CLR.W   D1
            MOVE.W  #SCRHEIGH/2,D2
            MOVE.W  #SCRWIDTH-1,D3
            MOVE.W  #SCRHEIGH-1,D4
            MOVE.B  #87,D0
            TRAP    #15

            ; PLOT VERTICAL STRIPES

            LEA     RCTHVEC,A0
            LEA     RCTDVEC,A1
            LEA     RCTCVEC,A2
            MOVE.W  #SCRHEIGH/2,D5
            MOVE.W  #SCRWIDTH-1,D1
.LOOP       JSR     .SETCOLOR
            MOVE.W  (A0)+,D2
            ASR.W   #1,D2
            MOVE.W  D2,D4
            NEG.W   D2
            ADD.W   D5,D2
            ADD.W   D5,D4
            MOVE.W  D1,D3
            MOVE.W  #84,D0
            TRAP    #15
            DBRA    D1,.LOOP
            MOVEM.L (A7)+,D0-D7/A0-A6
            RTS

            ; SET STRIPE COLOR DEPENDING ON DISTANCE, HIT SIDE AND CHANGE

.SETCOLOR   MOVE.L  D1,-(A7)
            MOVE.L  (A2)+,D1
            IFNE    CASCLRGR                ; ENABLE/DISABLE COLOR GRADATION
            JSR     .DISTCOL                ; DARKEN DEPENDING ON DISTANCE
            ENDC
            IFNE    CASCLRSD                ; ENABLE/DISABLE SIDE PROCESSING
            JSR     .HALFCOL                ; HALF DEPENDING ON SIDE/FRONT HIT
            ENDC
            IFEQ    CASCLRSD
            AND.L   #$00FFFFFF,D1
            ENDC
            MOVE.B  #80,D0                  ; SET COLOR
            TRAP    #15
            MOVE.L  (A7)+,D1
            RTS

; HALVES COLOR DEPENDING ON SIDE OR FRONT HIT. D1.L=COLOR

.HALFCOL    BTST    #31,D1
            BEQ     .END
            AND.L   #$00FFFFFF,D1           ; SET MSB TO ZERO JUST IN CASE
            LSR.B   #1,D1                   ; HALF R
            ROR.L   #8,D1                   ; PUT G IN PLACE
            LSR.B   #1,D1                   ; HALF G
            ROR.L   #8,D1                   ; PUT B IN PLACE
            LSR.B   #1,D1                   ; HALF B
            ROR.L   #8,D1                   ; ROTATE TO RESTORE...
            ROR.L   #8,D1                   ; ... THE COLOR FORMAT
.END        RTS

; DARKENS COLOR DEPENDING ON THE DISTANCE. D1.L=COLOR

.DISTCOL    MOVE.W  (A1)+,D0                ; DISTANCE
            ASR.W   #MAPWSHFT,D0            ; TRANSFORM TO 0-255 VALUE
            ASL.B   #1,D0                   ; TIMES TWO
            BCC     .DODARK                 ; IF <=255, LET'S GO!
            SCS     D0                      ; OTHERWISE SET TO 255
.DODARK     SUB.B   D0,D1                   ; DECREASE R
            BHS     .CONT0                  ; IF R<0 ...
            CLR.B   D1                      ; ... SET TO 0
.CONT0      ROR.L   #8,D1                   ; PUT G IN LSB
            SUB.B   D0,D1                   ; DECREASE G
            BHS     .CONT1                  ; IF G<0...
            CLR.B   D1                      ; ... SET TO 0
.CONT1      ROR.L   #8,D1                   ; PUT B IN LSB
            SUB.B   D0,D1                   ; DECREASE B
            BHS     .CONT2                  ; IF B<0...
            CLR.B   D1                      ; ... SET B TO 0
.CONT2      ROR.L   #8,D1                   ; ROTATE TO RESTORE...
            ROR.L   #8,D1                   ; ... THE COLOR FORMAT.
            RTS