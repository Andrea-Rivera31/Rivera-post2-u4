; macros.asm — Biblioteca de macros utilitarias
; Laboratorio Post2 Unidad 4 — Arquitectura de Computadores
; Formato: incluido via %include en programa2.asm (formato COM, 16 bits)
; NOTA: No compilar este archivo directamente — es incluido por programa2.asm

; ===========================================================================
; MACROS SIN PARÁMETROS
; ===========================================================================

; Macro: terminar programa DOS con código de salida 0
; Uso: fin_dos
; Expande: mov ax, 4C00h / int 21h
%macro fin_dos 0
    mov  ax, 4C00h          ; AH=4Ch terminar | AL=00h código de salida 0
    int  21h
%endmacro

; Macro: imprimir nueva línea (CR + LF)
; Uso: nueva_linea
; Expande: dos llamadas a INT 21h / función 02h
%macro nueva_linea 0
    mov  ah, 02h
    mov  dl, 0Dh            ; Carriage Return
    int  21h
    mov  ah, 02h
    mov  dl, 0Ah            ; Line Feed
    int  21h
%endmacro

; Macro: imprimir cadena terminada en '$' (24h)
; Uso: print_str etiqueta
; %1 = etiqueta/offset de la cadena en memoria
%macro print_str 1
    mov  ah, 09h            ; función DOS: imprimir cadena hasta '$'
    mov  dx, %1             ; DX = offset de la cadena
    int  21h
%endmacro

; Macro: imprimir un carácter único
; Uso: print_char valor
; %1 = valor ASCII del carácter (inmediato o registro de 8 bits)
%macro print_char 1
    mov  ah, 02h            ; función DOS: imprimir carácter en DL
    mov  dl, %1             ; DL = carácter a imprimir
    int  21h
%endmacro

; Macro: leer un carácter desde teclado (sin eco en pantalla)
; Uso: leer_char
; Resultado queda en AL después de la expansión
%macro leer_char 0
    mov  ah, 07h            ; función DOS: entrada sin eco
    int  21h                ; AL = carácter leído
%endmacro

; ===========================================================================
; MACROS CON PARÁMETROS
; ===========================================================================

; Macro: imprimir una cadena N veces usando bucle interno
; Uso: repetir_str etiqueta, cantidad
; %1 = etiqueta/offset de la cadena a imprimir
; %2 = número de repeticiones (valor inmediato numérico)
; Etiqueta local %%ciclo evita colisión cuando la macro se invoca varias veces
%macro repetir_str 2
    mov  cx, %2             ; CX = número de repeticiones
%%ciclo:                    ; %% genera etiqueta única por cada expansión
    mov  ah, 09h            ; función DOS: imprimir cadena
    mov  dx, %1             ; DX = offset de la cadena
    int  21h
    loop %%ciclo            ; CX--; si CX != 0, repetir
%endmacro

; Macro: imprimir el dígito decimal del nibble bajo de AL (valores 0-9)
; Uso: print_digito  (AL debe contener el valor antes de invocar)
; Preserva AX mediante PUSH/POP para no alterar el acumulador
%macro print_digito 0
    push ax                 ; preservar AX completo
    and  al, 0Fh            ; aislar nibble bajo (garantiza rango 0-9)
    add  al, 30h            ; convertir a ASCII: 0→'0', 9→'9'
    mov  ah, 02h            ; función DOS: imprimir carácter
    mov  dl, al             ; DL = dígito ASCII
    int  21h
    pop  ax                 ; restaurar AX original
%endmacro