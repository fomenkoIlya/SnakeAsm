GameInit               proto
GameController         proto
KeyEvent               proto
DrawEvent              proto
ShowScore              proto
DrawPanel              proto
StepEvent              proto
BeginStepEvent         proto
GameOver               proto 
TimeEvent              proto :dword,:dword,:dword,:dword,:dword
LoadGameEvent          proto
StartGameEvent         proto

.const
MENU_SELECT_WAV_RES equ 100
FOOD_TAKED_WAV_RES  equ 101
LOSE_WAV_RES        equ 102
PAUSE_WAV_RES       equ 103
MAX_STEP            equ 30
STOP                equ 30h

.data
bKey         db 31h
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
StartGameEvent proc uses ebx esi edi
    fn crt_srand,rv(crt_time,0) 
       
    .if nLevel == 1
        ;fn DrawLevel,offset szLevel_1,0,cYellow
        fn printResTxt,LVL_1_TXT_RES,0,cYellow
    .endif
    
    or eax,eax
    je @@Error 
    fn DrawPanel
    fn SetConsoleColor,0,LightGreen
    fn Gotoxy,1,37
    fn crt_printf,offset szScore
    print ustr$(score)
    fn CreateSnake
    fn CreateFruit
    .if bPlay == 0
        fn PlayXmSound,XM_MUSIC_RES
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
    
StartGameEvent endp

GameController proc uses ebx edi esi
    fn BeginStepEvent
    fn KeyEvent
    fn DrawEvent
    fn StepEvent   

	ret
GameController endp

KeyEvent proc uses ebx esi edi   
    fn Keyboard_check
    mov byte ptr[bKey],al
    
    ;выход
    .if bKey == _ESC
        fn timeKillEvent,id_timer
        fn mfmPause
        mov byte ptr[gameOver],0
        mov dword ptr[score],0
    ;пауза    
    .elseif bKey == b_p
        fn timeKillEvent,id_timer
        fn PlayWavSoundFromRes,PAUSE_WAV_RES,0
        fn GamePause,37,18,0,b_p
        fn timeSetEvent,MAX_STEP,0,offset TimeEvent,0,1
        mov dword ptr[id_timer],eax
    ;движение    
    .elseif bKey == b_w || bKey == b_a || \
            bKey == b_s || bKey == b_d
            mov dword ptr[snake.direction],eax
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
        .if snake.speed <= 0
            mov snake.speed,MAX_SPEED
        .endif
    .endif
    ;врезались в стену
    .if snake.direction == STOP    
      @@GameOver:        
        fn GameOver      
        jmp @@Ret   
    .endif  
    ;врезались в свой хвост
    .if nTail > 0
        lea esi,tail
        xor ebx,ebx
        jmp @@For2
        
      @@In2:  
        mov eax,dword ptr[esi]
        mov edx,dword ptr[esi+4]
        .if eax == snake.obj.x && edx == snake.obj.y
           jmp @@GameOver          
        .endif
        
        inc ebx
        add esi,sizeof OBJECT
        
      @@For2:  
        cmp ebx,nTail
        jb @@In2      
    .endif
      
@@Ret:   
	ret
StepEvent endp

