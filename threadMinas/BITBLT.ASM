; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include bitblt.inc    ; local includes for this file

teste	equ		101
sweep   equ		102

CREF_TRANSPARENT  EQU 0FF00FFh
CREF_TRANSPARENT2 EQU 0FF0000h


; #########################################################################

.code

start:
      invoke GetModuleHandle, NULL
      mov hInstance, eax
      jmp l1
	tes db 	'Alo PD ',0
l1:
      invoke LoadBitmap,hInstance, teste ;100
      mov hBmp, eax

      invoke LoadBitmap,hInstance, sweep
      mov hBmp2, eax

      
      invoke GetCommandLine
      mov CommandLine, eax

      invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
      invoke ExitProcess,eax

; #########################################################################

WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

      ;====================
      ; Put LOCALs on stack
      ;====================

      LOCAL wc   :WNDCLASSEX
      LOCAL msg  :MSG
      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD

      ;==================================================
      ; Fill WNDCLASSEX structure with required variables
      ;==================================================

      invoke LoadIcon,hInst,500    ; icon ID
      mov hIcon, eax

      szText szClassName,"Project_Class"

      mov wc.cbSize,         sizeof WNDCLASSEX
      mov wc.style,          CS_BYTEALIGNWINDOW
      mov wc.lpfnWndProc,    offset WndProc
      mov wc.cbClsExtra,     NULL
      mov wc.cbWndExtra,     NULL
      m2m wc.hInstance,      hInst
      mov wc.hbrBackground,  COLOR_BTNFACE+1
      mov wc.lpszMenuName,  OFFSET MenuName
      mov wc.lpszClassName,  offset szClassName
      m2m wc.hIcon,          hIcon
        invoke LoadCursor,NULL,IDC_ARROW
      mov wc.hCursor,        eax
      m2m wc.hIconSm,        hIcon

      invoke RegisterClassEx, ADDR wc

      ;================================
      ; Centre window at following size
      ;================================

      mov Wwd, 500
      mov Wht, 350

      invoke GetSystemMetrics,SM_CXSCREEN
      invoke TopXY,Wwd,eax
      mov Wtx, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      invoke TopXY,Wht,eax
      mov Wty, eax

      invoke CreateWindowEx,WS_EX_LEFT,
                            ADDR szClassName,
                            ADDR szDisplayName,
                            WS_OVERLAPPEDWINDOW,
                            Wtx,Wty,Wwd,Wht,
                            NULL,NULL,
                            hInst,NULL
      mov   hWnd,eax

  ;    invoke LoadMenu,hInst,600  ; menu ID
 ;     invoke SetMenu,hWnd,eax

      invoke ShowWindow,hWnd,SW_SHOWNORMAL
      invoke UpdateWindow,hWnd

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

      return msg.wParam

WinMain endp

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL Rct    :RECT
    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_COMMAND
    ;======== menu commands ========
		mov eax,wParam
		.IF ax==IDM_TEST
			invoke MessageBox,NULL,ADDR Test_string,OFFSET AppName,MB_OK
		.ELSE
			invoke DestroyWindow,hWnd
		.ENDIF    
    .elseif uMsg == WM_CREATE

    mov ecx,tam_snake
    mov dif_snake, ecx
	  mov posicao.x,200
		mov posicao.y,0
    mov lRect.bottom,10

    mov rectCom.left, 200
    mov rectCom.right,210
    mov rectCom.top, 200
    mov rectCom.bottom,210
		
		invoke CreateEvent,NULL,FALSE,FALSE,NULL
		mov    hEventStart,eax
		
		mov    eax,OFFSET ThreadProc
		invoke CreateThread,NULL,NULL,eax,\
		                    NULL,NORMAL_PRIORITY_CLASS,\
		                     ADDR ThreadID
		mov    hThread,eax

		
    .elseif uMsg == WM_SIZE
