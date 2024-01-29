##################################################
;########### JARVIS              ##################
;##################################################

jarivs_boucle_1:

    jmp jarivs_boucle_2

    jarivs_boucle_2:

        ; ne pas prendre en compte le point lui même
        movzx rsi, byte[i]
        movzx rax, byte[j]
        cmp rax, rsi
        jne verify_point_is_in_convex

        ;;; xab
        movzx rsi, byte[last_min_angle_index]
        movzx rax, byte[tab1+rsi*BYTE]
        movzx rsi, byte[j]
        sub rax, [tab1+rsi*BYTE]
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
        sub rax, [tab2+rsi*BYTE]
        mov [ybc], rax

        ;;; produit vectoriel xbc yab
        movzx rsi, byte[xbc]
        movzx rdx, byte[yab]
        mul rdx
        mov [result_vectoriel_xbc_yab], rsi

        ;;; produit vectoriel xab ybc
        movzx rsi, byte[xab]
        movzx rdx, byte[ybc]
        mul rdx
        mov [result_vectoriel_ybc_xab], rsi


        mov rax, [result_vectoriel_xbc_yab]
        mov rdx, [result_vectoriel_ybc_xab]
        cmp rax, rdx
        ja point_is_to_left

        jmp verify_point_is_in_convex


point_is_to_left:
    mov rax, [j]
    mov [min_angle_index], rax

    movzx rsi, byte[i]
    mov [tabindex+rsi*BYTE], rax
    jmp verify_point_is_in_convex


verify_point_is_in_convex:
    mov rax, [final_result_vectoriel]
    cmp rax, 0
    jb modify_point_is_in_convex_hull


    mov rax, [j]
    add rax, 2
    mov [j], rax
    cmp byte[j], NB_POINTS
    jb jarivs_boucle_2

    mov byte[j], 0 ; reset j
    inc byte[i]
    cmp byte[i], NB_POINTS
    jb jarivs_boucle_1

    mov byte[i], 0 ; reset i
    jmp display_array_3


modify_point_is_in_convex_hull:
    mov byte[is_to_left], 1

    mov rax, [j]
    add rax, 2
    mov [j], rax
    cmp byte[j], NB_POINTS
    jb jarivs_boucle_2

    mov byte[j], 0 ; reset j
    inc byte[i]
    cmp byte[i], NB_POINTS
    jb jarivs_boucle_1

    mov byte[i], 0 ; reset i
    jmp display_array_3
