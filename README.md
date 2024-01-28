# ASM PROJECT

---

## Compilation

---

```bash
./compile main.asm
```

## Doc

---

### Generate random number

---

```bash
rdrand rax
```

### Display point

---

```bash
mov rdi,qword[display_name]
mov rsi,qword[gc]
mov edx,0xFF0000	; Couleur du crayon ; rouge
call XSetForeground

; Dessin d'un point rouge sous forme d'un petit rond : coordonnées (100,200)
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov rcx,100		; coordonnée en x du point
sub ecx,3
mov r8,200 		; coordonnée en y du point
sub r8,3
mov r9,6
mov rax,23040
push rax
push 0
push r9
call XFillArc
```

### Display line

---

```bash
mov rdi,qword[display_name]
mov rsi,qword[gc]
mov edx,0x000000	; Couleur du crayon ; noir
call XSetForeground
; coordonnées de la ligne 1 (noire)
mov dword[x1],50
mov dword[y1],50
mov dword[x2],200
mov dword[y2],350
; dessin de la ligne 1
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,dword[x1]	; coordonnée source en x
mov r8d,dword[y1]	; coordonnée source en y
mov r9d,dword[x2]	; coordonnée destination en x
push qword[y2]		; coordonnée destination en y
call XDrawLine
```