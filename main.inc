include    conengine\conengine.inc
includelib conengine\conengine.lib

Main            proto

.const
IDD_DLG1001   equ 1001
MAX_WIDTH     equ 82
MAX_HEIGHT    equ 42
XM_MUSIC_RES  equ 400
ABOUT_TXT_RES equ 300
LVL_1_TXT_RES equ 301
START_SCREEN_TXT_RES equ 302

;key code
_ESC   equ 27
_ENTER equ 13
b_p    equ 112
b_P    equ 80
b_w    equ 119
b_W    equ 87
b_s    equ 115
b_S    equ 83
b_d    equ 100
b_D    equ 68
b_a    equ 97
b_A    equ 65

.data?
id_timer  dd ?
hInstance dd ?

.data
srect   SMALL_RECT <0,0,81,41>

szCls             db "cls",0
szScore           db "Score: ",0
