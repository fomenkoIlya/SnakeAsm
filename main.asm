include main.inc
include obj_fruit.asm
include obj_snake.asm
include engine.asm
include interface.asm

.code
start:

fn SetConsoleTitle,"Snake game"
fn SetConsoleWindowSize,MAX_WIDTH,MAX_HEIGHT,0
fn HideConsoleCursor
fn Main 
exit
    
Main proc   
    fn MainMenu 

    .while closeConsole == 0
        fn StartGameEvent                   
        .while gameOver == 1   
                
        .endw  
          
        fn MainMenu
    .endw
      
    ret
Main endp   

end start
