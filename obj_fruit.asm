CreateFruit proto
DrawFruit   proto


.const
TIME_BLINK equ 10

.data?
fruit GAME_OBJECT <>
blink dd ?

.code
CreateFruit proc uses ebx esi edi
    local x:dword
    local y:dword

@@Do:    
    fn RangedRand,1,80
    mov dword ptr[x],eax
    fn RangedRand,1,35
    mov dword ptr[y],eax
    
    fn CheckCursorPosition,x,y
    cmp al,20h
    je @f
    jmp @@Do
    
@@:
    mov ebx,dword ptr[x]
    mov edx,dword ptr[y]
    fn CreateObject,offset fruit,ebx,edx,0,0,0,0,0,0,0,'0'
    mov blink,0
	ret
CreateFruit endp

DrawFruit proc uses ebx esi edi   
    inc blink
    .if blink >= TIME_BLINK
        
        .if byte ptr[fruit.sprite] == '0'
            mov byte ptr[fruit.sprite],'o'
        .else
            mov byte ptr[fruit.sprite],'0'   
        .endif
        
        mov blink,0
    .endif
    
    fn Gotoxy,fruit.obj.x,fruit.obj.y
    fn SetConsoleColor,0,LightRed
    movzx eax,fruit.sprite
    fn crt_putchar,eax
    
	ret
DrawFruit endp