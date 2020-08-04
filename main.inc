include    conengine\conengine.inc
includelib conengine\conengine.lib

include xm.asm

Main            proto

.const
    MAX_WIDTH   equ 82
    MAX_HEIGHT  equ 42
    
.data?
id_timer dd ?

.data
srect   SMALL_RECT <0,0,81,41>
szMenuSelectSound db "Res\SelectMenu.wav",0
szLevelMusic      db "Res\pulsium_powerium.xm",0
szCls             db "cls",0