BeginStepEvent proc uses ebx esi edi
    local x:dword
    local y:dword
    local lpObj:dword
    
    inc spd_count
    mov eax,spd_count
    
    .if eax >= snake.speed
        mov eax,snake.obj.x
        mov dword ptr[x],eax
        mov eax,snake.obj.y
        mov dword ptr[y],eax
        .if nTail > 0
            lea esi,tail
            mov eax,dword ptr[esi]
            mov dword ptr[esi+8],eax  ;xstart
            mov eax,dword ptr[esi+4]
            mov dword ptr[esi+12],eax ;ystart
            mov eax,dword ptr[x]
            mov dword ptr[esi],eax
            mov eax,dword ptr[y]
            mov dword ptr[esi+4],eax
            mov eax,dword ptr[esi+8]
            mov edx,dword ptr[esi+12] 
            fn Gotoxy,eax,edx
            putchar 20h
            mov dword ptr[lpObj],esi
            xor ebx,ebx
            inc ebx
            add esi,sizeof OBJECT
            jmp @@For
            
          @@In:
            mov edi,dword ptr[lpObj]
            mov eax,dword ptr[esi]
            mov dword ptr[esi+8],eax
            mov edx,dword ptr[esi+4]
            mov dword ptr[esi+12],edx
            fn Gotoxy,eax,edx
            putchar 20h
            mov eax,dword ptr[edi+8]
            mov dword ptr[esi],eax
            mov eax,dword ptr[edi+12]
            mov dword ptr[esi+4],eax
            mov dword ptr[lpObj],esi                    
            add esi,sizeof OBJECT
            inc ebx
            
          @@For:
            cmp ebx,nTail
            jb @@In
        .endif
        
        fn Gotoxy,snake.obj.x,snake.obj.y
        putchar 20h
        
        .if dword ptr[snake.direction] == b_w
              
            mov eax,dword ptr[y]
            dec eax
            fn CheckCursorPosition,x,eax            
            
            ;пусто или фрукт
            .if al == 20h || al == fruit.sprite
            
                dec dword ptr[snake.obj.y]
            
            ;столкновение со стеной      
            .elseif al == '#'
                mov byte ptr[snake.direction],STOP                                            
            .endif
        
        .elseif snake.direction == b_s
            mov eax,dword ptr[y]
            inc eax
            fn CheckCursorPosition,x,eax
            ;пусто или фрукт
            .if al == 20h || al == fruit.sprite
            
                inc dword ptr[snake.obj.y]
            
            ;столкновение со стеной      
            .elseif al == '#'
                mov dword ptr[snake.direction],STOP
                
            .endif
            
        .elseif snake.direction == b_a
            mov eax,dword ptr[x]
            dec eax
            fn CheckCursorPosition,eax,y
            ;пусто или фрукт
            .if al == 20h || al == fruit.sprite
            
                dec dword ptr[snake.obj.x]
             
             ;столкновение со стеной   
            .elseif al == '#'
                mov dword ptr[snake.direction],STOP
                
            .endif
            
        .elseif snake.direction == b_d    
            mov eax,dword ptr[x]
            inc eax
            fn CheckCursorPosition,eax,y
            ;пусто или фрукт
            .if al == 20h || al == fruit.sprite
            
                inc dword ptr[snake.obj.x]
            
            ;столкновение со стеной      
            .elseif al == '#'
                mov dword ptr[snake.direction],STOP
                
            .endif
        .endif
        
        mov spd_count,0
    .endif  
        
    ;ловим фрукт
    mov eax,snake.obj.x
    mov ebx,snake.obj.y
    .if eax == fruit.obj.x && ebx == fruit.obj.y
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
BeginStepEvent endp

GameOver proc uses ebx esi edi
    fn timeKillEvent,id_timer
    fn mfmPause
    fn crt_system,offset szCls
    fn PlayWavSoundFromRes,LOSE_WAV_RES,0
    fn SetConsoleColor,0,cBrown
    xor ebx,ebx
    inc ebx
    mov edi,41
    
    ;центральна€ надпись
    fn SetConsoleColor,0,LightGreen
    fn Gotoxy,35,21
    fn crt_puts,offset szScore
    fn Gotoxy,42,21
    print ustr$(score)
    
@@Do:
    ;верхн€€ надпись 
    fn SetConsoleColor,0,cBrown    
    fn Gotoxy,35,ebx
    fn crt_puts,offset szGameOver
    dec ebx
    fn Gotoxy,35,ebx
    fn crt_puts,"         "
    inc ebx
    ;нижн€€ надпись
    fn SetConsoleColor,0,cWhite
    fn Gotoxy,28,edi
    fn crt_printf,offset szBack
    inc edi
    fn Gotoxy,28,edi
    fn crt_printf,"                        "
    dec edi

    fn Sleep,400
    dec edi
    inc ebx
    cmp ebx,19
    jne @@Do
    
@@L0:    
    fn Keyboard_check_pressed
    cmp al,_ENTER
    jne @@L0
    mov byte ptr[gameOver],0
    mov dword ptr[score],0   
    fn PlayWavSoundFromRes,MENU_SELECT_WAV_RES,0
    
	ret
GameOver endp

TimeEvent proc uses ebx esi edi idTimer:dword,uMsg:dword,dwUser:dword,Res1:dword,Res2:dword
    fn GameController
    
	ret
TimeEvent endp

LoadGameEvent proc uses ebx esi edi
    
	ret
LoadGameEvent endp
