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
        Tiny_Random proto :DWORD

        wsprintfA PROTO C :DWORD,:VARARG
        wsprintf equ <wsprintfA>

      ;=============
      ; Local macros
      ;=============

      RGB MACRO red,green,blue 
        xor eax,eax 
        mov ah,blue 
        shl eax,8 
        mov ah,green 
        mov al,red 
    ENDM

      ESCREVE_TEXTO MACRO FontName, hDC, hfont, texto, x, y
        invoke CreateFont,24,16,0,0,400,0,0,0,OEM_CHARSET,\
               OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
               DEFAULT_QUALITY,DEFAULT_PITCH or FF_SCRIPT,\
               ADDR FontName
        invoke SelectObject, hDC, eax
        mov    hfont,eax
        RGB 200,200,50
        invoke SetTextColor,hDC,eax
        RGB    0,160,192
        invoke SetBkColor,hDC,eax

        invoke TextOut,hDC,x,y,ADDR texto,SIZEOF texto
        invoke SelectObject,hDC, hfont
    ENDM



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
        hello         dd 0
        hBmp2         dd 0
        TinyRNG_x   dd  0
        TinyRNG_a   dd  100711433
        memDC2        DWORD 0
        x		 dd 0
        trasp		 dd  0
        quantos  dd  0
        achou		 dd  0
        direita  dd  0
        somatoria dd 0
        esquerda dd  0
        cima     dd  0
        baixo    dd  0
        contador dd  0
        cont     dd  10
        FontName db "Consolas",0
        Text     db "Score :",0
        ptInf    dd  0
        posVet   dd  0
        contLim  dd  0
        dirAtual dd  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        limite1  dd  0
        unid     dd  0
        dez      dd  0
        cent     dd  0
        limite2  dd  0
        posArm   dd  0
        posAnt   dd  0  ;0=baixo,1=cima,2=direita,3=esquerda
        posMant  dd  10
        primeira  dd 1
        lRect           RECT <>
        rectCom         RECT <>
        hitpoint 	POINT <>
        cabeca    RECT <>
        corpo1    RECT<>
        corpo2    RECT<>
        corpo3    RECT<>
        corpo4    RECT<>
        corpo5    RECT<>
        corpo6    RECT<>
        corpo7    RECT<>
        corpo8    RECT<>
        corpo9    RECT<>
        corpo10   RECT<>
        corpo11   RECT<>
        corpo12   RECT<>

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
