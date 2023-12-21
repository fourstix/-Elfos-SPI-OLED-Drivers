;-------------------------------------------------------------------------------
; Display a set of reversed (black on white) lines on an OLED display
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
date:       db      80h+12         ; Month, 80h offset means extended info
            db      18             ; Day
            dw      2023           ; year
           
            ; Current build number
build:      dw      4              ; build
            db      'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz     show_it             ; jump if no argument given

good:       smi     '-'                 ; was it a dash to indicate option?
            lbnz    usage               ; if not a dash, show error  
            inc     ra                  ; move to next character
            lda     ra                  ; check for fill option 
            smi     'r'
            lbnz    usage               ; bad option, show usage message
       
sp_1:       lda     ra                  ; move past any spaces
            smi     ' '
            lbz     sp_1

            dec     ra                  ; move back to non-space character
            ldn     ra                  ; get rotation value
            smi     '0'                 ; should be 0, 1, 2 or 3
            lbnf    usage               ; if less than zero, show usage message
            ldn     ra                  ; check again
            smi     '4'                 ; should be 0, 1, 2 or 3
            lbdf    usage               ; if greater than 3, show usage message
            load    rf, rotate          ; point rf to rotate flag
            ldn     ra                  ; get rotation paramater
            smi     '0'                 ; convert character to digit value
            str     rf                  ; save as rotate flag

show_it:    call  oled_check_driver
            lbdf  error
            
            call  oled_fill_buffer      ; fill buffer for all white background
            
            ldi   GFX_CLEAR             ; set color to clear line
            phi   r9    
            
            load  rf, rotate            ; set rotation flag
            ldn   rf
            plo   r9
                        
            call  gfx_dimensions        ; get Ymax and Xmax values in ra         

            ldi   0                     ; draw top border
            plo   r7
            phi   r7                    ; origin = (0,0)
            phi   r8                    
            glo   ra                    ; get Xmax    
            plo   r8                    ; endpoint = (Xmax,0)
            
            call  gfx_draw_line
            lbdf  error
                    
                        
            ldi   0                     ; draw left border
            plo   r7
            phi   r7                    ; origin = (0,0)
            plo   r8
            ghi   ra                    ; get Ymax
            phi   r8                    ; endpoint = (0,Ymax)
            call  gfx_draw_line
            lbdf  error

            ldi   0                     ; draw right border
            phi   r7
            glo   ra
            plo   r7                    ; origin = (Xmax, 0)
            plo   r8
            ghi   ra
            phi   r8                    ; endpint = (Xmax, Ymax)          
            call  gfx_draw_line
            lbdf  error

            ldi   0                     ; draw bottom border
            plo   r7
            ghi   ra
            phi   r7                    ; origin = (0, Ymax)
            phi   r8
            glo   ra
            plo   r8                    ; endpoint = (Xmax, Ymax)            
            call  gfx_draw_line
            lbdf  error

            ldi   0                     ; draw diagonal
            plo   r7
            phi   r7                    ; origin at (0,0)
            glo   ra
            plo   r8
            ghi   ra
            phi   r8                    ; endpoint at (Xmax, Ymax)
            call  gfx_draw_line
            lbdf  error

            ldi   0                     ; draw second diagonal
            phi   r7
            plo   r8
            glo   ra
            plo   r7                    ; origin at (Xmax, 0)
            ghi   ra
            phi   r8                    ; endpoint at (0, Ymax)
            call  gfx_draw_line
            lbdf  error

            ldi   0                     ; draw vertical line at midpoint of display
            phi   r7
            glo   ra                    ; get Xmax
            shr                         ; divide by 2 for midpoint
            plo   r7                    ; origin at (Xmax/2, 0)
            plo   r8
            ghi   ra
            phi   r8                    ; endpoint at (Xmax/2, Ymax)
            call  gfx_draw_line
            lbdf  error

            
            ldi   0                     ; draw horizontal line at midpoint of display
            plo   r7
            ghi   ra                    ; get Ymax
            shr                         ; divide by 2 for midpoint
            phi   r7                    ; origin at (0, Ymax/2)
            phi   r8
            glo   ra                    ; get Xmax
            plo   r8                    ; endpoint at (Xmax, Ymax/2)
            call  gfx_draw_line
            lbdf  error

            glo   ra                    ; draw horizontal line in upper part of display
            shr                         ; divide Xmax by 4
            shr            
            plo   r7     
            str   r2                    ; save in M(X)   
            ghi   ra                    ; get Ymax
            shr                         ; divide Ymax by 4 for upper fourth
            shr                         ; 
            phi   r7                    ; origin at (Xmax/4, Ymax/4)
            phi   r8
            glo   ra                    ; get Xmax
            sm                          ; subtract Xmax/4
            plo   r8                    ; endpoint at (3*Xmax/4, Ymax/4)
            call  gfx_draw_line
            lbdf  error            

            ;---- update display
            call  oled_init_display
            call  oled_update_display

done:       clc   
            return

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: lines [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os
            
error:      call o_inmsg
            db 'Error drawing line.',10,13,0
            abend

            ;---- rotation flag
rotate:     db 0            
            
            end   start
