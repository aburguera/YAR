; =============================================================================
; TITLE    : YAR - YET ANOTHER RAYCASTER
; AUTHOR   : ANTONI BURGUERA
; CREATION : 11-DEC-2018
; =============================================================================

            ORG     $1000

; --- CODE INCLUDES -----------------------------------------------------------

            INCLUDE "SYSCONST.X68"          ; SYSTEM CONSTANTS
            INCLUDE "SYSTEM.X68"            ; SYSTEM CODE
            INCLUDE "CONST.X68"             ; SYSTEM CONSTANTS
            INCLUDE "UTIL.X68"              ; UTILITY CODE
            INCLUDE "GFX.X68"               ; GRAPHICS MANAGEMENT
            INCLUDE "GENERAL.X68"           ; GENERAL GAME-RELATED CODE
            INCLUDE "AUDIO.X68"             ; AUDIO MANAGEMENT
            INCLUDE "RAYCAST.X68"           ; THE RAYCASTING ENGINE
            INCLUDE "PLAYER.X68"            ; PLAYER MANAGEMENT
            INCLUDE "MAP.X68"               ; MAP MANAGEMENT
            INCLUDE "ATTRACT.X68"           ; ATTRACT MODE MANAGEMENT
            INCLUDE "INTRO.X68"             ; INTRO STATE
            INCLUDE "GOVER.X68"             ; GAME OVER MANAGEMENT
            INCLUDE "VICTORY.X68"           ; VICTORY MANAGEMENT
            INCLUDE "STATES.X68"            ; GAME STATE MANAGEMENT

; --- DATA INCLUDES -----------------------------------------------------------

            INCLUDE "DATA/RCTDATA.X68"      ; PRECOMPUTED DATA
            INCLUDE "DATA/MAPDATA.X68"      ; MAP AND INITIAL PLAYER POSITION
            IFNE    CASCLRTX                ; ONLY IF TEXTURES ENABLED
            INCLUDE "DATA/TEXDATA.X68"      ; TEXTURES
            ENDC
            INCLUDE "DATA/STRDATA.X68"      ; STRING DATA
            INCLUDE "DATA/GFXDATA.X68"      ; LOGO GRAPHIC DATA
            IFEQ    ATRSAVE                 ; ONLY IF NOT SAVING
ATRDATA     INCBIN  'DATA/KEYSTROK.DAT'     ; RECORDED DATA (FOR ATTRACT MODE)
            DS.W    0
            ENDC

; --- INITIALIZE --------------------------------------------------------------

START       JSR     SYSINIT
            JSR     STAINIT

; --- UPDATE ------------------------------------------------------------------

.LOOP       TRAP    #KBDTRAP                ; READ KEYBOARD
            JSR     STAUPD

; --- WAIT SYNCH --------------------------------------------------------------

.WINT       TST.B   (SCRINTCT)              ; WAIT FOR INTERRUPT
            BEQ     .WINT
            CLR.B   (SCRINTCT)

; --- PLOT --------------------------------------------------------------------

            JSR     STAPLOT
            TRAP    #SCRTRAP                ; SHOW GRAPHICS
            BRA     .LOOP
            SIMHALT

; --- VARIABLES ---------------------------------------------------------------

            INCLUDE "SYSVAR.X68"
            INCLUDE "VAR.X68"
            END    START