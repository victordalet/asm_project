; external functions from X11 library
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

; external functions from stdio library (ld-linux-x86-64.so.2)    
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

    tab1:   resb    10
    tab2:   resb    10
    val:    resb    1
    last_point_random_x : resd 1
    last_point_random_y : resd 1


section .data

    event:		times	24 dq 0

    x1:	dd	0
    x2:	dd	0
    y1:	dd	0
    y2:	dd	0

    i:    db    0
    j:      db 0
    fmt_print:  db  "Dernier Point aléatoire: %d",10,0
    is_to_left: db 1
    last_sense_is: db "Le point (%d,%d) est cp,te,i dans l'enveloppe",10,0
    last_sense_is_not: db "Le point (%d,%d) n'est pas contenu dans l'enveloppe",10,0
    point_max_left_print: db "index max gauche est %d",10,0
    display:  db  "t[%d]=%d",10,0
    min_angle_index: db 0
    last_min_angle_index: db 0
    max:	db	10
    swapped:	db	0
    xab:	db	0
    yab:	db	0
    xbc:	db	0
    ybc:	db	0
    result_vectoriel_xbc_yab:	db	0
    result_vectoriel_ybc_xab:	db	0
    final_result_vectoriel:	db	0

section .text
main:
    push rbp
    jmp init_array_1
	
;##################################################
;########### RANDOM POSTION      ##################
;##################################################
init_array_1:
    ; init last radnom point
    rdrand rax
    mov [last_point_random_x], rax
    rdrand rax
    mov [last_point_random_y], rax
    ; init array

    movzx rsi, byte[i]
    movzx ecx, byte[i]
    rdrand rax
    mov [tab1+ecx*BYTE], rax

    inc byte[i]
    cmp byte[i], 10
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
    cmp byte[i], 10
    jb display_array_1

    mov byte[i], 0 ; reset i
    jmp init_array_2


init_array_2:
    movzx rsi, byte[i]
    movzx ecx, byte[i]
    rdrand rax
    mov [tab2+ecx*BYTE], rax

    inc byte[i]
    cmp byte[i], 10
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
    cmp byte[i], 10
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


    mov byte[i], 0 ; reset i



; en assembleur réinitilise les registre pour le bon fonctionnement du graphic
mov rax,0
mov rbx,0
mov rcx,0
mov rdx,0
mov rsi,0
mov rdi,0
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

;#########################################
;#		DRAW                    		 #
;#########################################
dessin:

    mov rdi,qword[display_name]
    mov rsi,qword[gc]
    mov edx,0x000000
    call XSetForeground


    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]
    movzx rsi, byte[i]
    mov rcx,[tab1+rsi*BYTE]		; coordonnée en x du point
    sub ecx,3
    mov r8,[tab2+rsi*BYTE] 		; coordonnée en y du point
    sub r8,3
    mov r9,6
    mov rax,23040
    push rax
    push 0
    push r9
    call XFillArc

    mov rdi,qword[display_name]
    call XFlush

    inc byte[i]
    cmp byte[i], 10
    jb dessin

    jmp flush

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
;########### JARVIS      ##################
;##################################################
	
