;-------------------------------------------------------------------------------
; Check for an Elf/OS video driver for an OLED display  
; connected to port 0 of the 1802/Mini SPI interface.
;
; Copyright 2023 by Gaston Williams
;
; Based on code from the Elf-Elfos-OLED library
; Written by Tony Hefner
; Copyright 2022 by Tony Hefner
;
; SPI Expansion Board for the 1802/Mini Computer hardware
; Copyright 2022 by Tony Hefner 
;-------------------------------------------------------------------------------

#include    ../include/ops.inc
#include    ../include/bios.inc
#include    ../include/kernel.inc
#include    ../include/oled.inc

                      proc oled_check_driver
                load  rd, O_VIDEO     ; check if video driver is  loaded 
                lda   rd              ; get the vector long jump command
                smi   0C0h            ; if not long jump, assume never loaded
                lbnz  no_driver              
                lda   rd              ; get hi byte of address
                smi   03h             ; check to see if points to Kernel return
                lbnz  loaded          ; if not, assume driver is already loaded
                ldn   rd              ; get the lo byte of address
                smi   07eh            ; check to see if points to kernel return  
                lbnz  loaded          ; if not, assume driver is already loaded

no_driver:      load  rf, no_oled
                call  O_MSG
                stc
                return
                    
loaded:         clc 
                return

no_oled:        db    'No OLED driver loaded.',10,13,0
                      endp
