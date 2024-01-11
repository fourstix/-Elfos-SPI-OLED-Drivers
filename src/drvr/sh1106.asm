;-------------------------------------------------------------------------------
; sh1106 - a video driver for updating a SH1106 OLED display via
; the SPI Expansion Board for the 1802/Mini Computer. 
;
; Copyright 2024 by Gaston Williams
;
; Based on code from the Elf-Elfos-OLED library
; Written by Tony Hefner
; Copyright 2022 by Tony Hefner
;
; Based on code from Adafruit_SH110X library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright xxx by Adafruit Industries
;
; SPI Expansion Board for the 1802/Mini Computer hardware
; Copyright 2022 by Tony Hefner 
;-------------------------------------------------------------------------------
; Based on software written by Michael H Riley
; Thanks to the author for making this code available.
; Original author copyright notice:
; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

#include    ../include/bios.inc
#include    ../include/kernel.inc
#include    ../include/ops.inc
#include    ../include/sysconfig.inc
#include    ../include/sh1106.inc
#include    ../include/oled.inc

; ************************************************************
; This block generates the Execution header
; It occurs 6 bytes before the program start.
; ************************************************************
                    ORG     02000h-6  ; Header starts at 01ffah
                dw  02000h            ; Program load address
                dw  endrom-2000h      ; Program size
                dw  02000h            ; Program execution address

                    ORG     02000h    ; code starts here
                br  start             ; Jump past build info to code

; Build information                   
binfo:          db  1+80h         ; Month, 80H offset means extended info
                db  11            ; Day
                dw  2024          ; Year

; Current build number
build:          dw  3

; Must end with 0 (null)
copyright:      db      'Copyright (c) 2024 by Gaston Williams',0
                  
start:          lda  ra               ; move past any spaces
                smi  ' '
                bz   start
                dec  ra               ; move back to non-space character
                lda  ra               ; check for nonzero byte
                lbz  check            ; jump if no arguments
                smi  '-'              ; check for argument
                lbnz  bad_arg
                ldn  ra               ; check for correct argument
                smi  'u'
                lbz  unload           ; unload video driver
                lbr  bad_arg          ; anything else is a bad argument
                      
check:          LOAD rd, O_VIDEO      ; check if video driver is  loaded 
                lda  rd               ; get the vector long jump command
                smi  0C0h             ; if not long jump, assume never loaded
                lbnz load            
                lda  rd               ; get hi byte of address
                smi  03h              ; check to see if points to Kernel return
                lbnz already          ; if not, assume driver is already loaded
                ldn  rd               ; get the lo byte of address
                smi  07eh             ; check to see if points to kernel return 
                lbnz already          ; if not, assume driver is already loaded                    
                                  
load:           LOAD rc, END_DRIVER - BEGIN_DRIVER        ; load block size
                LOAD R7, 0FF44H       ; page aligned (FF) & named permanent (44) 
                CALL O_ALLOC          ; Call Elf/OS allocation routine

                lbdf fail             ; DF = 1 means Elf/OS can't allocate block                                                                  
                LOAD rd, O_VIDEO      ; save video buffer page in kernel
                ldi  0c0h             ; 'C0' is lbr to video driver address
                str  rd               ; save long jump instruction in kernel
                inc  rd               ; move to address for long jump
                ghi  rf               ; rf has address of allocated block
                str  rd               ; save hi byte in kernel vector
                inc  rd               ; move to lo byte of address                                                              
                glo  rf               ; save lo byte in kernel vector
                str  rd
                inc  rd
                                    
                COPY rf, rd           ; move destination in rf into rd               
                LOAD rf, BEGIN_DRIVER ; rf points to source driver code
                ; RC already has the count of bytes allocated
                ; LOAD rc, END_DRIVER - BEGIN_DRIVER  ; load block size to move
                CALL f_memcpy         ; copy the video driver into memory

                lbr  done             ; we're done!
                                                                                               
unload:         LOAD rd, O_VIDEO+1    ; point rd to video driver vector in kernel
                lda  rd               ; get hi byte
                phi  rf
                ldn  rd               ; get lo byte
                plo  rf               ; rf points to video driver in memory
                CALL O_DEALLOC        ; De-alloc memory to unload video driver
                
                                      ; Dealloc always works
                LOAD rd, O_VIDEO+1    ; point rd back to hi byte of address
                ldi  03h              ; point O_VIDEO to kernel return at 037eh
                str  rd
                inc  rd               ; advance to lo byte of address
                ldi  07eh             ; point O_VIDEO to kernel return at 037eh
                str  rd
                LOAD rf, removed      ; show message that driver was unloaded
                CALL O_MSG 
                RTN                   ; return to Elf/OS
                
