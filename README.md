# **Laboratorio 1 de la Unidad 4 — Arquitectura de Computadores**
## Unidad 4 — Lenguaje Ensamblador| Ingeniería de Sistemas 
### Asignatura — Arquitectura de Computadores
**Estudiante:** Andrea Valentina Rivera Fernandez  
**Codigo Estudiante:** 1152444  
**Repositorio:** rivera-post2-u4

## Descripción
Este laboratorio implementa un programa en lenguaje ensamblador NASM que define y utiliza macros con parámetros y etiquetas locales (`%%`), aplica estructuras de control de flujo (bucles con `LOOP` y condicionales con `CMP/Jcc`) y combina estos mecanismos en un programa integrador funcional verificable en DOSBox.

---

## Prerrequisitos

- **DOSBox 0.74** o superior — emulador de entorno DOS de 16 bits  
  Descarga: [dosbox.com](https://www.dosbox.com)
- **NASM (Netwide Assembler) 2.14** o superior  
  El ejecutable `nasm` debe estar en la carpeta de trabajo o en el PATH del sistema
- **Post-Contenido 1 completado** — los fundamentos de secciones, directivas y salida con `INT 21h` deben estar claros
- **Editor de texto plano** — Notepad++, VS Code o similar, con codificación ASCII sin BOM

> **Nota sobre el enlazador (macOS):**  
> La actividad especifica el uso de **ALINK** para generar archivos `.exe`.  
> ALINK no está disponible para macOS — su binario requiere Win32.  
> Como solución equivalente se utilizó el formato **COM de DOS**.  
> Con `nasm -f bin`, NASM actúa como ensamblador y enlazador en un solo paso,  
> generando el binario ejecutable directamente. DOSBox ejecuta `.com` de forma nativa.

---

## Estructura del repositorio

```
rivera-post2-u4/
├── macros.asm         # Biblioteca de macros utilitarias (incluida con %include)
├── programa2.asm      # Programa principal integrador
├── programa2.com      # Binario generado por NASM
├── programa2.lst      # Listado de expansión de macros (generado con -l)
├── README.md          # Este documento
└── capturas/
    ├── captura1_compilacion.png    # Compilación exitosa en DOSBox
    ├── captura2_ejecucion.png      # Salida completa del programa en DOSBox
    └── captura3_listado.png        # Archivo .lst con expansiones de macros
```

---

## Compilación y ejecución

**Paso 1 — Montar la carpeta en DOSBox:**

```
Z:\> mount C ~/doswork/LAB4P02
Z:\> C:
C:\>
```

**Paso 2 — Compilar y generar listado de expansión de macros:**

```
C:\> nasm -f bin programa2.asm -o programa2.com -l programa2.lst
```

El flag `-f bin` genera el binario ejecutable directamente sin enlazador.  
El flag `-l programa2.lst` genera el archivo de listado con las expansiones de cada macro.

**Paso 3 — Ejecutar:**

```
C:\> programa2.com
```

### Salida esperada

```
=== Macros y Control de Flujo ===
[Linea A] Primera impresion
[Linea A] Primera impresion
[Linea A] Primera impresion
[Linea B] Segunda impresion
[Linea B] Segunda impresion
Suma 1+2+3: 6
El valor mayor es: 9
Los valores son iguales.
Fin del programa.
```

---

## Descripción del programa

### `macros.asm` — Biblioteca de macros

Archivo separado incluido en `programa2.asm` mediante `%include "macros.asm"`.  
La directiva `%include` inserta el contenido textualmente antes del ensamblado.

**Macros sin parámetros:**

| Macro | Descripción |
|---|---|
| `fin_dos` | Termina el programa con `INT 21h / 4Ch`, código de salida `00h` |
| `nueva_linea` | Imprime `CR + LF` con `INT 21h / 02h` |
| `leer_char` | Lee un carácter del teclado sin eco con `INT 21h / 07h` |
| `print_digito` | Imprime el nibble bajo de `AL` como dígito ASCII (0–9), preserva `AX` con `PUSH/POP` |

**Macros con parámetros:**

| Macro | Parámetros | Descripción |
|---|---|---|
| `print_str %1` | `%1` = offset de la cadena | Imprime cadena terminada en `$` con `INT 21h / 09h` |
| `print_char %1` | `%1` = valor ASCII | Imprime un carácter con `INT 21h / 02h` |
| `repetir_str %1, %2` | `%1` = cadena, `%2` = veces | Imprime la cadena `%2` veces usando `LOOP` y etiqueta local `%%ciclo` |

La etiqueta `%%ciclo` en `repetir_str` usa el prefijo `%%` de NASM, que genera un nombre único por cada expansión de la macro. Esto permite invocar `repetir_str` múltiples veces en el mismo programa sin colisión de etiquetas.

### `programa2.asm` — Programa integrador

**Flujo de ejecución en `main`:**

1. `print_str titulo` — imprime el encabezado usando la macro
2. `repetir_str linea_a, 3` — imprime `[Linea A]` exactamente 3 veces con bucle interno
3. `repetir_str linea_b, 2` — imprime `[Linea B]` exactamente 2 veces
4. `call sumar_serie` con `CX=3` — calcula `1+2+3=6`, imprime con `print_digito`
5. `call comparar_e_imprimir` con `AX=9, BX=4` — imprime el mayor (`9`)
6. `call comparar_e_imprimir` con `AX=5, BX=5` — imprime mensaje de igualdad
7. `print_str msg_fin` + `fin_dos` — mensaje final y terminación limpia

**Procedimiento `sumar_serie`:**
- Entrada: `CX = N`
- Salida: `AX = 1+2+...+N`
- Usa `LOOP` para decrementar `CX` y acumular en `AX`
- Preserva `CX` con `PUSH/POP` para no alterar el valor original

**Procedimiento `comparar_e_imprimir`:**
- Entrada: `AX` y `BX` (valores 0–9)
- Usa `CMP AX, BX` para actualizar los flags `ZF`, `SF` y `OF`
- `JE` evalúa `ZF=1` → valores iguales
- `JG` evalúa `SF=OF` y `ZF=0` → `AX > BX`
- Si ninguna condición se cumple → `BX` es mayor
- Preserva `AX` y `BX` con `PUSH/POP`

---

## Adaptaciones por uso en macOS

| Aspecto | Guía original | Implementado en macOS |
|---|---|---|
| Formato de salida | `.exe` | `.com` |
| Enlazador | ALINK (`alink.exe`) | No requerido (`-f bin`) |
| Comando de compilación | `nasm -f obj` + `alink` | `nasm -f bin` (un paso) |
| Segmentos | `section .data/.bss/.text` con `@data` | `org 0x100`, un solo bloque |
| Inicialización DS | `mov ax, @data` / `mov ds, ax` | Automática en formato COM |
| Datos no inicializados | `resw 1` | `dw 0` |
| Listado de macros | `nasm -f obj ... -l archivo.lst` | `nasm -f bin ... -l archivo.lst` |

---

## Checkpoints verificados

- ✅ **Checkpoint 1** — Compilación sin errores; archivo `programa2.lst` generado con expansiones de macros visibles
- ✅ **Checkpoint 2** — Ejecución en DOSBox con la salida completa esperada; `LOOP` ejecuta exactamente 3 iteraciones en `sumar_serie` produciendo `6`
- ✅ **Checkpoint 3** — `comparar_e_imprimir` produce salida correcta para `AX>BX` (imprime `9`) y para `AX==BX` (imprime mensaje de igualdad); repositorio con `macros.asm`, `programa2.asm`, `README.md` y capturas con mínimo 3 commits

---

## Historial de commits

```
git commit -m "Agregar README con descripcion, prerrequisitos e instrucciones"
git commit -m "Implementar macros.asm con macros sin parametros y con parametros"
git commit -m "Agregar programa2.asm con sumar_serie, comparar_e_imprimir y main integrador"
git push origin main
```

---

## Referencias

- NASM Manual — https://www.nasm.us/doc/
- DOSBox — https://www.dosbox.com
- INT 21h DOS interrupts — https://stanislavs.org/helppc/int_21.html
- Guía de laboratorio: *Arquitectura de Computadores — Unidad 4, Post-Contenido 2* — UFPS 2026


