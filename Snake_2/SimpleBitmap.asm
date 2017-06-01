.386
.model flat,stdcall
option casemap:none
include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\gdi32.inc
include C:\masm32\include\comctl32.inc

includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\gdi32.lib
includelib C:\masm32\include\comctl32.lib

Paint_Proc proto :DWORD,:DWORD
ThreadProc proto :DWORD,:DWORD,:DWORD


WinMain proto :DWORD,:DWORD,:DWORD,:DWORD


IDM_CREATE_THREAD equ 1
IDB_MAIN1  equ 2
IDB_FIG    equ 3
IDB_APPLE  equ 4
IDB_MAIN   equ 5
WM_FINISH equ WM_USER+100h



.data
ClassName db "SimpleWin32ASMBitmapClass",0
AppName  db "Win32ASM Simple Bitmap Example",0

hBitmap2 dd 0
hBitmap3 dd 0
hBitmap4 dd 0
TimerID  dd 0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?

rectFundo RECT <>
hBitmap dd ?
rect RECT <>
estado db ?
hwndProgress dd ? 
hwndStatus dd ? 
CurrentStep dd ? 
ThreadID DWORD ?



.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov    CommandLine,eax
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	.while TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.break .if (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw
	mov     eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT
   LOCAL hdc:HDC
   LOCAL hMemDC:HDC
   .if uMsg==WM_CREATE
      invoke LoadBitmap,hInstance,IDB_FIG
      mov hBitmap,eax

      invoke LoadBitmap,hInstance,IDB_MAIN1
      mov hBitmap2,eax

      invoke LoadBitmap,hInstance,IDB_MAIN
      mov hBitmap3,eax

      mov   rect.left,2
      mov   rect.top,2
      mov   rect.right,50
      mov   rect.bottom,50
      mov   estado,0
; chamar Bitblt ao criar para criar pano de fundo
      invoke GetClientRect,hWnd,addr rectFundo

   .elseif uMsg==WM_COMMAND
      mov eax,wParam
                        MOV   rect.left, 2  
                        ADD   rect.top,10
                        ADD   rect.bottom,10

            mov  eax,OFFSET ThreadProc
            invoke CreateThread,NULL,NULL,ThreadProc,eax,0,ADDR ThreadID
            invoke CloseHandle,eax

   .elseif uMsg==WM_FINISH
       add rect.left, 2
       add rect.right,2

   .elseif uMsg==WM_CHAR
      cmp   wParam,'d'
      jne   nao
      add   rect.left, 2
      add   rect.right, 2
thread:
      cmp wParam,'h'
      jne nao
      mov ax,IDM_CREATE_THREAD
 
nao:
      cmp   wParam,'a'
      jne   nao1
      sub   rect.left, 2
      sub   rect.right, 2

nao1:
      cmp   wParam,'w'
      jne   nao2
      sub   rect.top, 2
      sub   rect.bottom, 2

nao2:
      cmp   wParam,'s'
      jne   nao3
      add   rect.top, 2
      add   rect.bottom, 2

nao3:
      not   estado
      invoke InvalidateRect, hWnd, NULL, FALSE             

   .elseif uMsg==WM_PAINT
      invoke BeginPaint,hWnd,addr ps
      mov hdc,eax
      invoke CreateCompatibleDC,hdc
      mov hMemDC,eax

;      invoke SelectObject,hMemDC,hBitmap
;      invoke BitBlt,hdc,200,200,200,200,hMemDC,150,150,SRCCOPY
;      invoke SelectObject,hMemDC,hBitmap3
;      invoke BitBlt,hdc,rect.left,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
;      invoke DeleteDC,hMemDC

      invoke SelectObject,hMemDC,hBitmap
      invoke BitBlt,hdc,0,0,10000,10000,hMemDC,50,10,MERGECOPY	


      cmp   estado,0
      jne   fig2
fig1:
      invoke SelectObject,hMemDC,hBitmap3
      invoke Paint_Proc,hWnd,hdc
 ;     invoke DeleteDC,hMemDC
      jmp    fim  
fig2:    
      invoke SelectObject,hMemDC,hBitmap2
      invoke Paint_Proc,hWnd,hdc

  ;    invoke DeleteDC,hMemDC
fim:
      invoke DeleteDC,hMemDC

     
      invoke EndPaint,hWnd,addr ps
	.elseif uMsg==WM_DESTROY
      invoke DeleteObject,hBitmap
		invoke PostQuitMessage,NULL
      .if TimerID!=0 
            invoke KillTimer,hWnd,TimerID 
      .endif
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.ENDIF
	xor eax,eax
	ret
WndProc endp


Paint_Proc proc hWin:DWORD, hDC:DWORD

    LOCAL hPen      :DWORD
    LOCAL hPenOld   :DWORD
    LOCAL hBrush    :DWORD
    LOCAL hBrushOld :DWORD

    LOCAL lb        :LOGBRUSH

    invoke CreatePen,0,1,00000000h  
    mov hPen, eax

    mov lb.lbStyle, BS_SOLID
    mov lb.lbColor, 00FF0000h       
    mov lb.lbHatch, NULL

    invoke CreateBrushIndirect,ADDR lb
    mov hBrush, eax

    invoke SelectObject,hDC,hPen
    mov hPenOld, eax

    invoke SelectObject,hDC,hBrush
    mov hBrushOld, eax

  ; ------------------------------------------------
  ; The 4 GDI functions use the pen colour set above
  ; and fill the area with the current brush.
  ; ------------------------------------------------

    mov ecx,rect.left
    add ecx,20
    mov edx,rect.top
    add edx,20
    invoke Rectangle,hDC,rect.left,rect.top,ecx,edx

   invoke CreatePen,0,1,000000h  
    mov hPen, eax

    mov lb.lbStyle, BS_SOLID
    mov lb.lbColor, 999000h       
    mov lb.lbHatch, NULL

    invoke CreateBrushIndirect,ADDR lb
    mov hBrush, eax

    invoke SelectObject,hDC,hPen
    mov hPenOld, eax

    invoke SelectObject,hDC,hBrush
    mov hBrushOld, eax
    mov lb.lbColor, 000000h  
    invoke Rectangle,hDC,100,200,110,210
  ; ------------------------------------------------

    invoke SelectObject,hDC,hBrushOld
    invoke DeleteObject,hBrush

    invoke SelectObject,hDC,hPenOld
    invoke DeleteObject,hPen

    ret

Paint_Proc endp

ThreadProc PROC USES ecx Param:DWORD, hwnd:HWND, hDC:DWORD
        mov  ecx,300000000
Loop1:
        add rect.left,2
        add rect.left,2
        invoke Rectangle,hDC,10,10,300,300
        invoke SendMessage,hwnd,WM_FINISH,NULL,NULL

Get_out:
        invoke SendMessage,hwnd,WM_FINISH,NULL,NULL
        ret
ThreadProc ENDP


end start


