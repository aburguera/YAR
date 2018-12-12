; =============================================================================
; USER CONSTANTS
;
; AUTHOR  : ANTONI BURGUERA BURGUERA
; CONTACT : MY FAMILY NAME FOLLOWED BY THE AT SYMBOL THEN WRITE GMAIL AND END
;           WITH A DOT AND A COM.
; DATE    : 6-DEC-2018
; =============================================================================

; --- CONDITIONAL ASSEMBLY FLAGS ----------------------------------------------

CASCLRGR    EQU     1                       ; ENABLE COLOR GRADATION
CASCLRSD    EQU     1                       ; ENABLE SIDE BLOCK COLOR CHANGE
CASCLRTX    EQU     1                       ; ENABLE TEXTURES
CASSTARB    EQU     1                       ; ENABLE STAR BACKGROUND
CASMINIM    EQU     1                       ; ENABLE MINIMAP

; --- GENERAL PURPOSE CONSTANTS -----------------------------------------------

GENCHRW     EQU     8                       ; WIDTH IN PIXELS OF A TEXT CHAR
GENCHRH     EQU     15                      ; HEIGHT IN PIXELS OF A TEXT CHAR

; --- AUDIO RELATED CONSTANTS -------------------------------------------------

AUDMU1ID    EQU     0                       ; ID OF ATTRACT MODE MUSIC
AUDMU2ID    EQU     1                       ; ID OF GAME OVER MUSIC
AUDMU3ID    EQU     2                       ; ID OF VICTORY MUSIC
AUDPK1ID    EQU     3                       ; ID OF PICK ITEM 1 SOUND
AUDPK2ID    EQU     4                       ; ID OF PICK ITEM 2 SOUND
AUDARGID    EQU     5                       ; ID OF ARGH SOUND
AUDARNID    EQU     6                       ; ID OF "ARNOLD" SOUND
AUDENDID    EQU     $FF                     ; ID TO STOP ALL SOUNDS
AUDMSKLP    EQU     $80                     ; LOOP AUDIO MASK
AUDMSKNL    EQU     $00                     ; NO LOOP AUDIO MASK
AUDACCY     EQU     $FF                     ; ACCEPT PLAYING NEW SOUND
AUDACCN     EQU     $00                     ; DO NOT PLAY NEW SOUND

; --- MAP RELATED CONSTANTS ---------------------------------------------------

MAPWSHFT    EQU     6                       ; AMOUNT TO SHIFT Y DATA
MAPWIDTH    EQU     1<<MAPWSHFT             ; MAP WIDTH IN CELLS
MAPMINSH    EQU     3                       ; SHIFT TO GET CELL SIZE
MAPMINCS    EQU     1<<MAPMINSH             ; MINIMAP CELL SIZE
MAPMINNC    EQU     15                      ; NUMBEROF MINIMAP CELLS
MAPMINPX    EQU     SCRWIDTH-MAPMINCS*(MAPMINNC+3) ; MINIMAP POS X
MAPMINPY    EQU     MAPMINCS*3              ; MINIMAP POS Y
MAPWALID    EQU     1                       ; WALL ID
MAPFUEID    EQU     2                       ; FUEL ID
MAPOXYID    EQU     3                       ; OXYGEN ID
MAPOXYCO    EQU     $00FF0000               ; OXYGEN COLOR
MAPFUECO    EQU     $0000FF00               ; FUEL COLOR
MAPOBSCO    EQU     $000000FF               ; OBSTACLE COLOR

; --- PLAYER RELATED CONSTANTS ------------------------------------------------

