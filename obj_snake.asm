DrawSnake proto
ClearTail proto
DrawTail  proto
CreateSnake proto


TAIL struct
    x dword ?
    y dword ?  
TAIL ends

.const
MAX_SPEED       equ 10
MAX_TAIL        equ 500
SPD_STEP        equ 2
SNAKE_HEAD_CHAR equ 'O'
SNAKE_TAIL_CHAR equ 'o'

.data?
snake GAME_OBJECT <>
spd_count   dd ?
tail        TAIL MAX_TAIL dup(<>)
nTail       dd ?
nPickup     dd ?

.data


.code
DrawSnake proc uses ebx esi edi   
    fn Gotoxy,snake.x,snake.y
    fn SetConsoleColor,0,LightCyan  
    movzx eax,byte ptr[snake.sprite]
    fn crt_putchar,eax
      
	ret
DrawSnake endp

ClearTail proc uses ebx esi edi
    lea esi,tail
    xor ebx,ebx
    jmp @@For
    
  @@In:
    mov dword ptr[esi],0
    mov dword ptr[esi+4],0
    add esi,sizeof TAIL
    inc ebx
    
  @@For:
      cmp ebx,nTail
      jb @@In
	ret
ClearTail endp

DrawTail proc uses ebx esi edi
    fn SetConsoleColor,0,LightCyan
    lea esi,tail
    xor ebx,ebx
    jmp @@For
    
@@In:
    mov eax,dword ptr[esi]
    mov edx,dword ptr[esi+4]
    .if eax == 0 || edx == 0
        jmp @@Ret
        
    .endif
    fn Gotoxy,eax,edx
    fn crt_putchar,SNAKE_TAIL_CHAR
    
    inc ebx
    add esi,sizeof TAIL
    
@@For:
    cmp ebx,nTail
    jb @@In 

@@Ret:    
	ret
DrawTail endp

CreateSnake proc uses ebx esi edi  
    fn CreateObject,offset snake,40,20,MAX_SPEED,0,0,0,31h,0,0,SNAKE_HEAD_CHAR   
    mov dword ptr[score],0
    mov dword ptr[score_old],0
    fn ClearTail
    mov dword ptr[nTail],0
    mov dword ptr[nPickup],0
	ret
CreateSnake endp