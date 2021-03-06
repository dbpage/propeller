{{ miniIMU9v2_simple.spin
┌─────────────────────────────────────┬──────────────┬──────────┬────────────┐
│ Pololu miniIMU-9 v2 drver           │ BR           │ (C)2016  │ 29Jul2016  │
├─────────────────────────────────────┴──────────────┴──────────┴────────────┤
│ A simple/lightweight driver object for the Pololu miniIMU-9 v2  9 DOF      │
│ accelerometer, magnetometer, gyro module.  Uses a stripped-down version    │ 
│ of Jon's jm_i2c object for i2c interface communication.                    │
│                                                                            │
│ Jon's original i2c object is here:                                         │
│ http://obex.parallax.com/object/311                                        │
│                                                                            │
│ See also:                                                                  │
│ https://www.pololu.com/product/1268                                        │
│                                                                            │
│ See end of file for terms of use.                                          │
└────────────────────────────────────────────────────────────────────────────┘
FIXME: not 100% sure I've gotten the magnetometer interface code working right...seems flakey


REFERENCE CIRCUIT for connecting miniIMU9v2:    
                                                  
       miniIMU-9 V2                      
      ┌───────────┐                       
      ┤ •      SCL┣─── to Prop pin assigned to SCL              
      ┤        SDA┣─── to Prop pin assigned to SDA
      ┤        GND┣─── to GND 
      ┤        Vin┣─── 2.7v to 5v in      Note: either connect 5v to Vin
      ┤        Vdd┣─── 3.3v in or out           OR connect 3.3v to Vdd
      └───────────┘                              NOT both!  See pololu data sheet     
}}
con

  'default device addresses
  acc_adr = %0011_0010   '$19 <<1
  mag_adr = %0011_1100
  gyr_adr = %1101_0110                                      

  'acel & gyro register addresses
  ctrl1 = $20
  ctrl4 = $23
  accx1 = $28 '+ %1000_0000          'uncomment to assert multi byte read/write mode
  accy1 = $2a '+ %1000_0000
  accz1 = $2c '+ %1000_0000
  gyrx1 = $28 '+ %1000_0000         
  gyry1 = $2a '+ %1000_0000
  gyrz1 = $2c '+ %1000_0000
  astat = $27
  gstat = $27

  'mag register addresses
  ctrla = $00
  ctrlm = $01
  ctrlr = $02
  magx1 = $03  + %1000_0000
  magy1 = $07
  magz1 = $05
  mstat = $09
  

var
long mx,my,mz

pub readmx
''read magnetometer x-axis.  Must call updatemag first to update the sensor readings!

  return mx

pub readmy
''read magnetometer y-axis.  Must call updatemag first to update the sensor readings!

  return my

pub readmz
''read magnetometer z-axis.  Must call updatemag first to update the sensor readings!

  return mz

pub updatemag|t1,t2
''read all magnetometer/compass axes and store in mx, my, mz vars

  start                                     
  write(mag_adr)                            'send device address 
  write(magx1)                              'send command (register address)
  start                                     'send start sequence
  write(mag_adr+1)                          'send device address (+ read bit set)
  t1 := read(ACK)                           'read byte
  t2 := read(ACK)
  mx := ((t1<<8 + t2)<<16)~>16              'catenate bytes, put MSB in sign bit slot
  t1 := read(ACK)                           
  t2 := read(ACK)
  mz := ((t1<<8 + t2)<<16)~>16              
  t1 := read(ACK)                          
  t2 := read(NAK)
  my := ((t1<<8 + t2)<<16)~>16              
  stop                                      
  return  


