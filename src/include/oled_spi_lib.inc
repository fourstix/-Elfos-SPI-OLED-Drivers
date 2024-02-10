;-----------------------------------
; Pixel constants
;-----------------------------------
#define GFX_SET     $01
#define GFX_CLEAR   $00
#define GFX_INVERT  $80


;-----------------------------------
; Public Text color style constants
;-----------------------------------
#define GFX_TXT_NORMAL    $01
#define GFX_TXT_INVERSE   $00
#define GFX_TXT_OVERLAY   $80

;-----------------------------------
; Public Text size constants
;-----------------------------------
#define GFX_TXT_DEFAULT  $00
#define GFX_TXT_SMALL    $01
#define GFX_TXT_MEDIUM   $02
#define GFX_TXT_LARGE    $04
#define GFX_TXT_HUGE     $08

;-------------------------------------------------------------------------------
; OLED public routines
;-------------------------------------------------------------------------------
            extrn   oled_display_buffer            
            extrn   oled_check_driver
            extrn   oled_fill_buffer
            extrn   oled_clear_buffer
            extrn   oled_init_display
            extrn   oled_update_display
            extrn   oled_print_char
            extrn   oled_print_string
