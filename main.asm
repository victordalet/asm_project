extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XDrawPoint
extern XFillArc
extern XNextEvent

extern printf
extern exit

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		    19
%define KeyPress		    2
%define ButtonPress		    4
%define Expose			    12
%define ConfigureNotify		22
%define CreateNotify        16
%define QWORD	            8
%define DWORD	            4
%define WORD	            2
%define BYTE	            1
%define NB_POINTS           30

global main

section .bss
    display_name:	        resq	1
    screen:			        resd	1
    depth:         	        resd	1
    connection:    	        resd	1
    width:         	        resd	1
    height:        	        resd	1
    window:		            resq	1
    gc:		                resq	1

    array_x:                resq   NB_POINTS
    array_y:                resq    NB_POINTS
    tabindex:               resb    NB_POINTS
    val:                    resb    1
    last_point_random_x :   resq 1
    last_point_random_y :   resq 1
    xab:                    resq 1
    yab:                    resq 1
    xbc:                    resq 1
    ybc:                    resq 1



section .data

    event:	                    times	24 dq 0
    x1:	                        dd	0
    x2:	                        dd	0
    y1:	                        dd	0
    y2:                     	dd	0
    i:                          db 0
    j:                          db 0
    k:                          db 0
    is_to_left:                 db 1
    last_random_point_print:    db  "Dernier Point aléatoire: %d",10,0
    last_sense_is:              db  "Le point (%d,%d) est cp,te,i dans l'enveloppe",10,0
    last_sense_is_not:          db  "Le point (%d,%d) n'est pas contenu dans l'enveloppe",10,0
    point_max_left_print:       db  "index max gauche est %d",10,0
    result_vectoriel_print:     db  "result vectoriel est %d",10,0
    display:                    db  "t[%d]=%d",10,0
    min_angle_index:            dd 0
    last_min_angle_index:       dd 0
    max:	                    dd	10
    swapped:	                dd	0
    result_vectoriel_xbc_yab:	dq	0
    result_vectoriel_ybc_xab:	dq	0
    final_result_vectoriel:	    dq	0
    p_index:                    db	0
    q_index:                    db	0
    l_index:                    db	0


section .text
main:
    push rbp
    jmp init_array_1

;##################################################
; RANDOM POINT
;##################################################
init_array_1:
    ; init last random point
    rdrand rax
    mov rax, rax
    and rax, 0FFh
    mov [last_point_random_x], rax
    rdrand rax
    mov rax, rax
    and rax, 0FFh
    mov [last_point_random_y], rax

    ; init array
    movzx rsi, byte[i]
    movzx ecx, byte[i]
    rdrand rax
    mov rax, rax
    and rax, 0FFh
    mov [array_x+ecx*QWORD], rax

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb init_array_1

    mov byte[i], 0
    jmp bubble


applic_neg:

bubble:
		mov byte[swapped],0	; variable indiquant s'il y a eu échange de valeurs (si oui, swapped=1)
		mov byte[i],1	; i=compteur de boucle
		boucle_bubble:
			movzx ebx,byte[i]		; ebx=i
			mov cl,byte[array_x+ebx*QWORD]	; cl=tab[i]
			dec ebx				; ebx=i-1
			mov dl,byte[array_x+ebx*QWORD] 	; dl=tab[i-1]
			cmp cl,dl
		jae noswap ; si cl>=dl, pas d'échange : saut à noswap

			;Echange
			mov byte[array_x+ebx*QWORD],cl	; tab[i-1]=tab[i]
			inc ebx	; ebx=i
			mov byte[array_x+ebx*QWORD],dl	; tab[i]=tab[i-1]
			mov byte[swapped],1	; il y a eu échange, donc swapped=1

			noswap:
				inc byte[i]		; i est incrémenté
				mov al,byte[max]	; on copie max dans al
				cmp byte[i],al   	; on compare i et max
				jb boucle_bubble	; si i<max on saute à boucle
	dec byte[max]	; on a un élément bien placé dans le tableau donc un de moins à traiter
	cmp byte[swapped],1
	je bubble		; si swapped=1 (s'il y a eu échange), on saute à bubble pour recommencer

	mov byte[i], 0 ; reset i
	jmp display_array_1



display_array_1:
    mov rdi, display
    movzx rsi, byte[i]
    mov rdx, [array_x+rsi*QWORD]
    mov rax, 0
    call printf

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb display_array_1

    mov byte[i], 0
    jmp init_array_2


init_array_2:
    movzx rsi, byte[i]
    movzx ecx, byte[i]
    rdrand rax
    mov rax, rax
    and rax, 0FFh
    mov [array_y+ecx*QWORD], rax

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb init_array_2

    mov byte[i], 0
    jmp display_array_2



display_array_2:
    mov rdi, display
    movzx rsi, byte[i]
    mov rdx, [array_y+rsi*QWORD]
    mov rax, 0
    call printf

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb display_array_2

    ; display last random point
    mov rdi,last_random_point_print
    mov rsi,[last_point_random_x]
    mov rax,0
    call printf
    ; display last random point
    mov rdi,last_random_point_print
    mov rsi,[last_point_random_y]
    mov rax,0
    call printf

    mov byte[j], 0
    mov byte[k], 0
    jmp jarivs_boucle_1



display_array_3:
    mov rdi, display
    movzx rsi, byte[i]
    movzx rdx, byte[tabindex+rsi*QWORD]
    mov rax, 0
    call printf

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb display_array_3

    mov byte[i], 0

    jmp draw


;##################################################
; JARVIS
;##################################################

jarivs_boucle_1:

    mov rax, [p_index]
    movzx rsi, byte[j]
    mov [tabindex+rsi*QWORD],rax

    ; q = (p+1) mod n
    mov edx, 0
    mov rax, [p_index]
    add rax, 1
    mov [q_index], edx
    mov edx, [q_index]
    mov ecx, NB_POINTS
    div ecx
    mov [q_index], edx


    mov byte[k], 0 ; reset k
    jmp jarivs_boucle_2

    jarivs_boucle_2:

        ;;; yab
        movzx rsi, byte[k]
        mov rax, [array_y+rsi*QWORD]
        movzx rsi, byte[p_index]
        sub rax, [array_y+rsi*QWORD]
        mov [yab], rax
        ;;; xab
        movzx rsi, byte[q_index]
        mov rax, [array_x+rsi*QWORD]
        movzx rsi, byte[k]
        sub rax, [array_x+rsi*QWORD]
        mov [xab], rax
        ;;; xbc
        movzx rsi, byte[k]
        mov rax, [array_x+rsi*QWORD]
        movzx rsi, byte[p_index]
        sub rax, [array_x+rsi*QWORD]
        mov [xbc], rax
        ;;; ybc
        movzx rsi, byte[q_index]
        mov rax, [array_y+rsi*QWORD]
        movzx rsi, byte[k]
        sub rax, [array_y+rsi*QWORD]
        mov [ybc], rax

        ;;; produit vectoriel xbc yab
        mov rax, [yab]
        mov rcx, [xab]
        mul rcx
        mov [result_vectoriel_xbc_yab], rax


        ;;; produit vectoriel xab ybc
        mov rax, [xbc]
        mov rcx, [ybc]
        mul rcx
        mov [result_vectoriel_ybc_xab], rax


        mov rax, [result_vectoriel_xbc_yab]
        mov rdx, [result_vectoriel_ybc_xab]
        cmp rax, rdx
        jb point_is_to_left

        jmp test_is_in_jarvis_point



point_is_to_left:
    movzx rax, byte[k]
    mov [q_index], rax

    jmp test_is_in_jarvis_point

incremente_calcule_jarvis:
    inc byte[k]
    movzx rax, byte[k]
    cmp rax, NB_POINTS
    jb jarivs_boucle_2

    mov rax, [q_index]
    mov [p_index], rax

    inc byte[j]

    mov rax, [p_index]
    cmp rax, 0
    je stop_jarvis


    cmp byte[j], NB_POINTS
    jb stop_jarvis

    jmp jarivs_boucle_1


stop_jarvis:
    mov byte[i], 0

    jmp display_array_3


test_is_in_jarvis_point:
        mov rax, [result_vectoriel_xbc_yab]
        mov rdx, [result_vectoriel_ybc_xab]
        cmp rax, rdx
        ja is_not_in_jarvis_point

        jmp incremente_calcule_jarvis


is_not_in_jarvis_point:
    mov byte[is_to_left], 0

    jmp incremente_calcule_jarvis



;##################################################
; DRAWING
;##################################################
draw:

    xor     rdi,rdi
    call    XOpenDisplay	; Création de display
    mov     qword[display_name],rax	; rax=nom du display

    ; display_name structure
    ; screen = DefaultScreen(display_name);
    mov     rax,qword[display_name]
    mov     eax,dword[rax+0xe0]
    mov     dword[screen],eax

    mov rdi,qword[display_name]
    mov esi,dword[screen]
    call XRootWindow
    mov rbx,rax

    mov rdi,qword[display_name]
    mov rsi,rbx
    mov rdx,10
    mov rcx,10
    mov r8,800	; largeur
    mov r9,800	; hauteur
    push 0xFFFFFF	; background  0xRRGGBB
    push 0x00FF00
    push 1
    call XCreateSimpleWindow
    mov qword[window],rax

    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,131077 ;131072
    call XSelectInput

    mov rdi,qword[display_name]
    mov rsi,qword[window]
    call XMapWindow

    mov rsi,qword[window]
    mov rdx,0
    mov rcx,0
    call XCreateGC
    mov qword[gc],rax

    mov rdi,qword[display_name]
    mov rsi,qword[gc]
    mov rdx,0x000000	; Couleur du crayon
    call XSetForeground

boucle: ; boucle de gestion des évènements
    mov rdi,qword[display_name]
    mov rsi,event
    call XNextEvent

    cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
    je dessin							; on saute au label 'dessin'

    cmp dword[event],KeyPress			; Si on appuie sur une touche
    je closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
    jmp boucle


dessin:

    mov rdi,qword[display_name]
    mov rsi,qword[gc]
    mov edx,0x0000FF
    call XSetForeground


    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]

    movzx rax, byte[i]
    mov rcx, [array_x+rax*QWORD]		; coordonnée en x du point
    sub ecx,3
    mov r8, [array_y+rax*QWORD] 		; coordonnée en y du point
    sub r8,3
    mov r9,6
    mov rax,23040
    push rax
    push 0
    push r9
    call XFillArc

    mov rdi,qword[display_name]
    mov rsi,qword[gc]
    mov edx,0x000000	; Couleur du crayon ; orange
    call XSetForeground
    ; coordonnées de la ligne 1 (noire)
    movzx rbx, byte[i]
    movzx rax, byte[tabindex+rbx*BYTE]  ;
    mov rcx, [array_x+rax*QWORD]
    mov [x1], rcx
    mov rcx, [array_y+rax*QWORD]
    mov [y1], rcx
    movzx rbx, byte[i]
    add rbx, 1
    movzx rax, byte[tabindex+rbx*BYTE]
    mov rcx, [array_x+rax*QWORD]
    mov [x2], rcx
    mov rcx, [array_y+rax*QWORD]
    mov [y2], rcx
    ; dessin de la ligne 1
    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]
    mov ecx,dword[x1]	; coordonnée source en x
    mov r8d,dword[y1]	; coordonnée source en y
    mov r9d,dword[x2]	; coordonnée destination en x
    push qword[y2]		; coordonnée destination en y
    call XDrawLine

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb dessin

    jmp display_last_point_random



flush:
    mov rdi,qword[display_name]
    call XFlush
    jmp boucle
    mov rax,34
    syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit



;##################################################
; DISPLAY LAST POINT RANDOM
;##################################################

display_last_point_random:
    cmp byte[is_to_left], 1
    je display_last_point_random_is_not


    mov rdi,qword[display_name]
    mov rsi,qword[gc]
    mov edx,0x00FF00
    call XSetForeground


    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]
    mov rcx, [last_point_random_x]	; coordonnée en x du point
    sub ecx,3
    mov r8, [last_point_random_y] 		; coordonnée en y du point
    sub r8,3
    mov r9,6
    mov rax,23040
    push rax
    push 0
    push r9
    call XFillArc

    jmp flush


display_last_point_random_is_not:

    mov rdi,qword[display_name]
    mov rsi,qword[gc]
    mov edx,0xFF0000
    call XSetForeground


    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]
    mov rcx, [last_point_random_x]	; coordonnée en x du point
    sub ecx,3
    mov r8,[last_point_random_y] 		; coordonnée en y du point
    sub r8,3
    mov r9,6
    mov rax,23040
    push rax
    push 0
    push r9
    call XFillArc

    jmp flush