pub readgyr(axis)|t1,t2
''read a gyro axis (input is register address for x, y, or z axis)
''example call from a higher level object: acel_x := imu.readgyr(imu#gyrx1)

  t1 := readreg(gyr_adr,axis+1)
  t2 := readreg(gyr_adr,axis)
  return ((t1<<8 + t2)<<16)~>16             'cat bytes, put MSB in sign bit slot & drop last 4 bits


pub readacc(axis)|t1,t2
''read an accelerometer axis (input is register address for x, y, or z axis)
''example call from a higher level object: acel_x := imu.readgyr(imu#accx1)

  t1 := readreg(acc_adr,axis+1)
  t2 := readreg(acc_adr,axis)
  return ((t1<<8 + t2)<<16)~>20             'cat bytes, put MSB in sign bit slot & drop last 4 bits


pub readReg(devadr,reg)|tmp
''read value from register
''arguments are: device address, register address to read from
''See constants section at top of this object for valid input values

  start                                     
  write(devadr)                             'send device address 
  write(reg)                                'send command (register address)
  start                                     'send start sequence
  write(devadr+1)                           'send device address (+ read bit set)
  tmp := read(NAK)                          'read byte
  stop                                      
  return tmp


pub writeReg(devadr,regadr,val)|tmp
''read value from register
''arguments are: device address, register address, and value to write
''See constants section at top of this object for valid input values

  start                                     
  write(devadr)                            'send device address 
  write(regadr)                            'send register address
  write(val)                                'write byte
  stop
  

con
' *****************************************
' everything from this point on is code snippets from Jon's JM_I2C object
' *****************************************
con
   #0, ACK, NAK
  #28, BOOT_SCL, BOOT_SDA                                       ' Propeller I2C pins


dat
scl             long    -1                                      ' clock pin of i2c buss
sda             long    -1                                      ' data pin of i2c buss
devices         long    0                                       ' devices sharing driver


pub setup

'' Setup I2C using default (boot EEPROM) pins

  setupx(BOOT_SCL, BOOT_SDA)
         

pub setupx(sclpin, sdapin)

'' Define I2C SCL (clock) and SDA (data) pins
'' -- will not redefine pins once defined
''    * assumes all I2C devices on same pins

  if (devices == 0)                                             ' if not defined
    longmove(@scl, @sclpin, 2)                                  '  copy pins
    dira[scl] := 0                                              '  float to pull-up
    outa[scl] := 0                                              '  write 0 to output reg
    dira[sda] := 0
    outa[sda] := 0

  repeat 9                                                      ' reset device
    dira[scl] := 1
    dira[scl] := 0
    if (ina[sda])
      quit

  devices += 1                                                  ' increment device count


pub kill

'' Clear I2C pin definitions

  if (devices > 0)
    if (devices == 1)                                           ' if last device
      longfill(@scl, -1, 2)                                     ' undefine pins
      dira[scl] := 0                                            ' force to inputs
      dira[sda] := 0
    devices -= 1                                                ' decrement device count


con

  { ===================================== }
  {                                       }
  {  L O W   L E V E L   R O U T I N E S  }
  {                                       }
  { ===================================== }
  
        
pub start

'' Create I2C start sequence
'' -- will wait if I2C bus SDA pin is held low

  dira[sda] := 0                                                ' float SDA (1)
  dira[scl] := 0                                                ' float SCL (1)
  repeat while (ina[scl] == 0)                                  ' allow "clock stretching"

  outa[sda] := 0
  dira[sda] := 1                                                ' SDA low (0)

  
pub write(i2cbyte) | ackbit

'' Write byte to I2C buss

  outa[scl] := 0
  dira[scl] := 1                                                ' SCL low

  i2cbyte <<= constant(32-8)                                    ' move msb (bit7) to bit31
  repeat 8                                                      ' output eight bits
    dira[sda] := ((i2cbyte <-= 1) ^ 1)                          ' send msb first
    dira[scl] := 0                                              ' SCL high (float to p/u)
    dira[scl] := 1                                              ' SCL low

  dira[sda] := 0                                                ' relase SDA to read ack bit
  dira[scl] := 0                                                ' SCL high (float to p/u)  
  ackbit := ina[SDA] == 0                                            ' read ack bit
  dira[scl] := 1                                                ' SCL low

  return (ackbit)


pub read(ackbit) | i2cbyte

'' Read byte from I2C buss

  outa[scl] := 0                                                ' prep to write low
  dira[sda] := 0                                                ' make input for read

  repeat 8
    dira[scl] := 0                                              ' SCL high (float to p/u)
    i2cbyte := (i2cbyte << 1) | ina[sda]                        ' read the bit
    dira[scl] := 1                                              ' SCL low
                             
  dira[sda] := !ackbit                                          ' output ack bit 
  dira[scl] := 0                                                ' clock it
  dira[scl] := 1

  return (i2cbyte & $FF)


pub stop

'' Create I2C stop sequence 

  outa[sda] := 0
  dira[sda] := 1                                                ' SDA low
  
  dira[scl] := 0                                                ' float SCL
  repeat while (ina[scl] == 0)                                  ' hold for clock stretch
  
  dira[sda] := 0                                                ' float SDA


DAT
{{
┌────────────────────────────────────────────────────────────────────────────┐
│                              TERMS OF USE: MIT License                     │                                                            
├────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy│ 
│of this software and associated documentation files (the "Software"), to    │
│deal in the Software without restriction, including without limitation the  │
│rights to use, copy, modify, merge, publish, distribute, sublicense, and/or │
│sell copies of the Software, and to permit persons to whom the Software is  │
│furnished to do so, subject to the following conditions:                    │
│The above copyright notice and this permission notice shall be included in  │
│all copies or substantial portions of the Software.                         │
│                                                                            │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  │
│IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    │
│FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE │
│AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     │
│FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         │
│DEALINGS IN THE SOFTWARE.                                                   │
└────────────────────────────────────────────────────────────────────────────┘
}} 