# Trabajo Práctico Nº3 - Protected Mode

**Materia:** Sistemas de Computación  
**Profesor:** Jorge, Javier Alejandro  
**Grupo:** Overclocked minds  

## Integrantes:
- **Luna Fernando Valentino** - 43612136  
- **Recchini Fabrizio Andrés** - 41440569  
- **Villane Santiago** - 39421319  

---

## Introducción

En los niveles más fundamentales de una computadora, existen mecanismos y estructuras esenciales que permiten la inicialización del sistema, la gestión de la memoria y el control de los privilegios de ejecución. Estos elementos, aunque invisibles para el usuario final, son clave para garantizar que el hardware y el software funcionen de manera coordinada y segura.

Desde los primeros momentos del arranque del sistema, donde intervienen tecnologías como la BIOS, UEFI o firmwares alternativos como Coreboot, hasta el cambio entre modos de operación del procesador como el modo real y el modo protegido, se ponen en marcha procesos altamente estructurados que habilitan el entorno operativo moderno. En este marco también se insertan conceptos como la segmentación de memoria, el uso de tablas de descriptores como la GDT y los esquemas de privilegios representados por los anillos de seguridad.

La arquitectura x86 se caracteriza por mantener una fuerte compatibilidad con sus generaciones anteriores, lo que ha influido directamente en el diseño de sus modos de operación. Para asegurar esta compatibilidad hacia atrás (backward compatibility), todos los procesadores x86 inician su funcionamiento en el denominado modo real al momento del arranque (boot time). En esta fase inicial, el CPU opera en un estado básico y limitado, replicando el comportamiento del Intel 8086, lo cual permite ejecutar código heredado y garantizar la interoperabilidad con sistemas antiguos.

Sin embargo, una vez energizado, el procesador tiene la capacidad de evolucionar gradualmente hacia modos más avanzados mediante configuraciones específicas. Uno de estos modos es el modo protegido, introducido a partir de la familia 80286. Este representa el primer salto evolutivo significativo en la arquitectura x86, al incorporar características orientadas a la multitarea, la estabilidad del sistema y la seguridad del entorno de ejecución. Entre sus mejoras destacan la protección de memoria, el soporte de hardware para memoria virtual y la conmutación de tareas de forma eficiente y segura.

## Desafío: UEFI y coreboot

### 1. ¿Qué es UEFI? ¿Cómo puedo usarlo? Mencionar además una función a la que podría llamar usando esa dinámica.

UEFI (Unified Extensible Firmware Interface) es una interfaz de firmware moderna que reemplaza al antiguo BIOS. Su función principal es inicializar el hardware durante el arranque y pasar el control al sistema operativo. A diferencia del BIOS, UEFI ofrece una interfaz gráfica, soporte para discos duros grandes (GPT), arranque seguro (Secure Boot), y mayor flexibilidad en extensiones de firmware.

Se puede usar accediendo al menú de configuración durante el inicio del sistema (usualmente presionando teclas como F2, Supr o Esc). También se puede interactuar con él desde un sistema operativo mediante herramientas como efibootmgr en Linux o comandos en PowerShell como bcdedit.

Una función que se puede llamar en este entorno es la de modificación del orden de arranque (boot order), que permite elegir desde qué dispositivo iniciar (disco, USB, red, etc.).

### 2. ¿Menciona casos de bugs de UEFI que puedan ser explotados?

Algunas vulnerabilidades reportadas en UEFI son:

- MoonBounce (2022): un malware persistente detectado por Kaspersky que se aloja en el firmware UEFI, lo que le permite sobrevivir incluso a formateos del sistema.

- LoJax: el primer rootkit UEFI en ser utilizado activamente en ataques reales, descubierto en 2018. Fue utilizado por el grupo APT28 para comprometer sistemas a nivel de firmware.

- Pixie Dust Attack: si bien no afecta directamente a UEFI, explota configuraciones débiles de arranque seguro y puede facilitar ataques a través del firmware.

- LogoFail: es una vulnerabilidad de seguridad que afecta el firmware de las placas madre.Este ataque explota las bibliotecas de análisis de imágenes utilizadas durante el arranque del sistema, reemplazando el logotipo del fabricante por un archivo diseñado para ejecutar código malicioso. Debido a que ocurre en una etapa temprana del arranque, es casi imposible de detectar o eliminar con soluciones de seguridad convencionales

Estas fallas suelen permitir la ejecución de código malicioso antes de que el sistema operativo arranque, lo que dificulta su detección y eliminación.


### 3. ¿Qué es Converged Security and Management Engine (CSME), the Intel Management Engine BIOS Extension (Intel MEBx)?

**Intel CSME** es un subsistema dentro del chipset de Intel que proporciona funciones de seguridad y gestión, incluyendo arranque seguro, protección de firmware, almacenamiento de claves criptográficas y capacidades remotas (como Intel AMT).

