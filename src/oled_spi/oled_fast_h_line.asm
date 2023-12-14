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

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: oled_fast_h_line
;
; Draw a horizontal line starting at position x,y.
; Uses logic instead of calling write pixel.
;
; Parameters: 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   r9.1 - color 
;   r8.0 - length  (0 to 127)   
;                  
; Return: (None) r8.0 - consumed
;-------------------------------------------------------
            proc    oled_fast_h_line
            
            push    rd                ; save position register 
            push    rc                ; save bit mask register
            
            call    oled_display_ptr  ; point rd to byte in buffer

            ldi     $01               ; bit mask for vertical pixie byte
            phi     rc                ; store bit mask in rc.1
            ghi     r7                ; vertical pixel bytes, so get y position for bitmask
            ani     $07               ; mask off 3 lower bits to get pixel position
            plo     rc                ; store in bit counter rc.0
            
shft_ybit:  lbz     chk_color
            ghi     rc
            shl                       ; shift mask one bit     
            phi     rc                ; save mask in rc.1
            dec     rc                ; count down
            glo     rc                ; check counter
            lbr     shft_ybit         ; repeat until count down to zero

chk_color:  ghi     r9                ; get color from temp register
            lbnz    wfh_loop          ; check for GFX_SET or SET_INVERSE
            ghi     rc                ; get mask from rc (LSB bit order)
            str     r2                ; store GFX_CLEAR mask at M(x)
            ldi     $FF               ; invert bit mask so selected bit is zero
            xor                       ; Filp all mask bits ~(Bit Mask)             
            phi     rc                ; put inverted mask back for later

wfh_loop:   ghi     rc                ; get mask from rc (LSB bit order)
            str     r2                ; store mask at M(x) 
            ghi     r9                ; always do at least one pixel, so get color
            lbz     clr_ybit          ; check for GFX_CLEAR value
            shl                       ; check for GFX_INVERT value
            lbdf    flip_ybit                
                          
set_ybit:   ldn     rd                ; get byte from buffer
            or                        ; OR mask to set bit
            str     rd                ; put updated byte back in buffer
            lbr     wfh_chk           
clr_ybit:   ldn     rd                ; get byte from buffer
            and                       ; AND inverse mask to clear bit
            str     rd                ; put updated byte back in buffer
            lbr     wfh_chk           
flip_ybit:  ldn     rd                ; get byte from buffer
            xor                       ; XOR mask to invert bit
            str     rd                ; put updated byte back in buffer
  
wfh_chk:    glo     r8                ; check length count
            lbz     wh_done           ; if zero we are done
            inc     rd                ; move ptr to next byte
            dec     r8                ; draw length of w pixels
            lbr     wfh_loop            

wh_done:    pop     rc
            pop     rd
            return

            endp
