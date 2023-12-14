;-------------------------------------------------------------------------------
; gfx_oled - a library for basic graphics functions useful 
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
#include    ../include/gfx_lib.inc

;-------------------------------------------------------
; Public routine - This routine validates the origin
;   and the character string will wrap around the 
;   display boundaries.
;-------------------------------------------------------

;---------------------------------------------------------------------
; Name: oled_print_string
;
; Set pixels in the display buffer to define a string of 
; ASCII characters at position x,y.  The string will wrap 
; around the display if needed.  
;
; Parameters: 
;   r7.1 - y (row)
;   r7.0 - x (column)
;   r9.1 - background (GFX_ BG_TRANSPARENT OR GFX_OPAQUE)
;   rf   - pointer to null-terminated ASCII string
;
; Note: Checks x,y values, error if out of bounds. 
;       Checks ASCII character value, draws DEL (127) if out of bounds
;                  
; Returns: 
;    DF = 1 if error, 0 if no error
;    r7 points to next character position after string
;---------------------------------------------------------------------
            proc    oled_print_string
            push    r9                ; save color register
            push    r8                ; save character register
                        
ds_loop:    lda     rf                ; r8 points to string of characters  
            lbz     ds_done           ; null ends the string
            plo     r8                ; put character to draw
            
            CALL    oled_print_char   ; r7 advances to next position  
            
            lbdf    ds_done           ; exit immediately if error
            lbr     ds_loop           ; continue if no error  
            
ds_done:    pop     r8                ; restore registers
            pop     r9
            return                    ; return after string drawn
                        
            endp
