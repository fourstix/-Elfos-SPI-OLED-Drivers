;-------------------------------------------------------------------------------
; oled_spi - a library for basic graphics functions useful 
; for an oled display connected to the 1802-Mini computer via 
; the SPI Expansion Board.  These routines operate on pixels
; in a buffer used by the display.
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
#include    ../include/oled.inc

;---------------------------------------------------------
; Public routine - This routine updates the display 
;---------------------------------------------------------


;-------------------------------------------------------
; Name: oled_init_display
;
; initiailize the OLED display.
;
; Parameters: (None)
;
; Returns: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    oled_init_display

            ;---- initiailize the display
            ldi   V_OLED_INIT
            CALL  O_VIDEO          

            return

            endp
