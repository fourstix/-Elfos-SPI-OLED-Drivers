[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_display_buffer.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_display_ptr.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_fill_buffer.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_write_pixel.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_fast_h_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_fast_v_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_check_driver.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_clear_buffer.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_init_display.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_update_display.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_fill_bg.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_print_char.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS oled_print_string.asm


[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_display.asm

type oled_display_buffer.prg oled_display_ptr.prg oled_fill_buffer.prg > oled_spi.lib
type oled_write_pixel.prg oled_fast_h_line.prg oled_fast_v_line.prg  >> oled_spi.lib
type oled_check_driver.prg oled_clear_buffer.prg oled_init_display.prg >> oled_spi.lib
type oled_update_display.prg  oled_fill_bg.prg oled_print_char.prg >> oled_spi.lib
type oled_print_string.prg gfx_display.prg >> oled_spi.lib

copy oled_spi.lib ..\lib\oled_spi.lib
