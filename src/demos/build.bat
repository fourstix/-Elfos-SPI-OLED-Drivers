[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS check_oled_driver.asm

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS spaceship.asm
[Your_Path]\Link02\link02 -e spaceship.prg check_oled_driver.prg

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS clear.asm
[Your_Path]\Link02\link02 -e clear.prg check_oled_driver.prg

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS splash.asm
[Your_Path]\Link02\link02 -e splash.prg check_oled_driver.prg

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS show.asm
[Your_Path]\Asm02\asm02 -L pixiecvt.asm
[Your_Path]\Link02\link02 -e show.prg pixiecvt.prg check_oled_driver.prg

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS pixels.asm
[Your_Path]\Link02\link02 -e -s pixels.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS linetest.asm
[Your_Path]\Link02\link02 -e -s linetest.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS lines.asm
[Your_Path]\Link02\link02 -e -s lines.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS reversed.asm
[Your_Path]\Link02\link02 -e -s reversed.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS boxes.asm
[Your_Path]\Link02\link02 -e -s boxes.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS blocks.asm
[Your_Path]\Link02\link02 -e -s blocks.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS bitmaps.asm
[Your_Path]\Link02\link02 -e -s bitmaps.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS snowflakes.asm
[Your_Path]\Link02\link02 -e -s snowflakes.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS charset.asm
[Your_Path]\Link02\link02 -e -s charset.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS helloworld.asm
[Your_Path]\Link02\link02 -e -s helloworld.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS textbg.asm
[Your_Path]\Link02\link02 -e -s textbg.prg check_oled_driver.prg -l ..\lib\gfx_oled.lib
