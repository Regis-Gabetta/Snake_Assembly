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

    .elseif uMsg == WM_CREATE

    mov ecx,tam_snake
    mov dif_snake, ecx
	  mov cabeca.left,200
    mov cabeca.right,220
		mov cabeca.top,100
    mov cabeca.bottom,120
    mov baixo,1

    mov corpo1.left,200
    mov corpo1.right,220
    mov corpo1.top,80
    mov corpo1.bottom,100

    mov corpo2.left,200
    mov corpo2.right,220
    mov corpo2.top,60
    mov corpo2.bottom,80

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

    
   nao:
      .if wParam != 97 && wParam != 100 && wParam != 119 && wParam !=115
        jmp nao4
      .endif

      .if direita != 0

        .if wParam == 'a'
        jmp passo2
        .elseif wParam == 'd'
        jmp passo2
        .endif

        mov posAnt,2
        mov ecx, cabeca.right
        mov ptInf,ecx


      .elseif esquerda !=0
        .if wParam == 'a'
        jmp passo2
        .elseif wParam == 'd'
        jmp passo2
        .endif

        mov posAnt,3
        mov ecx,cabeca.left
        mov ptInf,ecx


      .elseif cima != 0

        .if wParam == 'w'
        jmp passo2
        .elseif wParam == 's'
        jmp passo2
        .endif

        mov posAnt,1
        mov ecx,cabeca.top
        mov ptInf,ecx
      .elseif baixo != 0

        .if wParam == 'w'
        jmp passo2
        .elseif wParam == 's'
        jmp passo2
        .endif

        mov posAnt, 0
        mov ecx,cabeca.bottom
        mov ptInf,ecx
      .endif

  passo2:
    	cmp wParam,'a'
      jne nao1
      cmp direita,1
      je nao4
      cmp esquerda,1
      je nao4
      mov esquerda,1
      mov direita,0
      mov cima,0
      mov baixo,0
	    jmp nao4
	 nao1:
    cmp wParam,'d'
    jne nao2
    cmp direita,1
    je nao4
    cmp esquerda,1
    je nao4
    mov esquerda,0
    mov direita,1
    mov cima,0
    mov baixo,0

    jmp nao4
	 nao2:
    cmp wParam,'w'
    jne nao3
    cmp cima,1
    je nao4
    cmp baixo,1
    je nao4
    mov esquerda,0
    mov direita,0
    mov cima,1
    mov baixo,0

    jmp nao4

   nao3:
    cmp wParam,'s'
    jne nao4    
    cmp cima,1
    je nao4
    cmp baixo,1
    je nao4
    mov esquerda,0
    mov direita,0
    mov cima,0
    mov baixo,1


   nao4:



   .elseif uMsg == WM_RBUTTONDOWN
   	  ;  invoke PostMessage,hWnd,WM_FINISH,NULL,NULL
   	 ; invoke SetEvent,hEventStart
   	    
   .elseif uMsg==WM_FINISH

      mov ecx,cabeca.top
         .if rectCom.bottom >= ecx
            add ecx,20
            .if rectCom.top <= ecx
                mov ecx,cabeca.left
                .if rectCom.right >= ecx
                    add ecx,20
                    .if rectCom.left <= ecx
                      cmp achou,0
                      jne aqui
                      add dif_snake,20
                      mov achou,1
                      add quantos,1
                      aqui:
                      
                    .endif
                .endif
            .endif      
         .endif

   	   .if esquerda != 0

        .if posAnt == 1
              mov ecx,corpo1.top
              .if ecx > ptInf
                dec corpo1.top
                dec corpo1.bottom
              .else 
                dec corpo1.left
                dec corpo1.right
              .endif

              mov ecx, corpo2.top

              .if ecx > ptInf
                dec corpo2.top
                dec corpo2.bottom
              .else 
                dec corpo2.left
                dec corpo2.right
              .endif            
        .endif

        .if posAnt == 0
              mov ecx,corpo1.bottom
              .if ecx < ptInf
                inc corpo1.top
                inc corpo1.bottom
              .else 
                dec corpo1.left
                dec corpo1.right
              .endif

              mov ecx, corpo2.top

              .if ecx < ptInf
                inc corpo2.top
                inc corpo2.bottom
              .else 
                dec corpo2.left
                dec corpo2.right
              .endif            

        .endif


	       sub cabeca.left,1
         sub cabeca.right,1
         
       .elseif direita != 0
          .if posAnt == 0

              mov ecx,corpo1.bottom

              .if ecx < ptInf
                inc corpo1.top
                inc corpo1.bottom
              .else 
                inc corpo1.left
                inc corpo1.right
              .endif

              mov ecx, corpo2.top

              .if ecx < ptInf
                inc corpo2.top
                inc corpo2.bottom
              .else 
                inc corpo2.left
                inc corpo2.right
              .endif        
          
          .endif

          .if posAnt == 1

              mov ecx,corpo1.top
              .if ecx > ptInf
                dec corpo1.top
                dec corpo1.bottom
              .else 
                inc corpo1.left
                inc corpo1.right
              .endif

              mov ecx, corpo2.top

              .if ecx > ptInf
                dec corpo2.top
                dec corpo2.bottom
              .else 
                inc corpo2.left
                inc corpo2.right
              .endif           

          .endif


         add cabeca.left,1
         add cabeca.right,1

       .elseif cima != 0

          .if posAnt == 2
              mov ecx, corpo1.right

              .if ecx < ptInf
                inc corpo1.left
                inc corpo1.right
              .else 
                dec corpo1.top
                dec corpo1.bottom
              .endif

              mov ecx, corpo2.top

              .if ecx < ptInf
                inc corpo2.left
                inc corpo2.right
              .else 
                dec corpo2.top
                dec corpo2.bottom
              .endif

              
            .endif

          .if posAnt == 3

              mov ecx, corpo1.left

              .if ecx > ptInf
                dec corpo1.left
                dec corpo1.right
              .else 
                dec corpo1.top
                dec corpo1.bottom
              .endif

              mov ecx, corpo2.top

              .if ecx < ptInf
                dec corpo2.left
                dec corpo2.right
              .else 
                dec corpo2.top
                dec corpo2.bottom
              .endif
            
          .endif
          sub cabeca.top,1
          sub cabeca.bottom,1

       .elseif baixo != 0

            .if posAnt == 2
              mov ecx, corpo1.right

              .if ecx < ptInf
                inc corpo1.left
                inc corpo1.right
              .else 
                inc corpo1.top
                inc corpo1.bottom
              .endif

              mov ecx, corpo2.top

              .if ecx < ptInf
                inc corpo2.left
                inc corpo2.right
              .else 
                inc corpo2.top
                inc corpo2.bottom
              .endif
            .endif


           .if posAnt == 3

              mov ecx, corpo1.left

              .if ecx > ptInf
                dec corpo1.left
                dec corpo1.right
              .else 
                inc corpo1.top
                inc corpo1.bottom
              .endif

              mov ecx, corpo2.top

              .if ecx < ptInf
                dec corpo2.left
                dec corpo2.right
              .else 
                inc corpo2.top
                inc corpo2.bottom
              .endif
                
            .endif


         add cabeca.top,1
         add cabeca.bottom,1
         .if posAnt == 0
            inc corpo2.top
            inc corpo2.bottom
            inc corpo1.top
            inc corpo1.bottom
         .endif
       .endif





    mov ecx, tam_snake
    .if dif_snake > ecx   
      inc tam_snake
    .endif  

    .if cabeca.left > 464
	     mov cabeca.left,230
       mov cabeca.right,250
	     mov cabeca.top,1
       mov cabeca.bottom,21
       mov baixo,1
       mov cima,0
       mov direita,0
       mov esquerda,0

	  .endif 
    .if cabeca.left < 2
       mov cabeca.left,230
       mov cabeca.right,250
       mov cabeca.top,1
       mov cabeca.bottom,21
       mov baixo,1
       mov cima,0
       mov direita,0
       mov esquerda,0
    .endif 
    .if cabeca.top < 1
       mov cabeca.left,230
       mov cabeca.right,250
       mov cabeca.top,1
       mov cabeca.bottom,21
       mov baixo,1
       mov cima,0
       mov direita,0
       mov esquerda,0
    .endif 
    .if cabeca.top> 272
       mov cabeca.left,230
       mov cabeca.right,250
       mov cabeca.top,1
       mov cabeca.bottom,21
       mov baixo,1
       mov cima,0
       mov direita,0
       mov esquerda,0
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

    

    continua:
    invoke CreatePen,0,1,00FF0000h  
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

    mov ecx,cabeca.left
    mov edx,cabeca.top
    invoke Rectangle,hDC,cabeca.left,cabeca.top,cabeca.right,cabeca.bottom
    invoke Rectangle,hDC,corpo1.left,corpo1.top,corpo1.right,corpo1.bottom
    .if quantos>=1
    invoke Rectangle,hDC,corpo2.left,corpo2.top,corpo2.right,corpo2.bottom
    .endif

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
