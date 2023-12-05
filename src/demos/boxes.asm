;-------------------------------------------------------------------------------
; Display a set of rectangles on an OLED display using the SH1106 controller 
; chip connected to port 0 of the 1802/Mini SPI interface.
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
#include ../include/gfx_lib.inc

            org   2000h
start:      br    main


            ; Build information
            ; Build date
date:       db    80h+11         ; Month, 80h offset means extended info
            db    29             ; Day
            dw    2023           ; year
           
            ; Current build number
build:      dw    3              ; build
            db    'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   good                  ; jump if no argument given
            ; otherwise display usage message
            call  O_INMSG               
            db    'Usage: boxes',10,13,0
            return                      ; and return to os

good:       call  oled_check_driver
            lbdf  error
            
            call  oled_clear_buffer     ; clear out buffer
            
            ldi    GFX_SET              ; set color 
            phi    r9

            load  r7, $0000             ; draw border rectangle
            load  r8, $3F7F             
            call  gfx_draw_rect
            lbdf  error

            load  r7, $0810             ; draw rectangle inside first
            load  r8, $3060             
            call  gfx_draw_rect
            lbdf  error

            load  r7, $1020             ; draw rectangle inside second
            load  r8, $2040             
            call  gfx_draw_rect
            lbdf  error


            load  r7, $1828             ; draw last rectangle
            load  r8, $1030             
            call  gfx_draw_rect
            lbdf  error

            ;---- update display
            call  oled_init_display
            call  oled_update_display

done:       clc   
            return
            
error:      call o_inmsg
            db 'Error drawing rectangles.',10,13,0
            abend                       ; return to Elf/OS with an error code
            
            end   start
