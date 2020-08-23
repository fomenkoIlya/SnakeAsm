@echo off
::Компилировать ли ресурсы [0,1]
set rc_build=1
::Запускать ли автоматически собранный .exe файл [0,1]
set exe_run=1
::Имя исходного файла и готового exe
set exe_name=main
::Имя rc файла ресурсов
set rc_file_name=rsrc
::Тип сборки, консоль, окно и т.д [console, window]
set sub_sustem=console
::**************************************************************************
set del_obj=1
set del_res=1
set main_file_asm="%cd%\%exe_name%.asm"
set rc_file="%cd%\%rc_file_name%.rc"
set res_file="%cd%\%rc_file_name%.res"
set obj_file="%cd%\%exe_name%.obj"
::Компиляция ресурсов .RES
if %rc_build%==1 (cmd /C rc rsrc.rc)
@echo on
::Компиляция .obj
cmd /C ml /c /coff %main_file_asm%
::Сборка .exe
if %rc_build%==1 (cmd /C link /subsystem:%sub_sustem% %obj_file% %res_file%)
if %rc_build%==0 (cmd /C link /subsystem:%sub_sustem% %obj_file%)
@echo off
if %del_obj%==1 if exist %obj_file% (del %obj_file%)
if %del_res%==1 if exist %res_file% (del %res_file%)
::Запуск программы
if %exe_run%==1 (start %exe_name%.exe)
pause
