# AVR
Playing with attiny and atmega chips.


AVR is the microcontroller designed by Atmel, now owned by Microchip. It is very popular with hobbyists, it has seen a massive uptake in education due to the Arduino products and ecosystem.
AVRs have 32 general purpose registers and a rich instruction set. In AVRs that have SRAM (most of them), the stack is contained within SRAM instead of being limited to a built-in hardware stack this simplifies to create a compiler (like avr-gcc) for them. 

Atmel AVR Studio, is the suite provided by Atmel and contains everything you need to develop for the platform.
There is also WinAVR and the AVR-Dude suite, which are essentially the same thing except that WinAVR is for Windows and the AVR-Dude suite is for Unix-like systems.

All my experiments are done on WINDOWS with avrstudio 4.13  and winavr toolchain. You don't need to install winavr separately if you use a new version of avrstudio.
 
AVR microcontrollers are all In System Programmable (ISP). You can program them on board (ISP connector needed) or alone if the programmer has a socket or by mounting the chip on a prototyping board.
NOTE: You may need a crystal or external clock (depends on clock fuse bits configuration) when programming the AVR out of the board.

AVR programmers come in all shapes and sizes. They also come with different interfaces. They may be connected to a serial port, a parallel port, or to a USB port on the host PC. 
Some programmers like AVRISP-MKII run from AVRStudio IDE.

I used to use a homemade USBAsp programmer and avrdudess (GUI for avrdude).
Now I use an FTDI232R based USB-to-COM adaptor as an AVR programmer. Avrdudess support this programmer (bitbang mode).

The use of a bootloader allows us to avoid the use of external hardware programmers. Example of boards with bootloader is arduino and  TINY_USBBOARD.

 Fuses are used to configure important system parameters (such as the clock fuse bits, which allow you to specify the source and/or speed of the chip clock) . You will need to know how to program these fuse bytes in order to get the most out of your microcontroller (or get it working at all!).
The process of programming fuse bits involves:
    - Reading the datasheet to discover the location and settings for the bits of interest,
    - Determining the byte value for the affected fuse byte(s),
    - Actually programming the fuses on the chip.
The fuse configuration is done outside of the program. We can burn a new program with out touching to fuses.

You would sometimes want to use the RESET pin as IO (especialy with 8 or 14 pin AVRs). Doing so will disable further programming via SPI.
In this case you need an HV programmer to revert the device to factory default fuse settings so that you can use SPI to flash it again.
note that this is not to be confused the high-voltage serial programming (hvsp) available for 8 or 14 pin devices with the high-voltage parallel programming used for 20pin+ devices (i.e. tiny2313, mega8, etc).

=============================================================

Ressources:

avrfreaks: Forum, projects, wiki, .... The best !!

https://www.avrfreaks.net/

http://www.avrbeginners.net/

https://www.ladyada.net/learn/avr/programmers.html

https://www.fischl.de/usbasp/

http://diyduino.blogspot.com/2012/08/ft232r-bitbang-programmer.html

http://www.ladyada.net/library/picvsavr.html

https://www.quora.com/What-is-the-major-difference-between-PIC-and-AVR

