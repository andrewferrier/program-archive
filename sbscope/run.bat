@echo off

if "%1"=="" goto standard
goto other

:standard
\tasm\tasm sbscope.asm /DSB_BASE=220h
\tasm\tlink sbscope.obj,sbscope.exe /3
sbscope
pause
mode co80
goto end

:other
\tasm\tasm sbscope.asm %2
\tasm\tlink sbscope.obj,%1.exe /3

:end
