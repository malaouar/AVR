
This is the IRMP "Infrared-Multiprotocol-Decoder" By Frank M. 

http://www.mikrocontroller.net/articles/IRMP


- Try any IR receiver with this circuit.
- Use any Termianl program (hyperterminal, puty, cutecom, minicom ....) under WIN or LINUX.
   9600 8N1
- Your USB-to-COM adaptor may need an inverter after the TXD output.
========================================
- ATEMEGA8  Inetrnal oscillator 8MHz:

    Hfuse: 1101 1001 ---> D9  (default) 
    Lfuse: 1110 0100 ---> E4   (0100 --> internal 8MHz)



To Get the calibration byte to put in OSCAL  (look at code in main) use avrdude :
 commande:
avrdude -p m8 -c usbasp -U calibration:r:calibration.dat:r -F

You get a file "calibration.dat". open it with HxD u get 4 bytes like these:

	B6 B5 AF B0

These are the four calibration bytes in order, for 1 MHz, 2 MHz, 4 MHz, and 8 MHz.
So our value is 0xB0 (8MHz)