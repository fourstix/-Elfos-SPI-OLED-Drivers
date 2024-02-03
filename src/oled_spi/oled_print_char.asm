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
;   and the next character position will wrap around
;   the display boundaries.
;-------------------------------------------------------


;---------------------------------------------------------------------
; Name: oled_print_char
;
; Set pixels in the display buffer to define a 6x8 
; ASCII character at position x,y.  
;
; Parameters: 
;   r7.1 - y row
;   r7.0 - x column
;   r9.1 - color (text style: GFX_TXT_NORMAL, GFX_TXT_INVERSE or GFX_TXT_OVERLAY)
;   r9.0 - rotation
;   r8.1 - character scale factor (0,1 = no scaling, or 2-8)
;   r8.0 - ASCII character to print
;
; Note: Checks origin x,y adjusts to next valid cursor position
;       Checks ASCII character value, draws DEL (127) if out of bounds
;                  
; Return: 
;   r7 will point to next cursor position (text wraps)
;---------------------------------------------------------------------
            proc    oled_print_char      
            push    r9                ; save color register
            push    r8                ; save character register
                              
            call    gfx_adj_cursor    ; adjust position to valid cursor position                                    
                                           
            ;---- draw text background if needed
            call    oled_fill_bg
            
            call    gfx_draw_char     ; write the character to display
            ;---- space characters one column apart
            ghi     r8                ; get the scaling value
            lbnz    adjust            ; non-zero is okay
            ldi     $01               ; zero means one space
adjust:     str     r2                ; save spacing in M(X)
            glo     r7                ; get x value
            add                       ; adjust x by spacing    
            plo     r7                

            pop     r8                ; restore registers
            pop     r9
            clc                       ; indicate no error
pc_exit:    return    
     
            endp
