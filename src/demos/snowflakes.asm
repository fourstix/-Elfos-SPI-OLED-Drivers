;-------------------------------------------------------------------------------
; Display a set of falling snowflake bitmaps on an OLED display
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
date:       db    80h+12         ; Month, 80h offset means extended info
            db    19             ; Day
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

            call  oled_init_display
                  
            
repeat:     load  rc, $10               ; set up loop counter            
            load  rd, rand_xy           ; point to random positions

            load  rf, rotate            ; set rotation flag
            ldn   rf
            plo   r9
            
            call  gfx_dimensions        ; get dimensions in ra      

            ;----- set up registers for  snowflakes
snowflake:  lda   rd                    ; get random x
            plo   r7                    ; set as x origin
            lda   rd                    ; get random y
            phi   r7                    ; set as y origin
            
            glo   r9
            ani   $01                   ; check lsb for portrait, r=1 or r=3
            lbz   landscape
            glo   r7                    ; for portrait mode
            shr                         ; divide x by 2
            plo   r7                    ; multiply y by 2
            ghi   r7
            shl 
            phi   r7
                          
landscape:  load  r8, $1010             ; bitmap h = 16, w = 16
  
fall:       ldi   GFX_SET               ; set color 
            phi   r9
            load  rf, flake             ; point to bitmap buffer                         
            call  gfx_draw_bitmap       ; draw bitmap at random location
            lbdf  error

            call  oled_update_display
            
            ;---- wait half a second (input button will quit)  
            load  rb, $510E             ; wait a quarter of a second
wait1:      bn4   press1
            lbr   done
press1:     dec   rb
            lbrnz rb, wait1

            ldi   GFX_CLEAR
            phi   r9                    ; set up color to erase          
            load  rf, flake             ; point to bitmap buffer                         
            call  gfx_draw_bitmap       ; clear bitmap
            lbdf  error

            call  oled_update_display
            
            ghi   r7                    ; move flake down
            adi   04                    ; 4 pixels
            phi   r7
            ghi   ra                    ; get Ymax value
            str   r2                    ; save Ymax in M(X) 
            ghi   r7                    ; check y value
            sm                          ; to see if we reached (or passed) the end          
            lbdf  nextflake             ; do the next flake      
            lbr   fall                  ; otherwise keep moving down            
            
nextflake:  dec   rc                    ; count down
            lbrnz rc, snowflake         ; repeat for next snowflake
            lbr   repeat                ; keep going until input is pressed
            
done:       call  oled_clear_buffer     ; clear out buffer
            call  oled_update_display 
            return                      ; return to Elf/OS

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: snowflakes [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13
            db    'Press input (/EF4) to quit program.',10,13,0
            abend                       ; and return to os
                      
error:      call o_inmsg
            db 'Error drawing bitmap.',10,13,0
            abend                       ; return to Elf/OS with an error code
               

;----- snowflake 
flake:    db $01, $00, $03, $80, $01, $00, $C1, $06, $E1, $0E, $19, $30, $07, $C0, $03, $80
          db $07, $C0, $19, $30, $E1, $0E, $C1, $06, $01, $00, $03, $80, $01, $00, $00, $00
          
          ;--- pseudo random cooridinates x = rand(111), y = rand(20) 
          ;   x0  y0   x1  y1  x2  y2  x3  y3  x4  y4   x5  y5  x6  y6  x7  y7 
rand_xy:  db  95,  4,  74, 0,  93, 14, 11,  9, 69,  7,  21,  3,  0, 13,  9, 15
          ;   x8   y8  x9  y9  xA  yA  xB  yB  xC  yC   xD  yD  xE  yE  xF  yF 
          db  78,  11, 96, 7,  64,  1, 49,  0,  9,  15, 91, 5,  24, 16, 90, 13  

          ;---- rotation flag
rotate:     db 0            
          
            end   start
