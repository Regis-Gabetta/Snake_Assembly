; #########################################################################

;     include files
;     ~~~~~~~~~~~~~
      include C:\MASM32\INCLUDE\windows.inc
      include C:\MASM32\INCLUDE\masm32.inc
      include C:\MASM32\INCLUDE\gdi32.inc
      include C:\MASM32\INCLUDE\user32.inc
      include C:\MASM32\INCLUDE\kernel32.inc
      include C:\MASM32\INCLUDE\Comctl32.inc
      include C:\MASM32\INCLUDE\comdlg32.inc
      include C:\MASM32\INCLUDE\shell32.inc

    INCLUDE    C:\Masm32\Include\msimg32.inc
    INCLUDE    C:\Masm32\Include\oleaut32.inc
    INCLUDE    C:\Masm32\Macros\macros.asm



;     libraries
;     ~~~~~~~~~
      includelib C:\MASM32\LIB\masm32.lib

      includelib C:\MASM32\LIB\gdi32.lib
      includelib C:\MASM32\LIB\user32.lib
      includelib C:\MASM32\LIB\kernel32.lib
      includelib C:\MASM32\LIB\Comctl32.lib
      includelib C:\MASM32\LIB\comdlg32.lib
      includelib C:\MASM32\LIB\shell32.lib

    INCLUDELIB C:\Masm32\Lib\msimg32.lib
    INCLUDELIB C:\Masm32\Lib\oleaut32.lib
    INCLUDELIB C:\Masm32\Lib\msvcrt.lib
    INCLUDELIB C:\Masm32\Lib\masm32.lib

; #########################################################################

        ;=================
        ; Local prototypes
        ;=================
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD
        FillBuffer   PROTO :DWORD,:DWORD,:BYTE
        Paint_Proc   PROTO :DWORD,:DWORD
        Draw_Snake   PROTO :DWORD,:DWORD

        wsprintfA PROTO C :DWORD,:VARARG
        wsprintf equ <wsprintfA>

      ;=============
      ; Local macros
      ;=============

      szText MACRO Name, Text:VARARG
        LOCAL lbl
          jmp lbl
            Name db Text,0
          lbl:
        ENDM

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

    .data
        szDisplayName db "BitBlt",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        hIcon         dd 0
        hBmp          dd 0
        hBmp2         dd 0
        memDC2        DWORD 0
        x		 dd 0
        trasp		 dd  0
        quantos  dd  0
        achou		 dd  0
        direita  dd  0
        esquerda dd  0
        cima     dd  0
        baixo    dd  0
        cont     dd  0
        ptInf    dd  0
        posAnt   dd  0  ;0=baixo,1=cima,2=direita,3=esquerda
        tam_snake dd 20
        dif_snake dd 0
        primeira  dd 0
        lRect           RECT <>
        rectCom         RECT <>
        hitpoint 	POINT <>
        cabeca    RECT <>
        corpo1    RECT<>
        corpo2    RECT<>
        ThreadID dd 0
	ExitCode dd 0
	hThread dd 0
	hEventStart dd 0
        
AppName  db "Our First Window",0
MenuName db "FirstMenu",0
Test_string db "You selected Test menu item",0

EventStop BOOL FALSE



.const
IDM_TEST equ 1
IDM_HELLO equ 2
IDM_GOODBYE equ 3
IDM_EXIT equ 4
        
WM_FINISH equ WM_USER+100h
        
        

; ########################### Inserted modules ############################


; #########################################################################
