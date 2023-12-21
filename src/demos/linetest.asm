;-------------------------------------------------------------------------------
; Display various lines on an OLED display connected to
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
date:       db      80h+12         ; Month, 80h offset means extended info
            db      17             ; Day
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
            lbz   show_it               ; jump if no argument given

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
              
            call  oled_clear_buffer     ; clear out buffer
            lbdf  error

            ldi    GFX_SET              ; set color 
            phi    r9            
            
            load    rf, rotate          ; set rotation flag
            ldn     rf
            plo     r9
            shr                         ; lsb indicates portrait or landscape mode
            lbdf    portrait            ; r=1 or r=3 is portrait mode

            ;---------- horizontal line test            
            load  r7, $0010             ; draw along top border
            load  r8, $0070             
            call  gfx_draw_line

            lbnf  test_h2
            call  o_inmsg
            db    'H1 Error.',10,13,0
            lbr  error
            
            
            ;---------- horizontal line test (r7, r8 need swapping)
test_h2:    load  r7, $0650             ; draw horizontal line from (2,2)
            load  r8, $0620             ; to endpoint of (50,2)
            call  gfx_draw_line

            lbnf  test_h3
            call  o_inmsg
            db    'H2 Error.',10,13,0
            lbr  error

            ;---------- horizontal line test (boundaries)
test_h3:    load  r7, $2000             ; draw horizontal line from (0,32)
            load  r8, $207F             ; to endpoint of (127,32)
            call  gfx_draw_line

            lbnf  test_v1
            call  o_inmsg
            db    'H3 Error.',10,13,0
            lbr  error

            ;---------- vertical line test
test_v1:    load  r7, $2030             ; draw vertical line from (48,16)
            load  r8, $0030             ; to endpoint of (48,48)
            call  gfx_draw_line

            lbnf  test_v2
            call  o_inmsg
            db    'V1 Error.',10,13,0
            lbr  error

            ;---------- vertical line test (r7, r8 need swapping)
test_v2:    load  r7, $0060             ; draw vertical line from (32,16)
            load  r8, $2060             ; to endpoint of (32,48)
            call  gfx_draw_line

            lbnf  test_v3
            call  o_inmsg
            db    'V2 Error.',10,13,0
            lbr  error

            ;---------- vertical line test
test_v3:    load  r7, $0050             ; draw vertical line from (80,0)
            load  r8, $3F50             ; to endpoint of (80,63)
            call  gfx_draw_line

            lbnf  test_s1
            call  o_inmsg
            db    'V3 Error.',10,13,0
            lbr  error
            
            ;----------  sloping line test (flat, positive slope)
test_s1:    load  r7, $3213
            load  r8, $3A28
            call  gfx_draw_line

            lbnf  test_s2
            call  o_inmsg
            db    'S1 Error.',10,13,0
            lbr  error

            
            ;----------  sloping line test (flat, negative slope)
test_s2:    load  r7, $3843
            load  r8, $3058
            call  gfx_draw_line

            lbnf  test_s3
            call  o_inmsg
            db    'S2 Error.',10,13,0
            lbr  error

            ;----------  sloping line test (flat, positive, needs swap)
test_s3:    load  r7, $2A28
            load  r8, $2213
            call  gfx_draw_line

            lbnf  test_s4
            call  o_inmsg
            db    'S3 Error.',10,13,0
            lbr  error

            ;----------  sloping line test (steep, positive slope)
test_s4:    load  r7, $2213
            load  r8, $3218
            call  gfx_draw_line

            lbnf  test_s5
            call  o_inmsg
            db    'S4 Error.',10,13,0
            lbr  error

            ;----------  sloping line test (steep, negative slope)
test_s5:    load  r7, $3B50
            load  r8, $1B58
            call  gfx_draw_line

            lbnf  test_done
            call  o_inmsg
            db    'S5 Error.',10,13,0
            lbr  error


            ;---------- portrait mode line test 
portrait:   load  r7, $0008             ; draw along top border
            load  r8, $0038             
            call  gfx_draw_line

            lbdf  error


            ;---------- horizontal line test (r7, r8 need swapping)
            load  r7, $0C28             ; draw horizontal line from (40,12)
            load  r8, $0C3F             ; to endpoint of (63,12)
            call  gfx_draw_line

            lbdf  error


            ;---------- horizontal line test (boundaries)
            load  r7, $4000             ; draw horizontal line from (0,64)
            load  r8, $403F             ; to endpoint of (63,64)
            call  gfx_draw_line

            lbdf  error

            ;---------- vertical line test
            load  r7, $4018             ; draw vertical line from (24,64)
            load  r8, $0018             ; to endpoint of (24,0)
            call  gfx_draw_line

            lbdf  error

            ;---------- vertical line test (r7, r8 need swapping)
            load  r7, $0030             ; draw vertical line from (48,00)
            load  r8, $4030             ; to endpoint of (48,64)
            call  gfx_draw_line

            lbdf  error

            ;---------- vertical line test
            load  r7, $0028             ; draw vertical line from (40,0)
            load  r8, $7F28             ; to endpoint of (40,127)
            call  gfx_draw_line

            lbdf  error
          
            ;----------  sloping line test (flat, positive slope)
            load  r7, $640A
            load  r8, $7414
            call  gfx_draw_line

            lbdf  error

            
            ;----------  sloping line test (flat, negative slope)
            load  r7, $7021
            load  r8, $602C
            call  gfx_draw_line

            lbdf  error

            ;----------  sloping line test (flat, positive, needs swap)
            load  r7, $5414
            load  r8, $440A
            call  gfx_draw_line

            lbdf  error

            ;----------  sloping line test (steep, positive slope)
            load  r7, $440A
            load  r8, $640C
            call  gfx_draw_line

            lbdf  error

            ;----------  sloping line test (steep, negative slope)
            load  r7, $7628
            load  r8, $362C
            call  gfx_draw_line

            lbdf  error

            ;---- udpate the display
test_done:  call  oled_init_display
            call  oled_update_display

done:       clc   
            return

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: linetest [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os
            
error:      call o_inmsg
            db 'Error drawing line.',10,13,0
            abend                       ; return to Elf/OS with error code
            
            ;---- rotation flag
rotate:     db 0            
            
            end   start
