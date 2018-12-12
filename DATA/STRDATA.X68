; =============================================================================
; TEXT DATA
; =============================================================================

; -----------------------------------------------------------------------------
; TITLE STRINGS
; -----------------------------------------------------------------------------

STRTIT0     DC.B    'YET ANOTHER RAYCASTER',0
STRTIT1     DC.B    'PRESS FIRE1 TO START',0
STRTIT2     DC.B    'WAIT TO SEE TUTORIAL',0
            DS.W    0

; -----------------------------------------------------------------------------
; GAME OVER TEXT BLOCK AND STRINGS.
; A TEXT BLOCK IS A LIST OF POINTERS TO STRINGS.
; -----------------------------------------------------------------------------

STRBLKGV    DC.L    .STR0,.STR1,0
.STR0       DC.B    'YOU RAN OUT OF OXYGEN!',0
.STR1       DC.B    'PUSH FIRE1 TO TRY AGAIN',0
            DS.W    0

; -----------------------------------------------------------------------------
; VICTORY TEXT BLOCK
; -----------------------------------------------------------------------------

STRBLKVI    DC.L    .STR0,.STR1,.STR2,.STR3,.STR4,.STR5,.STR6,.STR7,.STR8
            DC.L    .STR9,0
.STR0       DC.B    'YOU HAVE FOUND ALL THE FUEL TANKS!',0
.STR1       DC.B    'NOW YOU ARE READY TO LEAVE THIS PLANET!',0
.STR2       DC.B    'LET ME SEE... EARTH IS 10 LIGHT YEARS AWAY.',0
.STR3       DC.B    'NO CRYOSTASIS. NO HYPERSPACE. NO WARP DRIVE',0
.STR4       DC.B    'BECAUSE... THEY DO NOT EXIST!',0
.STR5       DC.B    'AT MAX SPEED THIS MAY TAKE ONLY A FEW TENS OF...',0
.STR6       DC.B    'MILLENIA. GREAT. OH, WAIT! HOW THE HELL DID',0
.STR7       DC.B    'I ARRIVE HERE IN THE FIRST PLACE? THIS MAKES',0
.STR8       DC.B    'NO SENSE. IT SEEMS THE ABSURD STORY OF AN',0
.STR9       DC.B    'ABSURD VIDEOGAME.',0
            DS.W    0

; -----------------------------------------------------------------------------
; TUTORIAL BOOK, BLOCKS AND STRINGS.
; A BOOK IS A LIST OF TEXT BLOCKS. THE FIRST PAGE IS DUPLICATED SINCE THE
; RECORDED KBDEDGE IS USED TO ADVANCE, SO ADVANCING COMES BEFORE SHOWING.
; -----------------------------------------------------------------------------

STRPAGAT    DC.L    .STD0,.STD0,.STD1,.STD2,.STD3,.STD4,.STD5,.STD6,.STD7
            DC.L    .STD8,.STD9,.STDA,.STDB,0
.STD0       DC.L    .STR00,.STR01,0
.STD1       DC.L    .STR10,.STR11,0
.STD2       DC.L    .STR20,.STR21,.STR22,.STR23,0
.STD3       DC.L    .STR30,.STR31,.STR32,.STR33,0
.STD4       DC.L    .STR40,.STR41,.STR42,0
.STD5       DC.L    .STR50,.STR51,.STR52,0
.STD6       DC.L    .STR60,.STR61,.STR62,0
.STD7       DC.L    .STR70,.STR71,.STR72,.STR73,.STR74,.STR75,.STR76,0
.STD8       DC.L    .STR80,.STR81,.STR82,0
.STD9       DC.L    .STR90,.STR91,.STR92,0
.STDA       DC.L    .STRA0,.STRA1,.STRA2,.STRA3,0
.STDB       DC.L    .STRB0,.STRB1,0
.STR00      DC.B    'USE LEFT AND RIGHT',0
.STR01      DC.B    'TO CHANGE ORIENTATION',0
            DS.W    0
.STR10      DC.B    'USE UP AND DOWN',0
.STR11      DC.B    'TO MOVE FORWARD AND BACKWARD',0
            DS.W    0
.STR20      DC.B    'THE MINIMAP ON THE TOP-RIGHT',0
.STR21      DC.B    'SHOWS YOUR POSITION.',0
.STR22      DC.B    'THE GREEN TRIANGLE REPRESENTS',0
.STR23      DC.B    'YOUR FIELD OF VIEW.',0
            DS.W    0
.STR30      DC.B    'YOUR GOAL IS TO PICK ALL',0
.STR31      DC.B    'THE GREEN FUEL CAPSULES',0
.STR32      DC.B    'TO FILL YOUR SPACESHIP TANKS',0
.STR33      DC.B    'AND GO BACK TO EARTH.',0
            DS.W    0
.STR40      DC.B    'THE GREEN BAR BELOW THE MINIMAP',0
.STR41      DC.B    'SHOWS THE SPACESHIP FUEL TANK LEVEL.',0
.STR42      DC.B    'IT INCREASES WITH EVERY GATHERED CAPSULE',0
            DS.W    0
.STR50      DC.B    'OOPS! THE SPACE SUIT OXYGEN',0
.STR51      DC.B    'DECREASES WHEN WALKING.',0
.STR52      DC.B    'WATCH THE BLUE BAR OVER THE MINIMAP.',0
            DS.W    0
.STR60      DC.B    'THOSE BLUE CAPSULES ARE',0
.STR61      DC.B    'OXYGEN TANKS. PICK THEM TO',0
.STR62      DC.B    'GATHER SOME EXTRA TIME.',0
            DS.W    0
.STR70      DC.B    'SEE? A LITTLE MORE OXYGEN.',0
.STR71      DC.B    'THAT IS GOOD. OXYGEN IS IMPORTANT.',0
.STR72      DC.B    'NO. MORE THAN IMPORTANT. CRUCIAL.',0
.STR73      DC.B    'DO NOT WASTE YOUR OXYGEN.',0
.STR74      DC.B    'DO NOT PICK OXYGEN CAPSULES IF YOU',0
.STR75      DC.B    'DO NOT NEED THEM, THEY MAY BE USEFUL',0
.STR76      DC.B    'LATER.',0
            DS.W    0
.STR80      DC.B    'HMMM... THIS ALIEN BUILDING... IT',0
.STR81      DC.B    'BRINGS ME MEMORIES OF AN OLD MISSION',0
.STR82      DC.B    'I DID IN THE CASTLE OF WOLFENSTEIN...',0
            DS.W    0
.STR90      DC.B    'PRESS FIRE1 WHILE MOVING TO RUN BUT...',0
.STR91      DC.B    'BE CAREFUL! OXYGEN GOES DOWN MUCH',0
.STR92      DC.B    'FASTER WHEN RUNNING!',0
            DS.W    0
.STRA0      DC.B    'NOW IS UP TO YOU TO FIND ALL',0
.STRA1      DC.B    'ALL THE GREEN FUEL CAPSULES BEFORE',0
.STRA2      DC.B    'YOUR OXYGEN IS DEPLETED.',0
.STRA3      DC.B    'GOOD LUCK!',0
            DS.W    0
.STRB0      DC.B    'ENJOY THE GAME!',0
.STRB1      DC.B    'ENJOY THE POWER OF ASSEMBLY LANGUAGE!',0
            DS.W    0