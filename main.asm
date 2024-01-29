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
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1
%define NB_POINTS 30

global main

section .bss
    display_name:	resq	1
    screen:			resd	1
    depth:         	resd	1
    connection:    	resd	1
    width:         	resd	1
    height:        	resd	1
    window:		resq	1
    gc:		resq	1

    tab1:   resb   NB_POINTS
    tab2:   resb    NB_POINTS
    tabindex:   resb    NB_POINTS
    val:    resb    1
    last_point_random_x : resd 1
    last_point_random_y : resd 1
    xab:                    resd 1
    yab:                    resd 1
    xbc:                    resd 1
    ybc:                    resd 1



section .data

    event:		times	24 dq 0

    x1:	dd	0
    x2:	dd	0
    y1:	dd	0
    y2:	dd	0

    i:    db    0
    j:      db 0
    k:      db 0
    fmt_print:  db  "Dernier Point aléatoire: %d",10,0
    is_to_left: db 1
    last_sense_is: db "Le point (%d,%d) est cp,te,i dans l'enveloppe",10,0
    last_sense_is_not: db "Le point (%d,%d) n'est pas contenu dans l'enveloppe",10,0
    point_max_left_print: db "index max gauche est %d",10,0
    result_vectoriel_print: db "result vectoriel est %d",10,0
    display:  db  "t[%d]=%d",10,0
    min_angle_index: db 0
    last_min_angle_index: db 0
    max:	db	10
    swapped:	db	0
    result_vectoriel_xbc_yab:	db	0
    result_vectoriel_ybc_xab:	db	0
    final_result_vectoriel:	db	0
    p:    db	0
    q:    db	0
    l:   db	0

section .text
main:
    push rbp
    jmp init_array_1
	
;##################################################
;########### RANDOM POSTION      ##################
;##################################################
init_array_1:
    ; init last radnom point
    mov [last_point_random_x], rax
    rdrand rax
    mov [last_point_random_y], rax
    ; init array

    movzx rsi, byte[i]
    movzx ecx, byte[i]
    rdrand rax
    mov [tab1+ecx*BYTE], rax

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb init_array_1

    mov byte[i], 0 ; reset i
    jmp bubble



bubble:
		mov byte[swapped],0	; variable indiquant s'il y a eu échange de valeurs (si oui, swapped=1)
		mov byte[i],1	; i=compteur de boucle
		boucle_bubble:
			movzx ebx,byte[i]		; ebx=i
			mov cl,byte[tab1+ebx*BYTE]	; cl=tab[i]
			dec ebx				; ebx=i-1
			mov dl,byte[tab1+ebx*BYTE] 	; dl=tab[i-1]
			cmp cl,dl
		jae noswap ; si cl>=dl, pas d'échange : saut à noswap

			;Echange
			mov byte[tab1+ebx*BYTE],cl	; tab[i-1]=tab[i]
			inc ebx	; ebx=i
			mov byte[tab1+ebx*BYTE],dl	; tab[i]=tab[i-1]
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
    movzx rdx, byte[tab1+rsi*BYTE]
    mov rax, 0
    call printf

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb display_array_1

    mov byte[i], 0 ; reset i
    jmp init_array_2


init_array_2:
    movzx rsi, byte[i]
    movzx ecx, byte[i]
    rdrand rax
    mov [tab2+ecx*BYTE], rax

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb init_array_2

    mov byte[i], 0 ; reset i
    jmp display_array_2




display_array_2:
    mov rdi, display
    movzx rsi, byte[i]
    movzx rdx, byte[tab2+rsi*BYTE]
    mov rax, 0
    call printf

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb display_array_2

    ; display last random point
    mov rdi,fmt_print
    movzx rsi,byte[last_point_random_x]
    mov rax,0
    call printf
    ; display last random point
    mov rdi,fmt_print
    movzx rsi,byte[last_point_random_y]
    mov rax,0
    call printf

    mov byte[j], 0 ; reset j
    mov byte[p], 0 ; reset p
    mov byte[q], 0 ; reset q

    jmp jarivs_boucle_1


;##################################################
;########### JARVIS              ##################
;##################################################

