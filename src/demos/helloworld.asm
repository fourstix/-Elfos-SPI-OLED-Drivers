;-------------------------------------------------------------------------------
; Display a greeting on an OLED display connected to
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
date:       db    80h+12         ; Month, 80h offset means extended info
            db    4              ; Day
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
            db    'Usage: helloworld',10,13,0
            return                      ; and return to os

good:       call  oled_check_driver
            lbdf  error
              
            call  oled_clear_buffer     ; clear out buffer
            lbdf  error
            


            ;---- draw text with background cleared
            load  r7, $0C00             ; Set R7 to beginning of line 12
            load  r8, greeting          ; set string buffer
            ldi   GFX_TXT_NORMAL        ; background cleared
            phi   r9    
            
            call  oled_print_string     ; draw character   
            
show:       call  oled_init_display     ; setup the display
            call  oled_update_display   ; update the display

            clc
            return
                      
error:      call o_inmsg
            db 'Error drawing string.',10,13,0
            abend
            
greeting:   db 'Hello, World!',0            
                           
            end   start