**Intel MEBx (Management Engine BIOS Extension)** es una extensión que permite configurar las opciones del ME (Management Engine) desde el BIOS o UEFI. A través de MEBx se puede acceder, por ejemplo, a Intel AMT para gestionar equipos de forma remota, reiniciarlos, o configurar políticas de red.

Estas tecnologías son esenciales en entornos corporativos para el mantenimiento y control remoto de los sistemas, pero han sido criticadas por funcionar como "cajas negras" con acceso profundo al hardware.


### 4. ¿Qué es Coreboot? ¿Qué productos lo incorporan? ¿Cuáles son las ventajas de su utilización?

Coreboot es un proyecto de firmware libre y de código abierto diseñado para inicializar el hardware de un sistema y arrancar un sistema operativo moderno. A diferencia de BIOS/UEFI tradicionales, Coreboot es minimalista y modular. Se encuentra en algunos Chromebooks (por ejemplo, los de Google), Laptops de Purism (Librem) y System76, y algunas placas madre de servidores y dispositivos embebidos.

Las principales ventajas al usar Coreboot son: mayor velocidad de arranque, transparencia del código (es de código abierto), posibilidad de auditar y modificar el comportamiento del firmware, menor superficie de ataque, al eliminar componentes innecesarios.


## Desafío: Uso y análisis del Linker en sistemas de bajo nivel

### ¿Qué es un linker? ¿Qué hace?

El linker (o enlazador) es una herramienta que se encarga de tomar uno o más archivos objeto (.o), generados por el compilador, y unirlos para formar un archivo ejecutable o una imagen binaria. Su función principal es resolver referencias cruzadas entre funciones o variables definidas en distintos archivos, y ubicar cada sección del código en una dirección de memoria específica según las instrucciones del script de enlace.
### ¿Qué es la dirección que aparece en el script del linker? ¿Por qué es necesaria?
El script del linker permite definir direcciones absolutas en memoria donde se ubicarán las distintas secciones del programa (como **.text**, **.data**, **.bss**). Por ejemplo:
    
    SECTIONS {
        
        . = 0x7C00;
        .text : {*(.text)}
    }
La dirección **0x7C00** es crucial cuando se está desarrollando un bootloader, ya que es la dirección en la que la BIOS carga el primer sector del disco (512 bytes). Sin esta dirección explícita, el programa no funcionaría correctamente porque se esperaría en un lugar de memoria diferente al que realmente está.
### Compare la salida de **objdump** con **hd**, verifique dónde fue colocado el programa dentro de la imagen.

La herramienta objdump -d archivo.o permite ver el contenido desensamblado del archivo objeto. 

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_objdump.png)

Por otro lado, hd (hexdump) muestra el contenido hexadecimal de una imagen binaria.

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_hd.png)

Comparando ambos, se puede verificar que las instrucciones de ensamblado están presentes en el offset correcto de la imagen binaria. Por ejemplo, si el programa fue linkeado para la dirección 0x7C00, se debe verificar con hd que las primeras instrucciones del binario están efectivamente a partir de ese punto.

### Grabar la imagen en un pendrive y probarla en una PC y subir una foto.

Este paso consiste en tomar la imagen binaria generada (por ejemplo, bootloader.bin) y grabarla en un dispositivo USB con un comando como:

**sudo dd if=bootloader.bin of=/dev/sdX bs=512 count=1**

Luego, se debe reiniciar la PC configurando el arranque desde el pendrive para probar el funcionamiento del código. (Este punto incluye la subida de una foto, que deberías hacer desde tu dispositivo).

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_boot_pendrive.png)



### ¿Para qué se utiliza la opción --oformat binary en el linker?

La opción --oformat binary en ld le indica al linker que genere una salida en formato binario puro (sin encabezados ni metadatos), lo cual es necesario para el desarrollo de sistemas embebidos o bootloaders. Esto produce un archivo que puede ser cargado directamente en memoria, tal como lo haría un firmware o una BIOS.

Ejemplo de uso:

**ld -T script.ld archivo.o -o bootloader.bin --oformat binary**

### Depuración de ejecutables con llamadas a bios int 

Nuestro objetivo es depurar un bootloader en modo real usando QEMU y GDB, verificando la impresión de un mensaje personalizado mediante interrupciones BIOS.

#### Paso 1:
Como primer paso ejecutamos el comando:
**qemu-system-i386 -fda main.img -boot a -s -S -monitor stdio**

Donde:
- fda main.img: Carga nuestra imagen de bootloader.
- s -S: Pausa la CPU y habilita el servidor GDB en el puerto 1234.
- monitor stdio: Permite interactuar con QEMU desde la terminal.

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step1.png)