jarivs_boucle_1:

    jmp jarivs_boucle_2
    mov byte[j], 0 ; reset

    jarivs_boucle_2:

        ;;; xab
        movzx rsi, byte[last_min_angle_index]
        movzx rax, byte[tab1+rsi*BYTE]
        movzx rsi, byte[j]
        sub rax, [tab1+rdx*BYTE]
        mov [xab], rax

        ;;; yab
        movzx rsi, byte[last_min_angle_index]
        movzx rax, byte[tab2+rsi*BYTE]
        movzx rsi, byte[j]
        sub rax, [tab2+rsi*BYTE]
        mov [yab], rax

        ;;; xbc
        movzx rsi, byte[last_min_angle_index]
        movzx rax, byte[tab1+rsi*BYTE]
        movzx rsi, byte[j]
        add rsi, 1
        sub rax, [tab1+rsi*BYTE]
        mov [xbc], rax

        ;;; ybc
        movzx rsi, byte[last_min_angle_index]
        movzx rax, byte[tab2+rsi*BYTE]
        movzx rsi, byte[j]
        add rsi, 1
        sub rax, [tab2+rdx*BYTE]
        mov [ybc], rax

        ;;; produit vectoriel xbc yab
        movzx rsi, byte[xbc]
        movzx rdx, byte[yab]
        imul rsi, rdx
        mov byte[result_vectoriel_xbc_yab], sil

        ;;; produit vectoriel xab ybc
        movzx rsi, byte[xab]
        movzx rdx, byte[ybc]
        imul rsi, rdx
        mov byte[result_vectoriel_ybc_xab], sil

        ;;; final result vectoriel
        movzx rsi, byte[result_vectoriel_xbc_yab]
        movzx rdx, byte[result_vectoriel_ybc_xab]
        sub sil, dil
        mov byte[final_result_vectoriel], sil


        cmp byte[final_result_vectoriel], 0
        jne point_is_to_left

        jmp point_is_to_right

        point_is_to_right:
            movzx rax, byte[j]
            mov [min_angle_index], rax
            jmp verify_point_is_in_convex_hull

        point_is_to_left:
            movzx rax, byte[j]
            add rax, 1
            mov [min_angle_index], rax
            jmp verify_point_is_in_convex_hull


        ;couleur de la ligne
        ;mov rdi,qword[display_name]
        ;mov rsi,qword[gc]
        ;mov edx,0x000000	; Couleur du crayon ; noir
        ;call XSetForeground
        ; coordonnées de la ligne 1 (noire)
        ;movzx rsi, byte[last_min_angle_index]
        ;mov dword[x1],[tab1+rsi*BYTE]
        ;mov dword[y1],[tab2+rsi*BYTE]
        ;movzx rsi, byte[min_angle_index]
        ;mov dword[x2],[tab1+rsi*BYTE]
        ;mov dword[y2],[tab2+rsi*BYTE]
        ; TODO: CORRGOER L'ERREUR
        ; dessin de la ligne 1
        ;mov rdi,qword[display_name]
        ;mov rsi,qword[window]
        ;mov rdx,qword[gc]
        ;mov ecx,dword[x1]	; coordonnée source en x
        ;mov r8d,dword[y1]	; coordonnée source en y
        ;mov r9d,dword[x2]	; coordonnée destination en x
        ;push qword[y2]		; coordonnée destination en y
        ;call XDrawLine
        ;;;


        mov rax, [min_angle_index]
        mov [last_min_angle_index], rax

        jmp verify_point_is_in_convex_hull




verify_point_is_in_convex_hull:
    mov rax, [final_result_vectoriel]
    cmp rax, 0
    jb modify_point_is_in_convex_hull



    inc byte[j]
    cmp byte[j], 9
    jb jarivs_boucle_2


    inc byte[i]
    cmp byte[i], 10
    jmp jarivs_boucle_1

    jmp display_last_point_random


modify_point_is_in_convex_hull:
    mov byte[is_to_left], 1

    inc byte[j]
    cmp byte[j], 9
    jb jarivs_boucle_2


    inc byte[i]
    cmp byte[i], 10
    jmp jarivs_boucle_1

    jmp display_last_point_random

;##################################################
;########### LAST POINT RANDOM   ##################
;##################################################

display_last_point_random:
    cmp byte[is_to_left], 1
    jne display_last_point_random_is_not


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

    mov rdi,last_sense_is
    movzx rsi,byte[last_point_random_x]
    movzx rdx,byte[last_point_random_y]
    mov rax,0
    call printf


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

    mov rdi,last_sense_is_not
    movzx rsi,byte[last_point_random_x]
    movzx rdx,byte[last_point_random_y]
    mov rax,0
    call printf