;-------------------------------------------------------------------------------
; Clear the screen on an OLED  display using the SH1106 controller chip 
; connected to port 0 of the 1802/Mini SPI interface.
;
; Copyright 2023 by Gaston Williams
;
; Based on code from the Elf-Elfos-OLED library
; Written by Tony Hefner
; Copyright 2022 by Tony Hefner
;
; SPI Expansion Board for the 1802/Mini Computer hardware
; Copyright 2022 by Tony Hefner 
;-------------------------------------------------------------------------------
#include ../include/bios.inc
#include ../include/kernel.inc
#include ../include/ops.inc
#include ../include/sysconfig.inc
#include ../include/sh1106.inc
#include ../include/oled.inc

            org   2000h
start:      br    main


            ; Build information
            ; Build date
date:       db      80h+3             ; Month, 80h offset means extended info
            db      13                ; Day
            dw      2023              ; year
           
            ; Current build number
build:      dw      2                 ; build
            db    'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                  ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                  ; move back to non-space character
            ldn   ra                  ; get byte
            lbz   clr                 ; jump if no argument given
            ; otherwise display usage message
            call  O_INMSG             
            db    'Usage: clear',10,13,0
            RTN                       ; return to Elf/OS 

clr:        ldi   V_OLED_INIT 
            CALL  O_VIDEO
            bdf   error
            
            ldi   V_OLED_CLEAR        ; clear buffer
            call  O_VIDEO
            bdf   error
            RTN
            
error:      ABEND                     ; return to Elf/OS with error code
          
            end   start
