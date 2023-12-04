;-------------------------------------------------------------------------------
; Display a simple pattern made by drawing pixels on an OLED display
; connected to the 1802-Mini computer via the SPI Expansion Board.
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
date:       db      80h+11         ; Month, 80h offset means extended info
            db      27             ; Day
            dw      2023           ; year
           
            ; Current build number
build:      dw      3             ; build
            db    'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   good                  ; jump if no argument given
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: pixels',10,13,0
            return                      ; and return to os

good:       call  oled_check_driver
            lbdf  error
              
            call  oled_clear_buffer     ; clear out buffer

            ldi    GFX_SET              ; set color 
            phi    r9
              
            load   r7, $0000
            call   gfx_draw_pixel
            lbdf   error
          
            load   r7, $0A01
            call   gfx_draw_pixel
            lbdf   error


            load   r7, $0A02
            call   gfx_draw_pixel
            lbdf   error

            load   r7, $0A03
            call   gfx_draw_pixel
            lbdf   error

            load   r7, $0A04
            call   gfx_draw_pixel
            lbdf   error


            load   r7, $050A
            call   gfx_draw_pixel
            lbdf   error
          
            load   r7, $060A
            call   gfx_draw_pixel
            lbdf   error


            load   r7, $070A
            call   gfx_draw_pixel
            lbdf   error

            load   r7, $080A
            call   gfx_draw_pixel
            lbdf   error

            load   r7, $090A
            call   gfx_draw_pixel
            lbdf   error

            load   r7, $1010
            call   gfx_draw_pixel
            lbdf   error
          
            load   r7, $1111
            call   gfx_draw_pixel
            lbdf   error


            load   r7, $1212
            call   gfx_draw_pixel
            lbdf   error

            load   r7, $1313
            call   gfx_draw_pixel
            lbdf   error

            load   r7, $1414
            call   gfx_draw_pixel
            lbdf   error

            load   r7, $1515
            call   gfx_draw_pixel
            lbdf   error
          
            load   r7, $1416
            call   gfx_draw_pixel
            lbdf   error


            load   r7, $1317
            call   gfx_draw_pixel
            lbdf   error

            load   r7, $1218
            call   gfx_draw_pixel
            lbdf   error

            load   r7, $1119
            call   gfx_draw_pixel
            lbdf   error

            ;---- update display
            call  oled_init_display
            call  oled_update_display
            
done:       clc   
            return
            
error:      call o_inmsg
            db 'Error setting pixel.',10,13,0
            abend
            
; buffer:     ds    BUFFER_SIZE
            end   start
