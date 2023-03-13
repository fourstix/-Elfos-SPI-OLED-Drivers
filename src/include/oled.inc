; Kernel vector for Video Driver
O_VIDEO:            equ 0456h

; OLED Video Driver functions
V_OLED_TYPE:        equ 00h
V_OLED_INIT:        equ 01h
V_OLED_CLEAR:       equ 02h
V_OLED_SHOW:        equ 03h

; common routine
                    extrn check_oled_driver
