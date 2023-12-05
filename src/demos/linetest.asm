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
date:       db      80h+11         ; Month, 80h offset means extended info
            db      27             ; Day
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
            ; otherwise display usage message
            call  o_inmsg               
            db    'Usage: linetest',10,13,0
            return                      ; and return to os

good:       call  oled_check_driver
            lbdf  error
              
            call  oled_clear_buffer     ; clear out buffer
            lbdf  error

            ldi    GFX_SET              ; set color 
            phi    r9            
            
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

            ;---- udpate the display
test_done:  call  oled_init_display
            call  oled_update_display

done:       clc   
            return
            
error:      call o_inmsg
            db 'Error drawing line.',10,13,0
            abend                       ; return to Elf/OS with error code
            
            end   start
