@echo off
::Удалять ли .obj файл после сборки [0,1]
set del_obj=1
::Запускать ли автоматически собранный .exe файл [0,1]
set exe_run=1
::Имя для исходного файла и exe
set exe_name=main
::Тип сборки, консоль, окно и т.д
set sub_sustem=console
::Путь к главному исходному файлу
set main_file_asm="%cd%\%exe_name%.asm"
::Путь к obj файлу
set obj_file="%cd%\%exe_name%.obj"
::Путь к дириктории с компилятором и линкером
set masm32_path="D:\masm32\bin\"
@echo on
::Запуск компиляции и итоговой сборки с выводом ошибок в консоль
cmd /C ml /c /coff %main_file_asm%
cmd /C link /subsystem:%sub_sustem% %obj_file%
@echo off
if %del_obj%==1 del %obj_file%
::Запуск программы
if %exe_run%==1 start %exe_name%.exe
pause
