section .text
global _start

_start:
; Se define un segmento de datos llamado "data_segment"
data_segment:
    db "This is some data"

; Cambia los bits de acceso del segmento de datos a solo lectura
mov eax, 0x0f            ; Setea EAX en el numero de registro de control
mov ecx, data_segment    ; Setea ECX a la direccion del segmento de datos
mov ebx, 0x02            ; Setea EBX en la mascara de bits de solo lectura
mov [ecx], ebx           ; Escribe la mascara de bits en el registro de control

; Se intenta escribir en el segmento de datos
mov eax, 0x61            ; Setea EAX con el valor a escribir
mov ebx, data_segment    ; Setea EBX con la direccion del segmento de datos
mov [ebx], eax           ; Intento escribir el valor en el segmento de datos

; Muestra un mensaje indicando que los datos fueron modificados
mov eax, 4           ; Setea EAX el de llamada de sistema para escribir en stdout
mov ebx, data_segment ; Setea EBX en la direccion de los datos
mov ecx, 16            ; Setea ECX con el numero de bytes a escribir
mov edx, 0           ; Setea EDX en el descriptor de archivo de salida (1 para stdout)
int 0x80              ; Genera la llamada de sistema

; Sale del programa
mov eax, 1           ; Setea EAX con el numero de llamada de sistema para salir
int 0x80              ; Genera la llamada de sistema