done:           LOAD rf, loaded       ; show message that driver is loaded
                CALL O_MSG 
                LOAD rf, copyright
                CALL O_MSG
                LOAD rf, crlf
                CALL O_MSG    
                RTN                   ; return to Elf/OS 
                      
                      org 2100h       ; make sure to start driver on page boundary
BEGIN_DRIVER:   bz    get_type        ; 0 = get OLED type
                smi   01h
                bz    init_oled       ; 1 = init OLED
                smi   01h
                bnz   chk_show
                ldi   $00
                br    load_oled       ; 2 = clear OLED
chk_show:       smi   01h 
                bnz   unknown
                ldi   $FF
                br    load_oled       ; 3 = show OLED
unknown:        STC                   ; DF = 1 for error (unknown API call)
                RTN
           


;-------------------------------------------------------------------------------
; Name: get_type
;
; Get information about the driver type.
; 
; Returns: rf - pointer to oled type string 'SH1106'
;-------------------------------------------------------------------------------
get_type:       ldi   OledType.0      ; load ptr to type string
                plo   rf              ; put in rf
                ghi   r3              ; get hi byte for current block from p
                phi   rf              ; rf points to OLED type string            
                CLC                   ; DF = 0 for success
                RTN

;-------------------------------------------------------------------------------
; Name: init_oled
;
; Initializes the OLED display using the SH1106 controller chip connected
; to port 0 of the 1802/Mini SPI interface. 
;
; The bits of the SPI control port are as follows:
; Bit 7 - If set to 0, the low 6-bits of the control port are set.
;         If set to 1, the low 6-bits of the DMA count are set.
; Bit 6 - Setting this bit to 1 starts a DMA out operation.
; Bit 5 - Setting this bit to 1 starts a DMA in operation (not used here).
; Bit 4 - The MSB of the DMA count when the count is written.
; Bit 3 - CS1 - used by the micro-SD card.
; Bit 2 - CS0 - Chip Select for the OLED port.
; Bit 1 - Active low reset for the OLED display.
; Bit 0 - 0 = Display Control, 1 = Display Data.
;
; Parameters: None
;
; Return: None
;-------------------------------------------------------------------------------
init_oled:      push    rc

                sex     r3

              #if SPI_GROUP
                out     EXP_PORT
                db      SPI_GROUP
              #endif

                out     SPI_CTL
                db      IDLE

                ldi     83            ; delay 1 ms
                plo     rc
delay1:         dec     rc
                glo     rc
                bnz    delay1

                out     SPI_CTL
                db      RESET

                mov     rc, 830       ; delay 10 ms
delay2:         dec     rc
                brnz   rc, delay2

                out     SPI_CTL
                db      IDLE

                mov     rc, 830       ; delay 10 ms
delay3:         dec     rc
                brnz   rc, delay3

                ldi     dma_init.0
                plo     r0            ; lo nibble has display data address
                ghi     r3            ; set hi nibble for correct page
                phi     r0            ; r0 points to display data in memory
                sex     r0            ; output data here

                out     SPI_CTL       ; Set DMA count
                out     SPI_CTL       ; Start control DMA out
                ;--- dma occurs here to send rest of display data
                sex     r3

                out     SPI_CTL
                db      IDLE

              #if SPI_GROUP
                out     EXP_PORT
                db      NO_GROUP
              #endif

                sex     r2

                pop     rc
                CLC
                RTN

;-------------------------------------------------------------------------------
; Name: load_oled
;
; Load zeros into the display to clear the display or copy a complete
; image from frame buffer to display using the SH1106 controller chip
; connected to port 0 of the 1802/Mini SPI interface. 
;
; The bits of the SPI control port are as follows:
; Bit 7 - If set to 0, the low 6-bits of the control port are set.
;         If set to 1, the low 6-bits of the DMA count are set.
; Bit 6 - Setting this bit to 1 starts a DMA out operation.
; Bit 5 - Setting this bit to 1 starts a DMA in operation (not used here).
; Bit 4 - The MSB of the DMA count when the count is written.
; Bit 3 - CS1 - used by the micro-SD card.
; Bit 2 - CS0 - Chip Select for the OLED port.
; Bit 1 - Active low reset for the OLED display.
; Bit 0 - 0 = Display Control, 1 = Display Data.
;
; Parameters: D = 0, clear display  (load all zeros)
;             D = nonzero, load display with buffer data
;             rf - pointer to 1K frame buffer.
;
; Return: None
;-------------------------------------------------------------------------------
load_oled:      plo     re            ; save D in scratch register
                push    rc            ; save reg used as byte count
                push    r8            ; save reg used as page count

                sex     r3

              #if SPI_GROUP
                out     EXP_PORT
                db      SPI_GROUP
              #endif

                out     SPI_CTL
                db      COMMAND
                out     SPI_DATA
                db      SET_COL_LOW
                out     SPI_DATA
                db      SET_COL_HIGH
                out     SPI_DATA
                db      SET_START_LINE
                out     SPI_CTL
                db      IDLE
                
                mov     r8, 0         ; set up page counter