#### Paso 2: Conexión con GDB
Luego debemos abrir otra terminal y abrir gdb para comenzar con la depuración

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img1.png)

Luego el primer comando que debemos escribir es:
**target remote localhost:1234**

Este comando nos conecta GDB a QEMU

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img2.png)

Luego debemos escribir el comando:
**set architecture i8086**
el cual configura para modo real de 16 bits.

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img3.png)

A continuación escribimos el comando:
**br \*0x7c00**
El cual coloca un breakpoint en la dirección de carga del bootloader

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img4.png)

Luego escribimos **continue** y vemos esto:

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img5.png)

Esto nos indica que **main.img** se reconoció como un disquete booteable
#### Paso 3:
Luego debemos colocar un breakpoint luego de la llamada a la interrupción.
Si ejecutamos el comando:
**x/10i $eip**
Nos examina 10 instrucciones a partir de la actual

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img6.png)

Podemos ver que la dirección que nos interesa es la **0x7c0c** que es a continuación del llamado a la interrupción y es donde debemos colocar el breakpoint.

Si escribimos
**br \*0x7c0c**
en la imagen podemos ver ambos breakpoints.

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img7.png)

Escribiendo la letra **c** o la palabra **continue** para continuar vemos en la pantalla de Quemu que se va formando la palabra hello world letra a letra.

Con el comando **info registers** podemos ver el estado actual de los registros.

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img8.png)

Podemos ver que el registro **eax** contiene el valor **0xe6c**, esto nos quiere decir que la parte alta (**AH=0x0e** es la función BIOS para imprimir), y la parte baja (**AL=0x6c** nos indica que la letra **'l'** acaba de ser impresa).

Podemos ver que efectivamente los registros muestran la información correcta.

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img9.png)

Continuando con la depuración y verificando la información de los registros nuevamente:
Observamos que el registro **eax** contiene ahora el valor **0xe6f** correspondiente a la letra **'o'**

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img10.png)

Repitiendo el procedimiento llegamos a completar la palabra **hello world**

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/linker_debug_step2_img11.png)


## Desafío: Modo protegido

### Crear un código assembler que pueda pasar a modo protegido (sin macros).

Para ello se genero el codigo en el archivo

**/protected_mode/protected_mode_code.S**

Este código tiene como objetivo iniciar en modo protegido en arquitecturas x86 junto con una implementación de función de impresión en pantalla

Luego se corrieron los siguientes comandos

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/protected_mode_ass_img1.png)

Logrando ver en QEMU lo siguiente

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/protected_mode_ass_img2.png)

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/protected_mode_ass_img3.png)

Vemos que el modo protegido se inició correctamente, sin embargo por alguna razón el programa queda en un bucle infinito del cual no hemos encontrado forma de corregirlo.

### ¿Cómo sería un programa que tenga dos descriptores de memoria diferentes, uno para cada segmento (código y datos) en espacios de memoria diferenciados? 
| Característica               | Programa con un descriptor                     | Programa con dos descriptores                   |
|------------------------------|-----------------------------------------------|------------------------------------------------|
| **Segmentos de memoria**          | Único segmento para código y datos            | Dos segmentos diferenciados: código y datos    |
| **Descriptores**                  | 1 descriptor (compartido)                     | 2 descriptores independientes                  |
| **Seguridad**                     | Menor nivel (código y datos comparten espacio)| Mayor aislamiento entre código y datos         |
| **Eficiencia**                    | Acceso menos optimizado                       | Acceso más eficiente                           |
| **Modularidad**                   | Más complejo de mantener                      | Más fácil de escalar y depurar                 |
| **Complejidad**                   | Implementación sencilla                       | Configuración más compleja                     |
| **Sobrecarga**                    | Menor uso de memoria                          | Mayor uso por descriptores adicionales         |
| **Compatibilidad**                | Funciona en sistemas básicos                  | Requiere soporte avanzado                      |
| **Usos típicos**                  | Aplicaciones simples                          | Sistemas críticos (kernels, entornos seguros)  |

#### Factores Clave para la Elección

La selección entre una o dos descriptores debe considerar:

* Requisitos del programa: Seguridad, rendimiento y complejidad.
* Capacidades del sistema operativo: Soporte para múltiples descriptores.
* Recursos disponibles: Memoria y capacidad de procesamiento.

#### Ventajas y Desafíos
- Un descriptor:	
    - Ventaja: Simpleza de implementación y menor consumo de recursos.
    - Desafío: Riesgos de seguridad y limitaciones en rendimiento.
- Dos descriptores:
    - Ventaja: Aislamiento de memoria (seguridad) y acceso optimizado.
    - Desafío: Mayor complejidad y sobrecarga de memoria.
