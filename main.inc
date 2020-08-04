include    conengine\conengine.inc
includelib conengine\conengine.lib

include xm.asm

Main            proto

.const
    MAX_WIDTH   equ 82
    MAX_HEIGHT  equ 42
    XM_MUSIC_RES equ 400
    
.data?
id_timer dd ?

.data
srect   SMALL_RECT <0,0,81,41>
szMenuSelectSound db "Res\SelectMenu.wav",0
szCls             db "cls",0
szScore           db "Score: ",0