disp_page:      out     SPI_CTL
                db      COMMAND
                sex     r2
                ldi     SET_PAGE
                str     r2            ; put base page in m(x)
                glo     r8            ; get page count
                add                   ; D = M(X) + D
                str     r2          
                out     SPI_DATA      ; send page command
                dec     r2            ; fix stack pointer
                inc     r8            ; bump counter
                sex     r3
                out     SPI_DATA
                db      SET_COL_LOW   ; set lower column address
                out     SPI_DATA
                db      SET_COL_HIGH  ; set higer column address
                out     SPI_CTL
                db      IDLE

                out     SPI_CTL
                db      DATA

                sex     r2

                mov     rc, 128       ; send a whole page of data at once

d_loop:         glo     re            ; check D value
                bz      d_skip        ; if D = 0, clear display instead
                lda     rf            ; get byte from buffer
d_skip:         str     r2            ; save at M(X)

                out     SPI_DATA      ; send byte
                dec     r2            ; fix stack pointer

                dec     rc
                brnz    rc, d_loop        

                sex     r3            ; set x for next page commands or exit

                glo     r8            ; get the page count
                smi     08            ; check to see if we have sent all 8 pages

                bnf     disp_page     ; if negative (DF = 0) fill next page

                out     SPI_CTL       ; done updating display, prepare to exit
                db      IDLE

              #if SPI_GROUP
                out     EXP_PORT
                db      NO_GROUP
              #endif

                sex     r2

                pop     r8            ; restore reg used as page count
                pop     rc            ; restore reg used as byte count
                CLC
                RTN


            ;---------------------------------------------
            ; SPI data for DMA transaction
            ;---------------------------------------------

dma_init:       db      $19 | $80     ; set low 6-bits of count
                                      ; = (init_end - init_start)
                db      $46           ; enable control dma

            ;---------------------------------------------
            ; Init sequence for SH1106 displays.          
            ; Source: Adafruit SH1106 Display driver      
            ; https://github.com/adafruit/Adafruit_SH110x 
            ;---------------------------------------------
init_start:     db      SET_DISP_OFF                    ; 0xAE,
                db      SET_DISP_CLK_DIV, $80           ; 0xD5, 0x80
                db      SET_MUX_RATIO, DISP_HEIGHT - 1  ; 0xA8, 0x3F,
                db      SET_DISP_OFFSET, $00            ; 0xD3, 0x00, 
                db      SET_START_LINE                  ; 0x40, 
                db      SET_CHARGEPUMP, $14             ; 0x8D, 0x14            
                db      SET_MEM_ADDR_MODE, HORZ_MODE    ; 0x20, 0x00
                db      SET_SEG_REMAP_ON                ; 0xA1,             
                db      SET_COM_SCAN_DEC                ; 0xC8,
                db      SET_COM_PIN_CFG, $12            ; 0xDA, 0x12,
                db      SET_CONTRAST, $CF               ; 0x81, 0xCF,
                db      SET_PRECHARGE, $F1              ; 0xD9, 0xF1,
                db      SET_VCOM_DETECT, $40            ; 0xDB, 0x40,
                db      SET_ALL_ON_RESUME               ; 0xA4
                db      SET_NORMAL_DISP                 ; 0xA6 
                db      SET_DISP_ON                     ; 0xAF
init_end:

; -----------------------------------------------------------
;           ID String for memory block
;------------------------------------------------------------
BlockMarker:    db 0                  ; zero byte before memory id string
OledType:       db 'SH1106',0         ; oled type string for memory block id
END_DRIVER:     db 0                  ; one zero byte for padding at end

;------ error handling for memory allocation and loading functions
fail:           LOAD RF, failed       ; show error message
                CALL O_MSG
                ABEND                 ; return to Elf/OS with error
                    
;------ show configuration when the driver is already loaded                                   
already:        ldi  V_OLED_TYPE
                CALL O_VIDEO          ; get type of OLED video driver
                CALL O_MSG            
                LOAD rf, present      ; show message driver already loaded
                CALL O_MSG
                RTN
                    
;------ show usage message for an invalid argument
bad_arg:        LOAD rf, usage        ; print bad arg message and end
                CALL O_MSG
                RTN

;------ message strings
failed:         db   'Error: OLED video driver was *NOT* loaded.',10,13,0
loaded:         db   'OLED video driver loaded.',10,13,0
usage:          db   'Loads OLED video driver. Use -u option to unload the video driver.',10,13,0 
removed:        db   'OLED video driver unloaded.',10,13,0
present:        db   ' OLED video driver is already in memory.',10,13,0
crlf:           db   10,13,0                 

;------ define end of execution block
endrom: equ     $