#### Casos Prácticos
| Tipo de Programa      | Ejemplo                     | Descriptor Recomendado | Razón                                                                 |
|-----------------------|-----------------------------|------------------------|-----------------------------------------------------------------------|
| **Aplicación básica**     | Juego clásico (ej: Tetris)  | 1 descriptor           | No requiere aislamiento de datos ni alto rendimiento.                |
| **Sistema crítico**       | Plataforma bancaria o médica| 2 descriptores         | Protección de datos sensibles y prevención de corrupción.            |
### Cambiar los bits de acceso del segmento de datos para que sea de solo lectura,  intentar escribir, ¿Que sucede? ¿Que debería suceder a continuación? (revisar el teórico) Verificarlo con gdb. 

Para ello se generó el siguiente código

**/protected_mode/read_only_code.S**

El cual busca modificar un segmento de datos de solo lectura

Explicación:

Se declara un segmento de datos **data_segment**, este contiene la cadena **"This is some data"**.

Luego el código intenta cambiar los permisos de acceso de **data_segment** a solo lectura, para esto utiliza valores de registro específicos para configurar el registro de control y la máscara de bits de sólo lectura.

El código intenta escribir el valor 0x61, es decir el carácter “a”, en **data_segment**, pero este intento de escritura falla debido a que los permisos de acceso de solo lectura

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/protected_mode_read_only_img1.png)

Validación en GDB

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/protected_mode_read_only_img2.png)


![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/protected_mode_read_only_img3.png)


![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/protected_mode_read_only_img4.png)


La última línea indica que el error ocurre al intentar escribir en el registro que simula ser el segmento de datos

![](https://github.com/megafagol/tp3-siscomp-om/blob/main/img/protected_mode_read_only_img5.png)


### En modo protegido, ¿Con qué valor se cargan los registros de segmento ? ¿Porque? 

En el modo protegido, los registros de segmento no almacenan direcciones físicas directamente, sino selectores de segmento, que actúan como índices en una tabla de descriptores. Este enfoque proporciona:
- Mayor seguridad: Control de acceso granular.
- Flexibilidad: Cambios dinámicos en segmentos sin modificar registros.
- Compatibilidad: Transición más sencilla entre modos (real/protegido).

Funcionamiento Detallado
1. Selectores de Segmento
- Son valores de 16 bits que funcionan como índices en la GDT (Global Descriptor Table) o LDT (Local Descriptor Table).
- Estructura del selector:	
    - Índice (13 bits): Posición en la tabla de descriptores.
    - TI (1 bit): Tabla usada (0 = GDT, 1 = LDT).
    - RPL (2 bits): Nivel de privilegio (0 = kernel, 3 = usuario).


2. Tabla de Descriptores (GDT/LDT)
Cada entrada define un segmento de memoria con:

| Campo      | Descripción                                                                 |
|------------|------------------------------------------------------------------------------|
| **Base**   | Dirección física de inicio del segmento.                                    |
| **Límite** | Tamaño del segmento (en bytes o páginas).                                   |
| **Permisos** | Lectura/escritura/ejecución (según tipo de segmento: código, datos, stack). |
| **DPL**    | Nivel de privilegio requerido (0-3).                                         |
| **Atributos** | Flags como presencia, granularidad (4KB o bytes), y tipo (sistema/usuario). |



3. Traducción de Direcciones
- Proceso:
    - El CPU usa el selector (ej: CS, DS) para buscar el descriptor en la GDT/LDT.
    - Combina la base del segmento con el offset (dirección lógica) para obtener la dirección física.
    - Verifica límites y permisos (ej: escritura en segmento de código → error #GP).
    
Ejemplo:

        asm
        MOV AX, 0x10       ; Selector de segmento (índice 2 en GDT, TI=0, RPL=0)
        MOV DS, AX         ; Carga DS con el selector
        MOV [BX], AL       ; Acceso a memoria: DS:[BX] → dirección física = base_DS + BX

#### Ventajas Clave



| Beneficio       | Explicación                                                                 |
|-----------------|------------------------------------------------------------------------------|
| **Seguridad**   | Aislamiento entre procesos (cada uno con su LDT) y protección por niveles (DPL). |
| **Flexibilidad**| Cambiar atributos de segmentos (ej: expandir memoria) sin recargar registros.   |
| **Compatibilidad**| Ejecución de código antiguo (modo real) mediante descriptores especiales.     |


#### Ejemplo práctico

| Aspecto         | Modo Real                             | Modo Protegido                         |
|-----------------|----------------------------------------|----------------------------------------|
| **Direccionamiento** | Segmento:Offset = Dirección física     | Selector → Descriptor → Dirección física |
| **Protección**       | Ninguna                               | Límites y permisos (DPL)               |
| **Uso típico**       | BIOS, bootloaders                     | Sistemas operativos modernos           |

