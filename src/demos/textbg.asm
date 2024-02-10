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
            db    20             ; Day
            dw    2023           ; year
           
            ; Current build number
build:      dw    4              ; build
            db    'Copyright 2023 by Gaston Williams',0


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

            load    rf, rotate          ; set rotation flag
            ldn     rf
            plo     r9

            
            ;---- set up background pattern
            load  r7, $0810             ; draw first block 
            load  r8, $3060
            
            glo   r9                    ; check rotation flag
            ani   $01                   ; lsb indicates upright or sideways
            lbz   up_rt1                ; if upright, no need to swap w and h
            
            swap  r8                    ; sideways swap w and h values             
            ldi   $08                   ; adjust x value so x' = x/2
            plo   r7
            
up_rt1:     ldi   GFX_SET
            phi   r9
            call  gfx_fill_rect
            lbdf  error

            load  r7, $1020             ; clear a block inside
            load  r8, $2040             
            
            glo   r9                    ; check rotation flag
            ani   $01                   ; lsb indicates upright or sideways
            lbz   up_rt2                ; if upright, no need to swap w and h
            
            swap  r8                    ; sideways swap w and h values             
            ldi   $10                   ; adjust x value so x' = x/2
            plo   r7

up_rt2:     ldi   GFX_CLEAR
            phi   r9
            call  gfx_fill_rect
            lbdf  error


            load  r7, $1828             ; draw last block
            load  r8, $1030
            glo   r9                    ; check rotation flag
            ani   $01                   ; lsb indicates upright or sideways
            lbz   up_rt3                ; if upright, no need to swap w and h
            
            swap  r8                    ; sideways swap w and h values
            ldi   $18                   ; adjust x value so x' = x/2
            plo   r7
             
up_rt3:     ldi   GFX_SET
            phi   r9
            call  gfx_fill_rect
            lbdf  error

            ;---- draw overlay text
            load  r7, $0819             ;---- Set R7 to overlap block
            ldi   GFX_TXT_OVERLAY       ; background shows through, text inverts bits
            phi   r9              
            ldi   0                     ; set for no character scaling 
            phi   r8
            load  rf, overlay
            call  oled_print_string

            ;---- draw text with background cleared, text wraps
            load  r7, $2C38             ;---- Set R7 near middle of line 44
            ldi   GFX_TXT_NORMAL        ; background cleared, text set
            phi   r9    
            ldi   0                     ; set for no character scaling 
            phi   r8
            load  rf, normal            ;---- set string buffer
            
            call  oled_print_string


            ;---- draw text with background set
            load  r7, $1A00             ;---- Set R7 at beginning of line 26
            ldi   GFX_TXT_INVERSE       ; background set, text cleared
            phi   r9    
            ldi   0                     ; set for no character scaling 
            phi   r8
            load  rf, inverse           ;---- set string buffer
            
            call  oled_print_string
            
show:       call  oled_init_display     ; setup the display
            call  oled_update_display   ; update the display

            clc
            return                      ; return to Elf/OS

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: textbg [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os
                      
error:      call o_inmsg
            db 'Error drawing string.',10,13,0
            abend                       ; return to Elf/OS with an error code

            ;---- rotation flag
rotate:     db 0            
            
overlay:    db 'Transparent text background.',0
normal:     db 'Normal text background.',0            
inverse:    db 'Inverse text background.',0                            
            end   start
