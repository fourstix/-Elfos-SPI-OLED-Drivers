;-------------------------------------------------------------------------------
; Display a characters on an OLED display connected to
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
            db    2              ; Day
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
            call  o_inmsg               
            db    'Usage: charset',10,13,0
            return                      ; Return to Elf/OS

good:       call  oled_check_driver
            lbdf  error
              
            call  oled_clear_buffer     ; clear out buffer
            lbdf  error

            ldi   96                    ; 96 printable characters
            plo   rc                    ; save in counter
            
            ;---- draw text
            ldi   GFX_TXT_NORMAL       ; clear background
            phi   r9    
          
            load  r7, 0                 ;---- Set R7 at origin (0,0)
            ldi   ' '                   ; set up first character
            plo   r8

draw_ch:    glo   rc                    ; get counter
            lbz   show                  ; when done, show display
                          
            call  oled_print_char       ; draw character   

            inc   r8                    ; go to next character
            dec   rc                    ; count down
            lbr   draw_ch               ; keep going until all chars drawn
            
show:       call  oled_init_display     ; setup the display
            call  oled_update_display   ; update the display

            clc
            return                      ; return to Elf/OS
                      
error:      call o_inmsg
            db 'Error drawing character set.',10,13,0
            abend                       ; return to Elf/OS with an error code
                      
            end   start
