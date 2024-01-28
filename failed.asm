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

global main

section .data
dispaly:  db  "t[%d]=%d",10,0
i:    db    0
j:      db 0
event:		times	24 dq 0
fmt_print:  db  "Dernier Point aléatoire: %d",10,0
is_to_left: db 1
last_sense_is: db "Le point (%d,%d) est cp,te,i dans l'enveloppe",10,0
last_sense_is_not: db "Le point (%d,%d) n'est pas contenu dans l'enveloppe",10,0
point_max_left: db 100
point_max_left_print: db "Le point le plus à gauche est %d",10,0
min_angle: db 0
min_angle_index: db 0
x1:	dd	0
x2:	dd	0
y1:	dd	0
y2:	dd	0



section .bss
tab1:   resb    10
tab2:   resb    10
val:    resb    1
display_name:	resq	1
screen:			resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1
last_point_random_x : resd 1
last_point_random_y : resd 1

section .text
main:
push rbp

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


display_array_1:
    mov rdi, dispaly
    movzx rsi, byte[i]
    movzx rdx, byte[tab1+rsi*BYTE]
    mov rax, 0
    call printf

    inc byte[i]
    cmp byte[i], 10
    jb display_array_1

mov byte[i], 0 ; reset i


init_array_2:
    movzx rsi, byte[i]
    movzx ecx, byte[i]
    rdrand rax
    mov [tab2+ecx*BYTE], rax

    inc byte[i]
    cmp byte[i], 10
    jb init_array_2


mov byte[i], 0 ; reset i


display_array_2:
    mov rdi, dispaly
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

get_point_max_left:
    movzx rsi, byte[i]

    mov eax, [tab1+rsi*BYTE]
    cmp [point_max_left], eax
    jae change_point_max_left

    inc byte[i]
    cmp byte[i], 10
    jb get_point_max_left

    jmp display_point_max_left

    ;; TODO: CORRIGER L'ALGO

change_point_max_left:
    mov eax, [tab1+rsi*BYTE]
    mov [point_max_left], eax

    inc byte[i]
    cmp byte[i], 10
    jb get_point_max_left

    jmp display_point_max_left


display_point_max_left:
    mov rdi,point_max_left_print
    movzx rsi,byte[point_max_left]
    mov rax,0
    call printf



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
je draw_all_point

cmp dword[event],KeyPress			; Si on appuie sur une touche
je closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp boucle

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw_all_point:
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


    inc byte[i]
    cmp byte[i], 10
    jb draw_all_point

    jmp jarivs_boucle_1


jarivs_boucle_1:

    jmp jarivs_boucle_2
    mov byte[j], 0 ; reset



jarivs_boucle_2:

    ; TODO : calculer
    ; TODO : si c'est positif, alors le point est à gauche, sinon il est à droite
    ; TODO : stocker le résultat dans la variable min_angle et l'index dans la variable min_angle_index


    ;;;
    ;couleur de la ligne 1
    mov rdi,qword[display_name]
    mov rsi,qword[gc]
    mov edx,0x000000	; Couleur du crayon ; noir
    call XSetForeground
    ; coordonnées de la ligne 1 (noire)
    movzx rsi, byte[i]
    ;mov dword[x1],[tab1+rsi*BYTE]
    ;mov dword[y1],[tab2+rsi*BYTE]
    movzx rsi, byte[min_angle_index]
    ;mov dword[x2],[tab1+rsi*BYTE]
    ;mov dword[y2],[tab2+rsi*BYTE]
    ; TODO: CORRGOER L'ERREUR
    ; dessin de la ligne 1
    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]
    mov ecx,dword[x1]	; coordonnée source en x
    mov r8d,dword[y1]	; coordonnée source en y
    mov r9d,dword[x2]	; coordonnée destination en x
    push qword[y2]		; coordonnée destination en y
    call XDrawLine
    ;;;

    jmp verify_point_is_in_convex




verify_point_is_in_convex:
    ; TODO : vérifier si le point est dans l'enveloppe convexe

    inc byte[j]
    cmp byte[j], 10
    jb jarivs_boucle_2


    inc byte[i]
    cmp byte[i], 10
    jmp jarivs_boucle_1

    jmp display_last_point_random



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

    mov rdi,last_sense_is_not
    movzx rsi,byte[last_point_random_x]
    movzx rdx,byte[last_point_random_y]
    mov rax,0
    call printf
    jmp flush



pop rbp
mov rax, 60
mov rdi, 0
syscall
ret