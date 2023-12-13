;-------------------------------------------------------------------------------
; oled_spi - a library for basic graphics functions useful 
; for an oled display connected to the 1802-Mini computer via 
; the SPI Expansion Board.  These routines operate on pixels
; in a buffer used by the display.
;
;
; Copyright 2023 by Gaston Williams
;
; Based on code from the Elf-Elfos-OLED library
; Written by Tony Hefner
; Copyright 2022 by Tony Hefner
;
; Based on code from Adafruit_SH110X library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright 2012 by Adafruit Industries
;
; SPI Expansion Board for the 1802/Mini Computer hardware
; Copyright 2022 by Tony Hefner 
;-------------------------------------------------------------------------------
#include    ../include/ops.inc
#include    ../include/gfx_display.inc
#include    ../include/oled_spi_def.inc

;-------------------------------------------------------
; Public routine - This routine files the buffer with
;   the byte $FF so that all pixels are set.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: oled_fill_buffer
;
; Fill the entire display buffer so all pixels are set.
;
; Parameters: rf - pointer to display buffer.
;
; Return: (None)
;-------------------------------------------------------
            proc    oled_fill_buffer
            push    rf                ; save buffer ptr            
            push    rc                ; save counter

            load    rf, oled_display_buffer
            load    rc, BUFFER_SIZE   ; set counter
             
fb_loop:    ldi     $FF
            str     rf
            inc     rf
            dec     rc
            lbrnz   rc, fb_loop

            pop     rc
            pop     rf
            
            clc                       ; make sure DF = 0            
            return

            endp
