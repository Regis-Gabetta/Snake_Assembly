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


WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
IDB_MAIN   equ 1
IDB_MAIN1  equ 2
IDB_FIG    equ 3

.data
ClassName db "SimpleWin32ASMBitmapClass",0
AppName  db "Win32ASM Simple Bitmap Example",0

hBitmap2 dd 0
hBitmap3 dd 0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?

rectFundo RECT <>
hBitmap dd ?
rect RECT <>
estado db ?


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
      mov   rect.right,500
      mov   rect.bottom,500
      mov   estado,0
; chamar Bitblt ao criar para criar pano de fundo
      invoke GetClientRect,hWnd,addr rectFundo

   .elseif uMsg==WM_CHAR
      cmp   wParam,'d'
      jne   nao
      add   rect.left, 6
      add   rect.right, 6
 
nao:
      cmp   wParam,'a'
      jne   nao1
      sub   rect.left, 6
      sub   rect.right, 6

nao1:
      cmp   wParam,'s'
      jne   nao2
      add   rect.top, 6

nao2:
      cmp   wParam,'w'
      jne   nao3
      sub   rect.top, 6

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
      invoke BitBlt,hdc,rect.left,rect.top,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
 ;     invoke DeleteDC,hMemDC
      jmp    fim  
fig2:    
      invoke SelectObject,hMemDC,hBitmap2
      invoke BitBlt,hdc,rect.left,rect.top,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
  ;    invoke DeleteDC,hMemDC
fim:
      invoke DeleteDC,hMemDC

     
      invoke EndPaint,hWnd,addr ps
	.elseif uMsg==WM_DESTROY
      invoke DeleteObject,hBitmap
		invoke PostQuitMessage,NULL
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.ENDIF
	xor eax,eax
	ret
WndProc endp
end start


