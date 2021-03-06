{{
Wii MotionPlus Driver Demo Object v1.1
By Pat Daderko (DogP)

Based on a Wii nunchuck example project from John Abshier, which was based on code originally by João Geada

This demo object repeatedly polls the Wii MotionPlus and writes the gyro data to the serial port (at 115200bps),
reusing the pins used for programming.  Added in v1.1 is the ability to use the MotionPlus with an extension
controller plugged in (Nunchuck or Classic Controller).  The rotation data is also now in degrees/second, which
is being computed by dividing the raw value by 20 if at low speed, or dividing by 5 if at high speed (according
to the flags).  

Diagram below is showing the pinout looking into the connector on the top (which plugs into the Wii Remote)
 _______ 
| 1 2 3 |
|       |
| 6 5 4 |
|_-----_|

1 - SDA 
2 - 
3 - VCC
4 - SCL 
5 - 
6 - GND

This is an I2C peripheral, and requires a pullup resistor on the SDA line
If using a prop board with an I2C EEPROM, this can be connected directly to pin 28 (SCL) and pin 29 (SDA)
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  MP_ONLY       = 4 'MotionPlus only
  MP_NUN        = 5 'MotionPlus w/ Nunchuck
  MP_CLASSIC    = 7 'MotionPlus w/ Classic Controller


OBJ
  MP : "MotionPlus"
  uart : "Extended_FDSerial"

VAR
   byte mode
  
PUB init
   uart.start(31, 30, 0, 115200) 'start UART at 115200 on programming pins
   mode := MP_NUN 
   MP.init(28,29,mode) 'initialize I2C MotionPlus on existing I2C pins
   MP.enMotionPlus 'enable MotionPlus (write enable sequence to hardware)
   mainLoop 'run main app

PUB mainLoop | i
 repeat
    MP.readMotionPlus 'read data from MotionPlus
    MP.readMotionPlus 'read data from MotionPlus
         
    'output data read to serial port
    uart.dec(MP.rotate_x)
    uart.tx(44)
    uart.dec(MP.rotate_y)
    uart.tx(44)
    uart.dec(MP.rotate_z)      
    uart.tx(13)

    'if an extension is connected    
    if (MP.ext)
      if mode==MP_NUN 'if in Nunchuck mode, output Nunchuck data
        uart.dec(MP.joyX)
        uart.tx(44)
        uart.dec(MP.joyY)
        uart.tx(44)
        uart.dec(MP.accelX)
        uart.tx(44)
        uart.dec(MP.accelY)
        uart.tx(44)
        uart.dec(MP.accelZ)
        uart.tx(44)
        uart.dec(MP.pitch)
        uart.tx(44)
        uart.dec(MP.roll)
        uart.tx(44)
        uart.dec(MP.buttonC)
        uart.tx(44)
        uart.dec(MP.buttonZ)
        uart.tx(13)
      elseif mode==MP_CLASSIC 'if in Classic Controller mode, output Classic Controller data       
        uart.dec(MP.joyLX)
        uart.tx(44)
        uart.dec(MP.joyLY)
        uart.tx(44)
        uart.dec(MP.joyRX)
        uart.tx(44)
        uart.dec(MP.joyRY)
        uart.tx(44)
        uart.dec(MP.shoulderL)
        uart.tx(44)
        uart.dec(MP.shoulderR)
        uart.tx(44)
        uart.hex(MP.buttons,4)
        uart.tx(13)
                
    waitcnt(clkfreq/64 + cnt) 'wait for a short period