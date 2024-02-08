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
date:       db    80h+2          ; Month, 80h offset means extended info
            db    3              ; Day
            dw    2024           ; year
           
            ; Current build number
build:      dw    5              ; build
            db    'Copyright 2024 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   good                  ; jump if no argument given
            
            smi   '-'                   ; was it a dash to indicate option?
            lbnz  usage                 ; if not a dash, show error  
            inc   ra                    ; move to next character
            lda   ra                    ; check for fill option 
            smi   'r'
            lbnz  usage                 ; bad option, show usage message
       
sp_1:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   sp_1

            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get rotation value
            smi   '0'                   ; should be 0, 1, 2 or 3
            lbnf  usage                 ; if less than zero, show usage message
            ldn   ra                    ; check again
            smi   '4'                   ; should be 0, 1, 2 or 3
            lbdf  usage                 ; if greater than 3, show usage message
            load  rf, rotate            ; point rf to rotate flag
            ldn   ra                    ; get rotation paramater
            smi   '0'                   ; convert character to digit value
            str   rf                    ; save as rotate flag

good:       call  oled_check_driver
            lbdf  error
              
            call  oled_clear_buffer     ; clear out buffer
            lbdf  error
            
            ;---- draw text with background cleared
            
            load   rf, rotate           ; set rotation flag
            ldn    rf
            plo    r9

            ldi   GFX_TXT_NORMAL        ; background cleared
            phi   r9    
            ldi   GFX_TXT_SMALL         ; normal sized text
            phi   r8

            load  rf, greeting          ; set string buffer
            
            load  r7, $0C00             ; Set cursor to start of line 12

            call  oled_print_string     ; draw character  
                       
show:       call  oled_init_display     ; setup the display
            call  oled_update_display   ; update the display
            
            ;---- wait half a second   
            load  rc, $A220             ; wait about half a second
wait1:      nop                         ; cycles for delay
            dec   rc
            lbrnz rc, wait1

            
            call  oled_clear_buffer     ; clear out buffer
            lbdf  error
            
            ldi   GFX_TXT_NORMAL        ; background cleared
            phi   r9    
            ldi   GFX_TXT_LARGE         ; large sized text
            phi   r8

            load  rf, response          ; set string buffer
            
            load  r7, $0000             ; Set cursor to home

            call  oled_print_string     ; draw character  
            
            call  oled_update_display   ; update the display           
            clc
            return

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: helloworld [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter-clockwise',10,13,0
            abend                       ; and return to os            
                      
error:      call o_inmsg
            db 'Error drawing string.',10,13,0
            abend
            
greeting:   db 'Hello, World!',0     
response:   db 'Hi!',0            

            ;---- rotation flag
rotate:     db 0            
                           
            end   start
