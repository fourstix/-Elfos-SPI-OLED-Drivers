;-------------------------------------------------------------------------------
; Display a set of lines on an OLED display connected to
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
date:       db      80h+11         ; Month, 80h offset means extended info
            db      28             ; Day
            dw      2023           ; year
           
            ; Current build number
build:      dw      3              ; build
            db      'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   good                  ; jump if no argument given
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: lines',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       call  oled_check_driver
            lbdf  error
              
            call  oled_clear_buffer     ; clear out buffer
            lbdf  error

            ldi    GFX_SET              ; set color 
            phi    r9
            
            load  r7, $0000             ; draw top border
            load  r8, $007F             
            call  gfx_draw_line
            lbdf  error
                        
            load  r7, $0000             ; draw left border
            load  r8, $3F00             
            call  gfx_draw_line
            lbdf  error

            load  r7, $007F             ; draw right border
            load  r8, $3F7F             
            call  gfx_draw_line
            lbdf  error

            load  r7, $3F00             ; draw bottom border
            load  r8, $3F7F             
            call  gfx_draw_line
            lbdf  error

            load  r7, $0000             ; draw diagonals
            load  r8, $3F7F             
            call  gfx_draw_line
            lbdf  error

            load  r7, $007F             ; draw diagonals
            load  r8, $3F00             
            call  gfx_draw_line
            lbdf  error

            load  r7, $0040             ; draw vertical line
            load  r8, $3F40             
            call  gfx_draw_line
            lbdf  error

            load  r7, $2000             ; draw horizontal line
            load  r8, $207F             
            call  gfx_draw_line
            lbdf  error

            ;---- udpate the display
            call  oled_init_display
            call  oled_update_display

done:       clc   
            return
            
error:      call o_inmsg
            db  'Error drawing line.',10,13,0
            abend                       ; return to Elf/OS with error code
            
            end   start
