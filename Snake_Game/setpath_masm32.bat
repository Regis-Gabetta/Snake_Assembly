echo off

rem comando bat dos para se utilizado com o masm32 
rem
rem ajuste de path para que possa utilizar o masm32
rem
rem

cls

echo  "Ajuste de path para execução do masm32- SLMM 2017"


IF EXIST c:\masm32\bin SET PATH=%PATH%;c:\masm32\bin;c:\masm32;c:\masm32\include;c:\masm32\lib


setx ENV_VAR_NAME "c:\masm32\bin;c:\masm32" /m



start qeditor.exe

cls
echo on

