;-------------------------------------------------------------------------------
; Display a set of rectangles on an OLED display connected to
; the 1802-Mini computer via the SPI Expansion Board.
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
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: blocks',10,13,0
            return                      ; and return to os

good:       call  oled_check_driver
            lbdf  error
              
            call  oled_clear_buffer     ; clear out buffer


            ldi    GFX_SET              ; set color to draw
            phi    r9            

            load   r7, $0810            ; draw first block 
            load   r8, $3060             
            call   gfx_fill_rect
            lbdf   error
            
            ldi    GFX_CLEAR            ; set color to clear 
            phi    r9

            load   r7, $1020            ; clear a block inside
            load   r8, $2040             
            call   gfx_fill_rect
            lbdf   error

            ldi    GFX_SET              ; set color to draw
            phi    r9            

            load   r7, $1828            ; draw last block
            load   r8, $1030             
            call   gfx_fill_rect
            lbdf   error

            ;---- update display
show_it:    call  oled_init_display
            call  oled_update_display

done:       clc   
            return
            
error:      call o_inmsg
            db 'Error drawing blocks.',10,13,0
            abend                       ; return to Elf/OS with an error code
            
            end   start
