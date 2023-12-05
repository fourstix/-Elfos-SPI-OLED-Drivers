;-------------------------------------------------------------------------------
; Display a characters on an OLED display using the SH1106 controller 
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
            db    'Usage: textbg',10,13,0
            return                      ; and return to os

good:       call  oled_check_driver
            lbdf  error
              
            call  oled_clear_buffer     ; clear out buffer
            lbdf  error

            
            ;---- set up background pattern
            load  r7, $0810             ; draw first block 
            load  r8, $3060             
            ldi   GFX_SET
            phi   r9
            call  gfx_fill_rect
            lbdf  error

            load  r7, $1020             ; clear a block inside
            load  r8, $2040             
            ldi   GFX_CLEAR
            phi   r9
            call  gfx_fill_rect
            lbdf  error


            load  r7, $1828             ; draw last block
            load  r8, $1030             
            ldi   GFX_SET
            phi   r9
            call  gfx_fill_rect
            lbdf  error

            ;---- draw overlay text
            ldi   GFX_TXT_OVERLAY       ; background shows through, text inverts bits
            phi   r9    
          
            load  r7, $0819             ;---- Set R7 to overlap block
            load  r8, overlay
            call  oled_print_string

            ;---- draw text with background cleared, text wraps
            load  r7, $2C38             ;---- Set R7 near middle of line 44
            load  r8, normal            ;---- set string buffer
            ldi   GFX_TXT_NORMAL        ; background cleared, text set
            phi   r9    
            
            call  oled_print_string


            ;---- draw text with background set
            load  r7, $1A00             ;---- Set R7 at beginning of line 26
            load  r8, inverse           ;---- set string buffer
            ldi   GFX_TXT_INVERSE       ; background set, text cleared
            phi   r9    
            
            call  oled_print_string
            
show:       call  oled_init_display     ; setup the display
            call  oled_update_display   ; update the display

            clc
            return                      ; return to Elf/OS
                      
error:      call o_inmsg
            db 'Error drawing string.',10,13,0
            abend                       ; return to Elf/OS with an error code
            
overlay:    db 'Transparent text background.',0
normal:     db 'Normal text background.',0            
inverse:    db 'Inverse text background.',0                            
            end   start
