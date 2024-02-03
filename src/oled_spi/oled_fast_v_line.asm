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
#include    ../include/bios.inc
#include    ../include/kernel.inc
#include    ../include/ops.inc
#include    ../include/gfx_display.inc
#include    ../include/oled_spi_def.inc
#include    ../include/gfx_lib.inc

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: oled_fast_v_line
;
; Draw a vertical line starting at position x,y.
;
; Parameters: r7.1 - origin y 
;             r7.0 - origin x 
;             r9.1 - color 
;             r8.0 - length 
; Registers Used:
;             rd   - buffer pointer
;             rc.0 - counter
;             rb   - look up table pointer
;             ra.1 - mask byte
;             ra.0 - mod value 
;                 
; Return: (None) r8, r9.0 - consumed
;-------------------------------------------------------
            proc   oled_fast_v_line

            push   rd               ; save buffer pointer
            push   rc               ; save counter
            push   rb               ; save look up register
            push   ra               ; save scratch register

            ;-------------------------------------------------------
            ;  rd - points to byte in buffer
            ;  rc.1 - bit mask
            ;  rc.0 - counter
            ;  rb   - look up table ptr
            ;  r9.1 - color 
            ;  r8.0 - length (h)
            ;  ra.1 - mask byte
            ;  ra.0 - mod value
            ;  r7.1 - origin y
            ;  r7.0 - origin x
            ;-------------------------------------------------------
            
            ; increase length to always draw at least one pixel
            inc    r8                 
          
            ;---- get ptr to byte in buffer
            call   oled_display_ptr ; rd now points to byte in buffer
            
            ;---- calculate bit offset = y0 & 7
            ghi    r7               
            ani     7               ; D = y & 7
            lbz    fwv_byte         ; if byte aligned, draw entire byte
            ;---- calculate mod value
            sdi     8               ; D = (8 - D) = 8 - (y&7)
            plo    ra               ; save mod in ra.0
            

            ;-------------------------------------------------------
            ; write bits in partial first byte
            ;-------------------------------------------------------            
                        
            load   rb, premask      ; set lookup ptr to premask
            glo    ra               ; get mod value
            str    r2               ; save in M(X)
            glo    rb               ; get look up ptr
            add                     ; add mod offset to look up ptr
            plo    rb               ; put back in look up ptr
            ghi    rb               ; adjust hi byte of look up ptr        
            adci    0               ; add carry value to hi byte of look up ptr
            phi    rb               ; rb now points to premask value
            
            ldn    rb               ; get premask byte from look up table
            phi    ra               ; save in ra.1

            ;---- check if h is less than mod value
            glo    ra               ; get mod value
            str    r2               ; save at M(X)
            glo    r8               ; get h
            sm                      ; D = (h - m)
            lbdf   fwv_mask1        ; if DF = 1, (h - mod) >= 0, mask is okay
            
            ;---- adjust premask mask &= (0XFF >> (mod-h));
            sdi     0               ; negate difference, 0 - D = (mod - h)
            plo    rc               ; save shift counter
            ldi    $FF              ; set initial bit shift mask
            phi    rc               ; save bit shift mask in rc.1

fwv_shft1:  glo    rc               ; check counter
            lbz    fwv_shft2
            ghi    rc               ; shift bit mask 1 bit right
            shr    
            phi    rc
            dec    rc               ; count down
            lbr    fwv_shft1        ; keep going until shift mask done

fwv_shft2:  ghi    rc               ; get shifted bit mask
            str    r2               ; save in M(X)
            ghi    ra               ; get premask
            and                     ; clear out unused high bits
            phi    ra               ; save premask
            
fwv_mask1:  ghi    r9               ; check color
            lbz    clr_mask1        ; check for GFX_CLEAR  
            shl                     ; check for GFX_INVERSE
            lbdf   inv_mask1        ; DF =1, means GFX_INVERSE
            
set_mask1:  ghi    ra               ; get premask for GFX_SET
            str    r2               ; save premask in M(X) 
            ldn    rd               ; get first byte
            or                      ; or to set selected bits
            str    rd               ; put back in buffer
            lbr    fwv_draw         ; continue to draw rest of line
             