PLRINIA     EQU     63                      ; INITIAL ANGLE (0-255)
PLRMAXOX    EQU     128                     ; MAX OXYGEN
PLRMAXFU    EQU     128                     ; MAXIMUM FUEL VALUE
PLROXYBN    EQU     40                      ; OXYGEN BONUS WHEN PICKING TANK
PLROXYX0    EQU     491                     ; OXYGEN BAR INIT X
PLROXYX1    EQU     621                     ; OXYGEN BAR FINAL X
PLROXYY0    EQU     11                      ; OXYGEN BAR INIT Y
PLROXYY1    EQU     25                      ; OXYGEN BAR FINAL Y
PLRFUEX0    EQU     491                     ; FUEL BAR INIT X
PLRFUEX1    EQU     621                     ; FUEL BAR FINAL X
            IFNE    CASMINIM                ; FUEL BAR POSITION IF MINIMAP
PLRFUEY0    EQU     143                     ; FUEL BAR INIT Y
PLRFUEY1    EQU     157                     ; FUEL BAR FINAL Y
            ENDC
            IFEQ    CASMINIM                ; FUEL BAR POSITION IF NO MINIMAP
PLRFUEY0    EQU     PLRFUEY0+16             ; FUEL BAR INIT Y
PLRFUEY1    EQU     PLRTREY0+14             ; FUEL BAR FINAL Y
            ENDC
PLRARGTI    EQU     50                      ; MAX VALUE FOR ARGH TIMER

; --- RAYCASTER RELATED CONSTANTS ---------------------------------------------

; RAYCASTING

RCTCELLS    EQU     256                     ; CELL SIZE
RCTA2FSH    EQU     3                       ; SHIFT BETWEEN ANGLE AND FINE
RCTANGLE    EQU     256                     ; NUMBER OF ANGLES
RCTFINAN    EQU     RCTANGLE<<RCTA2FSH      ; NUMBER OF ANGLES IN FINE RESO

; CAMERA PROJECTION

RCTMINDS    EQU     $0058                   ; EYE TO FOCUS DISTANCE
RCTFOCAL    EQU     $0057                   ; FOCAL LENGTH
RCTFDIST    EQU     RCTFOCAL+RCTMINDS       ; FACE DISTANCE
RCTPROJR    EQU     ((SCRWIDTH/2)*RCTFDIST)/(RCTCELLS/2) ; PROJECTION RATIO

; OUTPUT GENERATION

RCTMSKVC    EQU     $80                     ; MASK TO STATE VERT COLLISION
RCTMSKHC    EQU     $00                     ; MASK TO STATE HOR COLLISION
RCTBITCL    EQU     7                       ; VER/HOR COLLISION BIT

; PLOT COLORS AND COLOR SCALING AND RELATED

RCTMINDV    EQU     $02FF                   ; MINIMUM DISTANCE TO OBSTACLE
RCTMAXDV    EQU     (MAPWIDTH-1)<<8         ; MAXIMUM DISTANCE TO OBSTACLE
RCTMINCL    EQU     $08                     ; MINIMUM COLOR LEVEL
RCTMAXCL    EQU     $7F                     ; MAXIMUM COLOR LEVEL
RCTCEILC    EQU     $00000000               ; CEIL COLOR
RCTFLOOC    EQU     $00072026               ; FLOOR COLOR
RCTSTARC    EQU     $0000FFFF               ; STARS COLOR
RCTSTARN    EQU     50                      ; NUMBER OF STARS
RCTSTARM    EQU     1024                    ; STARS MAX X COORDINATE

; --- ATTRACT MODE RELATED CONSTANTS ------------------------------------------

ATRSAVE     EQU     0                       ; RECORD GAME? SEE ATTRACT.X68

; --- GAME STATES -------------------------------------------------------------

STANONE     EQU     -1                      ; PLACEHOLDER TO FORCE CHANGE
STAINTR     EQU     0                       ; INTRO/PRESS FIRE STATE
STAPLAY     EQU     1                       ; NORMAL GAME STATE
STAGOVR     EQU     2                       ; GAME OVER STATE
STAATTR     EQU     3                       ; ATTRACT MODE STATE
STAVICT     EQU     4                       ; VICTORY STATE