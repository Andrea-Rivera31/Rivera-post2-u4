; programa2.asm — Laboratorio Post2 Unidad 4
; Asignatura: Arquitectura de Computadores
; Propósito: Demostrar macros con parámetros, etiquetas locales,
;            bucles con LOOP y condicionales con CMP/Jcc
;
; COMPILACIÓN (un solo comando, sin enlazador):
;   nasm -f bin programa2.asm -o programa2.com
;
; LISTADO de expansión de macros (genera programa2.lst):
;   nasm -f bin programa2.asm -o programa2.com -l programa2.lst
;
; EJECUCIÓN dentro de DOSBox:
;   programa2.com

; ===========================================================================
; INCLUIR BIBLIOTECA DE MACROS
; ===========================================================================

%include "macros.asm"       ; inserta macros.asm textualmente aquí

; ===========================================================================
; CONFIGURACIÓN FORMATO COM
; ===========================================================================

bits 16
org  0x100                  ; los programas COM inician en offset 0x100
                            ; DS ya apunta al segmento correcto — no se toca

; ===========================================================================
; CÓDIGO — punto de entrada (va primero en formato COM)
; ===========================================================================

main:
    ; ── 1. Imprimir encabezado usando macro print_str ─────────────────────
    print_str titulo        ; expansión: mov ah,09h / mov dx,titulo / int 21h

    ; ── 2. Demostración de macro repetir_str con etiquetas locales (%%) ───
    ; repetir_str usa %%ciclo internamente — cada invocación genera una
    ; etiqueta única, lo que permite llamar la macro múltiples veces
    repetir_str linea_a, 3  ; imprime linea_a exactamente 3 veces
    repetir_str linea_b, 2  ; imprime linea_b exactamente 2 veces

    ; ── 3. Suma acumulativa 1+2+3 = 6 usando CALL/RET y LOOP ─────────────
    print_str msg_suma      ; imprimir etiqueta "Suma 1+2+3: "
    mov  cx, 3              ; N = 3 → sumar 1+2+3
    call sumar_serie        ; resultado en AX = 6
    print_digito            ; macro: imprime nibble bajo de AX → '6'
    nueva_linea             ; macro: CR + LF

    ; ── 4. Comparar 9 vs 4 → mayor es 9 ──────────────────────────────────
    mov  ax, 9
    mov  bx, 4
    call comparar_e_imprimir

    ; ── 5. Comparar 5 vs 5 → iguales ─────────────────────────────────────
    mov  ax, 5
    mov  bx, 5
    call comparar_e_imprimir

    ; ── 6. Mensaje final y terminación ────────────────────────────────────
    print_str msg_fin       ; macro: imprime mensaje de fin
    fin_dos                 ; macro: mov ax,4C00h / int 21h

; ===========================================================================
; PROCEDIMIENTO: sumar_serie
; Propósito: calcula la suma acumulativa 1+2+3+...+N
; Entrada:   CX = N (número de términos a sumar)
; Salida:    AX = resultado de la suma (1+2+...+N)
; Modifica:  AX (resultado), preserva CX mediante PUSH/POP
; Ejemplo:   CX=3 → AX=6 (1+2+3), CX=4 → AX=10 (1+2+3+4)
; ===========================================================================

sumar_serie:
    push cx                 ; preservar CX — LOOP lo decrementa hasta 0
    xor  ax, ax             ; AX = 0 (inicializar acumulador)
.paso:
    add  ax, cx             ; AX += CX (suma N, luego N-1, ..., hasta 1)
    loop .paso              ; CX--; si CX != 0, repetir
    pop  cx                 ; restaurar CX original
    ret                     ; retornar con AX = suma total

; ===========================================================================
; PROCEDIMIENTO: comparar_e_imprimir
; Propósito: compara AX y BX e imprime cuál es mayor o si son iguales
; Entrada:   AX = primer valor (0-9), BX = segundo valor (0-9)
; Salida:    imprime en pantalla el resultado de la comparación
; Modifica:  AH, DX (uso interno para INT 21h)
; Preserva:  AX y BX mediante PUSH/POP
; Flags usados: ZF (igualdad), SF y OF (comparación con signo vía JG/JL)
; ===========================================================================

comparar_e_imprimir:
    push ax                 ; preservar AX
    push bx                 ; preservar BX

    cmp  ax, bx             ; AX - BX → actualiza ZF, SF, OF (no modifica AX/BX)
    je   .son_iguales       ; si ZF=1 → AX == BX
    jg   .ax_mayor          ; si ZF=0 y SF=OF → AX > BX con signo

    ; ── Caso: BX es mayor (ninguna condición anterior se cumplió) ─────────
    print_str msg_mayor     ; imprimir etiqueta "El valor mayor es: "
    mov  al, bl             ; AL = valor de BX (para print_digito)
    print_digito            ; imprimir dígito de BX
    nueva_linea
    jmp  .fin_comp          ; saltar al final del procedimiento

.ax_mayor:
    ; ── Caso: AX es mayor ─────────────────────────────────────────────────
    print_str msg_mayor     ; imprimir etiqueta "El valor mayor es: "
    ; AX sigue en la pila pero AL todavía contiene el valor original de AX
    ; (CMP no modifica AX, y push guardó el valor original)
    pop  bx                 ; restaurar BX temporalmente para liberar pila
    pop  ax                 ; restaurar AX — AL = valor original de AX
    push ax                 ; volver a apilar para el pop final de .fin_comp
    push bx
    print_digito            ; imprimir nibble bajo de AX
    nueva_linea
    jmp  .fin_comp

.son_iguales:
    ; ── Caso: AX == BX ────────────────────────────────────────────────────
    print_str msg_iguales   ; imprimir "Los valores son iguales."

.fin_comp:
    pop  bx                 ; restaurar BX
    pop  ax                 ; restaurar AX
    ret

; ===========================================================================
; DATOS — van después del código en un programa COM
; ===========================================================================

; Cadenas de texto (terminadas en '$' = 24h para INT 21h / función 09h)
titulo    db "=== Macros y Control de Flujo ===", 0Dh, 0Ah, 24h
linea_a   db "[Linea A] Primera impresion", 0Dh, 0Ah, 24h
linea_b   db "[Linea B] Segunda impresion", 0Dh, 0Ah, 24h
msg_suma  db "Suma 1+2+3: ", 24h
msg_mayor db "El valor mayor es: ", 24h
msg_iguales db "Los valores son iguales.", 0Dh, 0Ah, 24h
msg_fin   db "Fin del programa.", 0Dh, 0Ah, 24h

; Espacio reservado (equivalente a .bss en formato COM)
valor_a   dw 0              ; word reservado — equivalente a resw 1
valor_b   dw 0              ; word reservado — equivalente a resw 1