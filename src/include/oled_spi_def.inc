;-----------------------------------
; Display constants
;-----------------------------------
#define DISP_WIDTH   128
#define DISP_HEIGHT   64
#define BUFFER_SIZE 1024

;-----------------------------------
; Pixel constants
;-----------------------------------
#define GFX_SET     $01
#define GFX_CLEAR   $00
#define GFX_INVERT  $80

;-----------------------------------
; Public Text constants
;-----------------------------------
#define GFX_TXT_NORMAL    $01
#define GFX_TXT_INVERSE   $00
#define GFX_TXT_OVERLAY   $80

;-------------------------------------------------------------------------------
; OLED routines used by other routines
;-------------------------------------------------------------------------------
            extrn   oled_display_buffer            
            extrn   oled_display_ptr
            extrn   oled_write_pixel
            extrn   oled_fast_v_line
            extrn   oled_fast_h_line
            extrn   oled_fill_buffer
            extrn   oled_clear_buffer
            extrn   oled_update_display
            extrn   oled_init_display
            extrn   oled_fill_bg
            extrn   oled_print_char
