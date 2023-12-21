;-------------------------------------------------------------------------------
; Clear the screen on an OLED display connected to the 1802-Mini
; computer via the SPI Expansion Board.
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
#include ../include/ops.inc
#include ../include/bios.inc
#include ../include/kernel.inc
#include ../include/oled.inc
#include ../include/oled_spi_lib.inc

            org   2000h
start:      br    main


            ; Build information
            ; Build date
date:       db      80h+12            ; Month, 80h offset means extended info
            db      17                ; Day
            dw      2023              ; year
           
            ; Current build number
build:      dw      4                 ; build
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
            return                    ; return to Elf/OS 

clr:        call  oled_check_driver
            lbdf  error
            
            ldi   V_OLED_INIT 
            call  O_VIDEO
            lbdf  error
            
            ldi   V_OLED_CLEAR        ; clear buffer
            call  O_VIDEO
            lbdf  error
            return
            
error:      abend                     ; return to Elf/OS with error code
          
            end   start
