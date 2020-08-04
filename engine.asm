GameInit               proto
GameController         proto
KeyEvent               proto
DrawEvent              proto
ShowScore              proto
DrawPanel              proto
StepEvent              proto
GameUpdate             proto
GameOver               proto 
TimeEvent              proto :dword,:dword,:dword,:dword,:dword

.const
KEY_ENTER           equ 13
KEY_ESC             equ 27
MENU_SELECT_WAV_RES equ 100
FOOD_TAKED_WAV_RES  equ 101
LOSE_WAV_RES        equ 102
PAUSE_WAV_RES       equ 103
MAX_STEP            equ 30
STOP                equ 30h

.data
bKey         db 30h
bPlay        db 0
gameOver     db 0
closeConsole db 0
nLevel       db 1
szLevel_1    db "Res\Level_1.txt",0
score        dd 0
score_old    dd 0
szGameOver   db "GAME OVER",0
szBack       db "Press ENTER to back menu",0

.code
GameInit proc uses ebx esi edi
    fn crt_srand,rv(crt_time,0) 
       
    .if nLevel == 1
        fn DrawLevel,offset szLevel_1,0,cYellow
    .endif
    
    or eax,eax
    je @@Error 
    fn DrawPanel
    fn SetConsoleColor,0,LightGreen
    fn Gotoxy,1,37
    fn crt_printf,"Score: "
    print ustr$(score)
    fn CreateSnake
    fn CreateFruit
    .if bPlay == 0
        fn mfmPlay,offset music
        inc bPlay
    .else
        fn mfmPause
    .endif
    
    fn timeSetEvent,MAX_STEP,0,offset TimeEvent,0,1
    mov dword ptr[id_timer],eax
    
@@Ret:    
    ret
    
@@Error:
    mov byte ptr[gameOver],0
    fn Gotoxy,32,19
    fn SetConsoleColor,0,cBrown
    fn crt_puts,"Load file failed"
    fn Sleep,2000
    jmp @@Ret
    
GameInit endp

GameController proc uses ebx edi esi
    fn KeyEvent
    fn DrawEvent
    fn StepEvent
    
	ret
GameController endp

KeyEvent proc uses ebx esi edi
    mov byte ptr[bKey],31h
    fn Keyboard_check
    mov byte ptr[bKey],al
    ;выход
    .if byte ptr[bKey] == KEY_ESC
        fn timeKillEvent,id_timer
        fn mfmPause
        mov byte ptr[gameOver],0
        mov dword ptr[score],0
    ;пауза    
    .elseif byte ptr[bKey] == 'p'
        fn timeKillEvent,id_timer
        fn PlayWavSoundFromRes,PAUSE_WAV_RES,0
        fn GamePause,37,18,0
        fn timeSetEvent,MAX_STEP,0,offset TimeEvent,0,1
        mov dword ptr[id_timer],eax
    ;движение    
    .elseif byte ptr[bKey] == 'w' || byte ptr[bKey] == 'a' || \
            byte ptr[bKey] == 's' || byte ptr[bKey] == 'd'
        mov byte ptr[snake.direction],al
        
    .endif
	ret
KeyEvent endp

DrawEvent proc uses ebx esi edi
    .if nTail > 0
        fn DrawTail      
    .endif
    fn DrawSnake
    fn DrawFruit
    fn ShowScore
    
	ret
DrawEvent endp

ShowScore proc uses ebx esi edi 
    mov ebx,score
    .if ebx > score_old        
        fn DrawScore,8,37,0,LightGreen,ebx            
        mov dword ptr[score_old],ebx
    .endif  
	ret
ShowScore endp

DrawPanel proc uses ebx esi edi  
    fn SetConsoleColor,3,0
    fn Gotoxy,21,37
    fn crt_printf,"Esc - back to menu, P - pause the game"
   
	ret
DrawPanel endp

StepEvent proc uses ebx esi edi
    .if nPickup == SPD_STEP
        mov nPickup,0
        dec snake.speed
        .if snake.speed <=0
            mov snake.speed,MAX_SPEED
        .endif
    .endif
    
    .if snake.direction == STOP    
      @@GameOver:        
        fn GameOver      
        jmp @@Ret   
    .endif
    
    ;ловим свой хвост
    .if nTail > 0
        lea esi,tail
        xor ebx,ebx
        jmp @@For2
        
      @@In2:  
        mov eax,dword ptr[esi]
        mov edx,dword ptr[esi+4]
        .if eax == snake.x && edx == snake.y
           jmp @@GameOver          
        .endif
        
        inc ebx
        add esi,sizeof TAIL
        
      @@For2:  
        cmp ebx,nTail
        jb @@In2      
    .endif
      
@@Ret:   
	ret
StepEvent endp

