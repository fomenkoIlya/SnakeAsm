comment~ =================================================
            Console engine library by ILLIA FOMENKO
         =================================================~   

.686P                                     ; create 32 bit code
.mmx
.xmm
.model flat, stdcall                      ; 32 bit memory model
option casemap :none                      ; case sensitive 

;     include files
;     ~~~~~~~~~~~~~
include \masm32\include\windows.inc       ; main windows include file
include \masm32\include\masm32.inc        ; masm32 library include

; -------------------------
; Windows API include files
; -------------------------
include \masm32\include\gdi32.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\Comctl32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\shell32.inc
include \masm32\include\oleaut32.inc
include \masm32\include\ole32.inc
include \masm32\include\msvcrt.inc

include \masm32\macros\macros.asm         ; masm32 macro file

include \masm32\include\fpu.inc
include \masm32\include\Winmm.inc
include \masm32\minifmod\mfmplayer.inc

;     libraries
;     ~~~~~~~~~
includelib \masm32\lib\masm32.lib         ; masm32 static library

; ------------------------------------------
; import libraries for Windows API functions
; ------------------------------------------
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\Comctl32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\oleaut32.lib
includelib \masm32\lib\ole32.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\fpu.lib
includelib \masm32\lib\Winmm.lib
includelib \masm32\minifmod\mfmplayer.lib
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
SetConsoleWindowSize   proto :dword,:dword
HideConsoleCursor      proto   
Gotoxy                 proto :dword,:dword
SetConsoleColor        proto :dword,:dword
CheckCursorPosition    proto :dword,:dword
GamePause              proto :dword,:dword,:dword
Keyboard_check_pressed proto
Keyboard_check         proto
PlayWavSound           proto :dword,:dword
PlayWavSoundFromRes    proto :dword,:dword
DrawLevel              proto :dword,:dword,:dword
DrawScore              proto :dword,:dword,:dword,:dword,:dword
RangedRand             proto :dword,:dword

;Game object constructor
CreateObject proto :dword,:dword,:dword,:dword,:dword,\
                   :dword,:dword,:dword,:dword,:dword,:dword

cBlack           = 0
cBlue            = 1
cGreen           = 2
cCyan            = 3
cRed             = 4
cMagenta         = 5
cBrown           = 6
LightGray        = 7
DarkGray         = 8
LightBlue        = 9
LightGreen       = 10
LightCyan        = 11
LightRed         = 12
LightMagenta     = 13
cYellow          = 14
cWhite           = 15

GAME_OBJECT struct
    x         dword ?
    y         dword ?
    xstart    dword ?
    ystart    dword ?
    speed     dword ?
    vspeed    dword ?
    hspeed    dword ?
    gravity   dword ?
    direction db ?
    lives     db ?
    health    db ?
    sprite    db ?   
GAME_OBJECT ends

.data
rand_max dq 32768.0
