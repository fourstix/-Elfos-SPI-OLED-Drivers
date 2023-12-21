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
date:       db    80h+12         ; Month, 80h offset means extended info
            db    18             ; Day
            dw    2023           ; year
           
            ; Current build number
build:      dw    4              ; build
            db    'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                  ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                  ; move back to non-space character
            ldn   ra                  ; get byte
            lbz   good                ; jump if no argument given

            smi   '-'                 ; was it a dash to indicate option?
            lbnz  usage               ; if not a dash, show error  
            inc   ra                  ; move to next character
            lda   ra                  ; check for fill option 
            smi   'r'
            lbnz  usage               ; bad option, show usage message
       
sp_1:       lda   ra                  ; move past any spaces
            smi   ' '
            lbz   sp_1

            dec   ra                  ; move back to non-space character
            ldn   ra                  ; get rotation value
            smi   '0'                 ; should be 0, 1, 2 or 3
            lbnf  usage               ; if less than zero, show usage message
            ldn   ra                  ; check again
            smi   '4'                 ; should be 0, 1, 2 or 3
            lbdf  usage               ; if greater than 3, show usage message
            load  rf, rotate          ; point rf to rotate flag
            ldn   ra                  ; get rotation paramater
            smi   '0'                 ; convert character to digit value
            str   rf                  ; save as rotate flag

good:       call  oled_check_driver
            lbdf  error
            
            call  oled_clear_buffer   ; clear out buffer
            
            ldi    GFX_SET            ; set color 
            phi    r9
            
            load   rf, rotate         ; set rotation flag
            ldn    rf
            plo    r9

            shr                       ; check lsb to see of landscape or portrait
            lbdf    portrait          ; r=1 or r=3, portrait
            
landscape:  load  r7, $0000           ; draw border rectangle
            load  r8, $3F7F             
            call  gfx_draw_rect
            lbdf  error

            load  r7, $0810           ; draw rectangle inside first
            load  r8, $3060             
            call  gfx_draw_rect
            lbdf  error

            load  r7, $1020           ; draw rectangle inside second
            load  r8, $2040             
            call  gfx_draw_rect
            lbdf  error


            load  r7, $1828           ; draw last rectangle
            load  r8, $1030             
            call  gfx_draw_rect
            lbdf  error

            load  r7, $2F38           ; draw rectangle at bottom
            load  r8, $1010             
            call  gfx_draw_rect
            lbdf  error

            lbr   show_it

portrait:   load  r7, $0000           ; draw border rectangle
            load  r8, $7F3F             
            call  gfx_draw_rect
            lbdf  error
          
            load  r7, $1008           ; draw rectangle inside first
            load  r8, $6030             
            call  gfx_draw_rect
            lbdf  error

            load  r7, $2010           ; draw rectangle inside second
            load  r8, $4020             
            call  gfx_draw_rect
            lbdf  error


            load  r7, $2818           ; draw last rectangle
            load  r8, $3010             
            call  gfx_draw_rect
            lbdf  error

            load  r7, $6F18           ; draw rectangle at bottom
            load  r8, $1010             
            call  gfx_draw_rect
            lbdf  error

            ;---- update display
show_it:    call  oled_init_display
            call  oled_update_display

done:       clc   
            return

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: boxes [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os            
            
error:      call o_inmsg
            db 'Error drawing rectangles.',10,13,0
            abend                       ; return to Elf/OS with an error code
            
            ;---- rotation flag
rotate:     db 0            
                        
            end   start