GameUpdate proc uses ebx esi edi
    local x:dword
    local y:dword
    local xprev:dword
    local yprev:dword
    local xtemp:dword
    local ytemp:dword
    
    inc spd_count
    mov eax,spd_count
    
    .if eax >= snake.speed
        mov eax,snake.x
        mov dword ptr[x],eax
        mov eax,snake.y
        mov dword ptr[y],eax
        .if nTail > 0
            lea esi,tail
            mov eax,dword ptr[esi]
            mov dword ptr[xprev],eax
            mov eax,dword ptr[esi+4]
            mov dword ptr[yprev],eax
            mov eax,dword ptr[x]
            mov dword ptr[esi],eax
            mov eax,dword ptr[y]
            mov dword ptr[esi+4],eax
            fn Gotoxy,xprev,yprev
            fn crt_putchar,20h
            
            xor ebx,ebx
            inc ebx
            add esi,sizeof TAIL
            jmp @@For
            
          @@In:
            mov eax,dword ptr[esi]
            mov dword ptr[xtemp],eax
            mov eax,dword ptr[esi+4]
            mov dword ptr[ytemp],eax
            fn Gotoxy,xtemp,ytemp
            fn crt_putchar,20h
            mov eax,dword ptr[xprev]
            mov dword ptr[esi],eax
            mov eax,dword ptr[yprev]
            mov dword ptr[esi+4],eax
            
            mov eax,dword ptr[xtemp]
            mov dword ptr[xprev],eax
            
            mov eax,dword ptr[ytemp]
            mov dword ptr[yprev],eax
            
            add esi,sizeof TAIL
            inc ebx
            
          @@For:
            cmp ebx,nTail
            jb @@In
        .endif
        
        fn Gotoxy,snake.x,snake.y
        fn crt_putchar,20h
        
        .if snake.direction == 'w'
            mov eax,dword ptr[y]
            dec eax
            fn CheckCursorPosition,x,eax
            ;пусто или фрукт
            .if al == 20h || al == fruit.sprite
            
                dec dword ptr[snake.y]
            
            ;столкновение со стеной      
            .elseif al == '#'
                mov byte ptr[snake.direction],STOP
                
            .endif
        
        .elseif snake.direction == 's'
            mov eax,dword ptr[y]
            inc eax
            fn CheckCursorPosition,x,eax
            ;пусто или фрукт
            .if al == 20h || al == fruit.sprite
            
                inc dword ptr[snake.y]
            
            ;столкновение со стеной      
            .elseif al == '#'
                mov byte ptr[snake.direction],STOP
                
            .endif
            
        .elseif snake.direction == 'a'
            mov eax,dword ptr[x]
            dec eax
            fn CheckCursorPosition,eax,y
            ;пусто или фрукт
            .if al == 20h || al == fruit.sprite
            
                dec dword ptr[snake.x]
             
             ;столкновение со стеной   
            .elseif al == '#'
                mov byte ptr[snake.direction],STOP
                
            .endif
            
        .elseif snake.direction == 'd'    
            mov eax,dword ptr[x]
            inc eax
            fn CheckCursorPosition,eax,y
            ;пусто или фрукт
            .if al == 20h || al == fruit.sprite
            
                inc dword ptr[snake.x]
            
            ;столкновение со стеной      
            .elseif al == '#'
                mov byte ptr[snake.direction],STOP
                
            .endif
        .endif
        
        mov spd_count,0
    .endif  
        
    ;ловим фрукт
    mov eax,snake.x
    mov ebx,snake.y
    .if eax == fruit.x && ebx == fruit.y
        .if nTail < MAX_TAIL
            ;увеличиваем хвост и счет
            inc nTail
            inc nPickup
            fn CreateFruit
            add score,10
            ;звук подбора еды
            fn PlayWavSoundFromRes,FOOD_TAKED_WAV_RES,0
        .endif      
    .endif
    
	ret
GameUpdate endp

GameOver proc uses ebx esi edi
    fn timeKillEvent,id_timer
    fn mfmPause
    fn crt_system,offset szCls
    fn PlayWavSoundFromRes,LOSE_WAV_RES,0
    fn SetConsoleColor,0,cBrown
    xor ebx,ebx
    inc ebx
    mov edi,41
    
@@Do:
   
    fn SetConsoleColor,0,cBrown    
    fn Gotoxy,35,ebx
    fn crt_puts,offset szGameOver
    dec ebx
    fn Gotoxy,35,ebx
    fn crt_puts,"         "
    inc ebx
   
    fn SetConsoleColor,0,cWhite
    fn Gotoxy,26,edi
    fn crt_printf,offset szBack
    inc edi
    fn Gotoxy,26,edi
    fn crt_printf,"                                "
    dec edi

    fn Sleep,400
    dec edi
    inc ebx
    cmp ebx,19
    jne @@Do
    
@@L0:    
    fn Keyboard_check_pressed
    cmp al,KEY_ENTER
    jne @@L0
    mov byte ptr[gameOver],0
    mov dword ptr [score],0   
    fn PlayWavSoundFromRes,MENU_SELECT_WAV_RES,0
    
	ret
GameOver endp

TimeEvent proc uses ebx esi edi idTimer:dword,uMsg:dword,dwUser:dword,Res1:dword,Res2:dword
    fn GameUpdate
    fn GameController     
    
	ret
TimeEvent endp