jarivs_boucle_1:

    mov rax, [p]
    movzx rsi, byte[j]
    mov [tabindex+rsi*BYTE],rax

    ; q = (p+1) mod n
    mov edx, 0
    mov rax, [p]
    add rax, 1
    mov [q], edx
    mov edx, [q]
    mov ecx, NB_POINTS
    div ecx
    mov [q], edx


    mov byte[k], 0 ; reset k
    jmp jarivs_boucle_2

    jarivs_boucle_2:


        ;;; yab
        movzx rsi, byte[k]
        movzx rax, byte[tab2+rsi*BYTE]
        movzx rsi, byte[p]
        sub rax, [tab2+rsi*BYTE]
        mov [yab], rax
        ;;; xab
        movzx rsi, byte[q]
        movzx rax, byte[tab1+rsi*BYTE]
        movzx rsi, byte[k]
        sub rax, [tab1+rsi*BYTE]
        mov [xab], rax
        ;;; xbc
        movzx rsi, byte[k]
        movzx rax, byte[tab1+rsi*BYTE]
        movzx rsi, byte[p]
        sub rax, [tab1+rsi*BYTE]
        mov [xbc], rax
        ;;; ybc
        movzx rsi, byte[q]
        movzx rax, byte[tab2+rsi*BYTE]
        movzx rsi, byte[k]
        sub rax, [tab2+rsi*BYTE]
        mov [ybc], rax

        ;;; produit vectoriel xbc yab
        movzx rax, byte[yab]
        movzx rcx, byte[xab]
        mul rcx
        mov [result_vectoriel_xbc_yab], rax

        ;;; produit vectoriel xab ybc
        movzx rax, byte[xbc]
        movzx rcx, byte[ybc]
        mul rcx
        mov [result_vectoriel_ybc_xab], rax

        mov rdi,fmt_print
        movzx rsi,byte[yab]
        mov rax,0
        call printf

        mov rdi,fmt_print
        movzx rsi,byte[xab]
        mov rax,0
        call printf

        mov rdi,fmt_print
        movzx rsi,byte[result_vectoriel_xbc_yab]
        mov rax,0
        call printf


        mov rax, [result_vectoriel_xbc_yab]
        mov rdx, [result_vectoriel_ybc_xab]
        cmp rax, rdx
        jb point_is_to_left

        jmp incremente_calcule_jarvis



point_is_to_left:
    mov rax, [k]
    mov [q], rax

    jmp incremente_calcule_jarvis

incremente_calcule_jarvis:
    inc byte[k]
    mov rax, [k]
    cmp rax, NB_POINTS
    jb jarivs_boucle_2

    mov rax, [q]
    mov [p], rax

    inc byte[j]

    cmp byte[p], 0
    je stop_jarvis

    jmp jarivs_boucle_1


stop_jarvis:
    mov byte[i], 0 ; reset i
    mov byte[j], 0 ; reset j
    mov byte[k], 0 ; reset k
    mov byte[p], 0 ; reset p
    mov byte[q], 0 ; reset q

    jmp display_array_3

display_array_3:

    mov rdi, display
    movzx rsi, byte[i]
    movzx rdx, byte[tabindex+rsi*BYTE]
    mov rax, 0
    call printf

    inc byte[i]
    cmp byte[i], NB_POINTS
    jb display_array_3

    mov byte[i], 0 ; reset i
    ;reset register
    mov rax, 0
    mov rdx, 0
    mov rcx, 0
    mov rsi, 0



;##################################################
;########### DISPLAY            ##################
;##################################################

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
mov r8,400	; largeur
mov r9,400	; hauteur
push 0xFFFFFF	; background  0xRRGGBB
push 0x00FF00
push 1
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
    mov edx,0x000000
    call XSetForeground


    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]

    movzx rax, byte[i]
    mov rcx, [tab1+rax*BYTE]		; coordonnée en x du point : TODO : le point ne s'affiche pas correctement
    sub ecx,3
    mov r8, [tab2+rax*BYTE] 		; coordonnée en y du point
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
    movzx rax, byte[tabindex+rbx*BYTE]  ; TODO : verifier que la ligne se dessine bien
    mov rcx, [tab1+rax*BYTE]
    mov [x1], rcx
    mov rcx, [tab2+rax*BYTE]
    mov [y1], rcx
    movzx rbx, byte[i]
    add rbx, 1
    movzx rax, byte[tabindex+rbx*BYTE]
    mov rcx, [tab1+rax*BYTE]
    mov [x2], rcx
    mov rcx, [tab2+rax*BYTE]
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
;########### LAST POINT RANDOM   ##################
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
    mov r8,[last_point_random_y] 		; coordonnée en y du point
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