clr_mask1:  ghi    ra               ; get premask          
            xri    $FF              ; invert mask for AND
            str    r2               ; save premask in M(X)
            ldn    rd               ; get byte from buffer
            and                     ; and to clear out selected bits
            str    rd               ; put back in buffer
            lbr    fwv_draw         ; continue to draw rest of line
            
inv_mask1:  ghi    ra               ; get premask          
            str    r2               ; save premask in M(X)
            ldn    rd               ; get byte from buffer
            xor                     ; xor to invert selected bits
            str    rd               ; put back in buffer
                           
fwv_draw:   glo    ra               ; adjust h by mod value
            str    r2               ; save mod value in M(X)
            glo    r8               ; get h (length)
            sm                      ; D = (h - mod)
            lbnf   fwv_done         ; if h < mod, we're done!
            plo    r8               ; save updated h value

            ;-------------------------------------------------------
            ; write entire bytes at a time
            ;-------------------------------------------------------            

next_byte:  add16  rd, 128          ; advance buffer ptr to next line
fwv_byte:   glo    r8               ; get h
            smi     8               ; subtract 8
            lbnf   fwv_last         ; if h < 8, do last byte
            plo    r8               ; save h = h-8
            ghi    r9               ; check color
            lbz    clr_byte         ; check for GFX_CLEAR  
            shl                     ; check for GFX_INVERSE
            lbdf   inv_byte         ; DF =1, means GFX_INVERSE

            ldi    $FF              ; GFX_SET, so set all bits at once 
            str    rd               ; update byte in buffer
            lbr    next_byte        ; continue to next byte  

clr_byte:   ldi    0                ; clear all 8 bits                        
            str    rd
            lbr    next_byte        ; continue to next byte

inv_byte:   ldn    rd               ; get byte from buffer
            xri    $FF              ; flip all bits in byte
            str    rd               ; update byte in buffer
            lbr    next_byte        ; continue to next byte
            
fwv_last:   glo    r8               ; do the last partial byte
            lbz    fwv_done         ; h = 0, ends on byte boundary, we're done
            ani    7                ; h&7 is last mod value
            plo    ra               ; save mod value
            load   rb, postmask     ; set rb to lookup table
            glo    ra               ; get mod value
            str    r2               ; save mod value in M(X)
            glo    rb               ; add mod value to lookup ptr
            add 
            plo    rb               
            ghi    rb               ; adjust hi byte of lookup ptr for carry
            adci   0
            phi    rb
            ldn    rb               ; get post mask value
            phi    ra               ; save postmask byte

            ;-------------------------------------------------------
            ; write the bits in the remaining last byte  
            ;-------------------------------------------------------            
            
            ghi    r9               ; check color
            lbz    clr_mask2        ; check for GFX_CLEAR  
            shl                     ; check for GFX_INVERSE
            lbdf   inv_mask2        ; DF =1, means GFX_INVERSE
            
            ghi    ra               ; get postmask for GFX_SET
            str    r2               ; save postmask in M(X) 
            ldn    rd               ; get last byte
            or                      ; or to set selected bits
            str    rd               ; put back in buffer
            lbr    fwv_done         ; finished drawing line
             
clr_mask2:  ghi    ra               ; get postmask          
            xri    $FF              ; invert mask for AND
            str    r2               ; save postmask in M(X)
            ldn    rd               ; get last byte from buffer
            and                     ; and to clear out selected bits
            str    rd               ; put back in buffer
            lbr    fwv_done         ; finished drawing line
            
inv_mask2:  ghi    ra               ; get postmask          
            str    r2               ; save postmask in M(X)
            ldn    rd               ; get last byte from buffer
            xor                     ; xor to invert selected bits
            str    rd               ; put back in buffer            
            
fwv_done:   pop    ra               ; restore registers
            pop    rb
            pop    rc
            pop    rd  
            clc                     ; make sure error flag is cleared
            return

            ;---- look up tables for partial first and last bytes
premask:  db $00, $80, $C0, $E0, $F0, $F8, $FC, $FE 
postmask: db $00, $01, $03, $07, $0F, $1F, $3F, $7F 
            endp