;    // obter o tamanho da janela
    
    .elseif uMsg == WM_MOUSEMOVE

    
    .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
        mov hDC, eax
        invoke Draw_Snake,hWnd,hDC
        invoke EndPaint,hWin,ADDR Ps
        return 0

    .elseif uMsg == WM_CLOSE
    
    .elseif uMsg == WM_CHAR

    cmp wParam,'h'
    jne nao
    not achou
   nao:
    	cmp wParam,'a'
    	jne nao1
	    mov lRect.right,10
	    mov lRect.left,0
	    mov lRect.top,0
	    mov lRect.bottom,0
	    jmp nao4
	 nao1:
    cmp wParam,'d'
    jne nao2
    mov lRect.left,10
    mov lRect.top,0
    mov lRect.bottom,0
    mov lRect.right,0
    jmp nao4
	 nao2:
    cmp wParam,'w'
    jne nao3
    mov lRect.left,0
    mov lRect.top,10
    mov lRect.bottom,0
    mov lRect.right,0
    jmp nao4

   nao3:
    cmp wParam,'s'
    jne nao4
    mov lRect.left,0
    mov lRect.top,0
    mov lRect.bottom,10
    mov lRect.right,0

   nao4:
    invoke InvalidateRect, hWnd, addr lRect,TRUE 


   .elseif uMsg == WM_RBUTTONDOWN
   	  ;  invoke PostMessage,hWnd,WM_FINISH,NULL,NULL
   	 ; invoke SetEvent,hEventStart
   	    
   .elseif uMsg==WM_FINISH

      mov ecx,posicao.y
         .if rectCom.bottom >= ecx
            add ecx,20
            .if rectCom.top <= ecx
                mov ecx,posicao.x
                .if rectCom.right >= ecx
                    add ecx,20
                    .if rectCom.left <= ecx
                      cmp achou,0
                      jne aqui
                      add dif_snake,20
                      aqui:
                      mov achou,1
                    .endif
                .endif
            .endif      
         .endif

   	   .if lRect.right ==10
	       sub posicao.x,1
       .elseif lRect.left ==10
         add posicao.x,1
       .elseif lRect.top ==10
         sub posicao.y,1
       .elseif lRect.bottom ==10
         add posicao.y,1
       .endif

    mov ecx, tam_snake
    .if dif_snake > ecx   
      inc tam_snake
    .endif  

    .if posicao.x > 464
	     mov posicao.x,230
	     mov posicao.y,1
       mov lRect.bottom,10
       mov lRect.top,0
       mov lRect.left,0
       mov lRect.right,0

	  .endif 
    .if posicao.x < 2
       mov posicao.x,230
       mov posicao.y,1
       mov lRect.bottom,10
       mov lRect.top,0
       mov lRect.left,0
       mov lRect.right,0
    .endif 
    .if posicao.y < 1
       mov posicao.x,230
       mov posicao.y,1
       mov lRect.bottom,10
       mov lRect.top,0
       mov lRect.left,0
       mov lRect.right,0
    .endif 
    .if posicao.y > 272
       mov posicao.x,230
       mov posicao.y,1
       mov lRect.bottom,10
       mov lRect.top,0
       mov lRect.left,0
       mov lRect.right,0
    .endif 

	  invoke InvalidateRect,hWnd,NULL,TRUE	     
  
  .elseif uMsg == WM_DESTROY
    	mov  EventStop,TRUE
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ########################################################################

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY endp

; #########################################################################

ThreadProc PROC USES ecx Param:DWORD

  invoke WaitForSingleObject,hEventStart,10 ;INFINITE

	.IF eax == WAIT_TIMEOUT	
	           invoke PostMessage,hWnd,WM_FINISH,NULL,NULL
	           jmp   ThreadProc     
	.ELSEIF eax == WAIT_OBJECT_0	
	         invoke PostMessage,hWnd,WM_FINISH,NULL,NULL
	          jmp   ThreadProc
        .ENDIF
        
        jmp   ThreadProc
        
        ret
ThreadProc ENDP

Draw_Snake proc hWin:DWORD, hDC:DWORD

    
    LOCAL hPen      :DWORD
    LOCAL hPenOld   :DWORD
    LOCAL hBrush    :DWORD
    LOCAL hBrushOld :DWORD

    LOCAL lb        :LOGBRUSH

    invoke Rectangle,hDC,0,0,484,292

    continua:
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

    mov ecx,posicao.x
    add ecx,tam_snake
    mov edx,posicao.y
    add edx,20
    invoke Rectangle,hDC,posicao.x,posicao.y,ecx,edx

    cmp achou,0
    jne pulou

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

      invoke Rectangle,hDC,rectCom.left,rectCom.top,rectCom.right,rectCom.bottom
  
    pulou:

    invoke SelectObject,hDC,hBrushOld
    invoke DeleteObject,hBrush

    invoke SelectObject,hDC,hPenOld
    invoke DeleteObject,hPen

    ret

Draw_Snake endp


end start
