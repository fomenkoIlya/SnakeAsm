MainMenu  proto
AboutMenu proto

ABOUT_TXT_RES equ 200
LVL_1_TXT_RES equ 201

.data
szAbout db "Res\about.txt",0

.code
MainMenu proc uses ebx esi edi
    local hOut  :dword
    local choice:dword
    local cStart:dword
    local cExit :dword
    local cAbout:dword
   
    fn crt_system,offset szCls
    mov hOut,rv(GetStdHandle,-11)
    mov dword ptr[choice],1
    mov cStart,cWhite 
    mov cExit,cBrown
    mov cAbout,cBrown
    mov byte ptr[bKey],31h
    mov byte ptr[closeConsole],0
    
    .while closeConsole == 0 && gameOver == 0
        .while byte ptr[bKey] != KEY_ENTER
            mov byte ptr[bKey],31h
            fn SetConsoleTextAttribute,hOut,cStart
            fn Gotoxy,37,18
            fn crt_printf,"START"
            
            fn SetConsoleTextAttribute,hOut,cAbout
            fn Gotoxy,37,20
            fn crt_printf,"ABOUT"
            
            fn SetConsoleTextAttribute,hOut,cExit
            fn Gotoxy,37,22
            fn crt_printf,"EXIT"
            
            fn Keyboard_check_pressed
            mov byte ptr[bKey],al
            ;about to start
            .if al == 'w' && choice == 2
                dec dword ptr[choice] 
                mov dword ptr[cExit],cBrown
                mov dword ptr[cStart],cWhite
                mov dword ptr[cAbout],cBrown
                fn PlayWavSoundFromRes,MENU_SELECT_WAV_RES,0
            ;exit to about
            .elseif al == 'w' && choice == 3
                dec dword ptr[choice] 
                mov dword ptr[cExit],cBrown
                mov dword ptr[cStart],cBrown
                mov dword ptr[cAbout],cWhite
                fn PlayWavSoundFromRes,MENU_SELECT_WAV_RES,0
            ;ebout to exit    
            .elseif al == 's' && choice == 2
                inc dword ptr[choice] 
                mov dword ptr[cExit],cWhite
                mov dword ptr[cStart],cBrown
                mov dword ptr[cAbout],cBrown
                fn PlayWavSoundFromRes,MENU_SELECT_WAV_RES,0
            ;start to about
            .elseif al == 's' && choice == 1
                inc dword ptr[choice] 
                mov dword ptr[cExit],cBrown
                mov dword ptr[cStart],cBrown
                mov dword ptr[cAbout],cWhite
                fn PlayWavSoundFromRes,MENU_SELECT_WAV_RES,0
                
            .endif
        .endw
        
        ;start
        .if choice == 1
            mov gameOver,1
        ;about
        .elseif choice == 2
            fn AboutMenu
        ;exit
        .elseif choice == 3
            mov closeConsole,1    
        .endif
        
        fn crt_system,offset szCls
        mov byte ptr[bKey],31h      
    .endw  
    ret
MainMenu endp

AboutMenu proc uses ebx esi edi
    local hFile:dword
    local buffer[256]:byte
    local bStart:dword
    
    mov bStart,0
    fn crt_system,offset szCls
    fn crt_fopen,offset szAbout,"r"
    or eax,eax
    je @@Ret
    mov dword ptr[hFile],eax
    push eax    
    fn SetConsoleColor,0,LightRed
    lea ebx,buffer
    
@@While:
    fn crt_fgets,ebx,256,hFile
    or eax,eax
    je @@CloseFile
    fn crt_printf,eax
    inc bStart
    .if bStart == 9
        fn SetConsoleColor,0,cYellow
    .endif
    jmp @@While
        
@@CloseFile:
    pop eax
    fn crt_fclose,eax
    fn Keyboard_check_pressed
    fn PlayWavSoundFromRes,MENU_SELECT_WAV_RES,0
     
@@Ret:  
	ret
AboutMenu endp