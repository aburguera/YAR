; =============================================================================
; GAME VARS
;
; AUTHOR  : ANTONI BURGUERA BURGUERA
; CONTACT : MY FAMILY NAME FOLLOWED BY THE AT SYMBOL THEN WRITE GMAIL AND END
;           WITH A DOT AND A COM.
; DATE    : 6-DEC-2018
; =============================================================================

; --- GAME STATE RELATED VARIABLES --------------------------------------------

STACUR      DS.W    1                       ; CURRENT GAME STATE
STANEXT     DS.W    1                       ; NEXT GAME STATE

; --- GENERAL PURPOSE VARIABLES -----------------------------------------------

GENFRMCT    DS.B    1                       ; FRAME COUNTER

; --- AUDIO RELATED VARIABLES ------------------------------------------------

AUDACCSN    DS.B    1                       ; ACCEPT NEW SOUNDS?
            DS.W    0

; --- MAP RELATED VARIABLES --------------------------------------------------

MAPDATA     DS.B    MAPWIDTH*MAPWIDTH       ; MODIFIABLE COPY OF MAPDATAO

; --- PLAYER RELATED VARIABLES ------------------------------------------------

PLRPOSX     DS.W    1                       ; PLAYER X FIXPNT 8.8
PLRPOSY     DS.W    1                       ; PLAYER Y FIXPNT 8.8
PLRANGLE    DS.W    1                       ; PLAYER O INT 0-255
PLRDELTX    DS.W    1                       ; DELTA X FOR THE CURRENT ORIENT.
PLRDELTY    DS.W    1                       ; DELTA Y FOR THE CURRENT ORIENT.
PLROXYG     DS.W    1                       ; AVAILABLE OXYGEN
PLRPICKF    DS.W    1                       ; PICKED FUEL TANKS
PLRARGTM    DS.B    1                       ; ARGH TIMER
            DS.W    0

; --- RAYCASTER RELATED VARIABLES --------------------------------------------

; RAYCASTER OUTPUT

RCTHVEC     DS.W    SCRWIDTH                ; HEIGHT VECTOR
RCTDVEC     DS.W    SCRWIDTH                ; DISTANCE VECTOR
RCTCVEC     DS.L    SCRWIDTH                ; ID VECTOR

; LOCAL RCTUPD VARIABLES DECLARED HERE INSTEAD OF STACK FOR SPEED

RCTXPL      DS.W    1                       ; X PARTIAL LEFT
RCTXPR      DS.W    1                       ; X PARTIAL RIGHT
RCTYPU      DS.W    1                       ; Y PARTIAL UP
RCTYPD      DS.W    1                       ; Y PARTIAL DOWN
RCTMIDA     DS.W    1                       ; MID ANGLE
RCTYINT     DS.W    1                       ; Y INTERCEPT FIXED POINT
RCTXGRID    DS.W    1                       ; X GRID INT
RCTXSPOT    DS.W    1                       ; X SPOT
RCTXINT     DS.W    1                       ; X INTERCEPT FIXED POINT
RCTYGRID    DS.W    1                       ; Y GRID INT
RCTYSPOT    DS.W    1                       ; Y SPOT
RCTVSIN     DS.W    1                       ; VIEW SIN
RCTVCOS     DS.W    1                       ; VIEW COS

; --- ATTRACT MODE RELATED VARIABLES -----------------------------------------

ATRPTR      DS.L    1                       ; POINTER TO CURRENT KEYSTROKE
ATRCTR      DS.W    1                       ; ATTRACT MODE COUNTER
ATRTUTP     DS.L    1                       ; POINTER TO TUTORIAL TEXT

; --- GAME OVER RELATED VARIABLES --------------------------------------------

GOVCUROF    DS.W    1                       ; CURTAIN OFFSET FOR GAME OVER