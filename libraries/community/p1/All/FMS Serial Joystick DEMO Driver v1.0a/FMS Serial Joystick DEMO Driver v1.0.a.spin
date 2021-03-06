{{
*******************************************
* FMS Serial Joystick DEMO Driver v1.0.a  *
* Author: Beau Schwabe                    *
* Copyright (c) 2010 Parallax             *
* See end of file for terms of use.       *
*******************************************

Revision History:
                  Version 1.0   - (04-19-2010) original file created
                  Version 1.0.a - (04-19-2010) added Zhen Hua 5 byte protocol 

Supported FMS protocols:

FMS PIC  9600 baud (Generic)
FMS PIC  9600 baud (0xF0+ sync)  <- Default
FMS PIC 19200 baud (0xFF  sync)
Zhen Hua 5 byte protocol

}}

CON
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000


CON{{                                                   Notes

This object uses the PPJoy driver originally developed by Deon van der Westhuysen and can be located here...

http://www.simtel.net/product.download.php?id=75176

... or a Google search should lead you to the correct file.  PPJoySetup.zip is about 1.8 Megs

======================================================================================================
Install Notes:
 1) Download PPJoySetup.zip on your machine
 2) Extract files from zip file
 3) Run Setup.exe by clicking on the Setup Icon
 4) After installation, another folder window will be created and pop up...
 5) Click on the 'Configure Joysticks Shortcut' ... a configuration window pops up...
 6) You want to ADD a Joystick so click ADD
 7) Under 'Parallel Port' select 'Virtual JoySticks' and then ADD
 8) Windows should detect 'New Hardware' ... as a 'Parallel Port Joystick' go ahead and install.
 9) After this step your hardware should be ready to use
10) Now you can click 'Done' in the 'PPJoy Joystick and Gamepad configuration utility'
======================================================================================================


======================================================================================================
Using/Testing Hardware Propeller side:

1) Run THIS DEMO by pressing F11

2) Make note of the COM port that the Propeller uses or use F7 to identify the Propeller, you may need
   to change the USB COM port number if it's higher than COM8 (see below under 'Changing the USB COM port')

3) This Demo runs the 'FMS PIC 9600 baud (0xF0+ sync)' by default, but you can change it to any of the
   supported protocols. (see top of this document)
======================================================================================================


======================================================================================================
Using/Testing Hardware PC side:

In order to use the Serial Joystick, you must run 'PPJoyCOM' and direct it to the proper COM port
you are connected to.  This must continue to run as long as you are using the virtual joystick.

1) Start -> Parallel Port Joystick -> PPJoyCOM

2) For testing you can pull up the Game Controllers from the Control Panel
   Start-> Control Panel -> Game Controllers -> (You should see the PPJoy Virtual Joystick)->
           Click on 'Properties' to see all of the Joystick 'features' in action.

3) If this demo is running correctly, the Dial control should be moving.

                                                                                         
======================================================================================================


======================================================================================================
Changing the USB COM port:

The downside to all this is that PPJoy has a limitation of being able to only use COM1 to COM8.
Often the enumeration of the USB2Serial will assign a COMport higher than 8.   To solve this, on
one computer I had to go into the device manager and manually set the COMport to a lower value
under 8. On another machine this wasn't necessary.   But just in case you need to go there,

Start -> Control Panel -> System -> Hardware -> Device Manager ->Ports (COM & LPT)->
         USB Serial Port(COM?)->(Right Click Properties)->Port Settings->Advanced->
         COM Port Number <<<--- Change this to one that is NOT in use and is below COM8

Note: Although I haven't tried this a second option would be to use a Port Re-mapping software that would
      redirect the COM port to a lower number.
======================================================================================================


======================================================================================================
Customizing the Virtual Joystick:

It is beyond the scope of this DEMO, but since PPJoy creates a virtual Joystick, it gives you several
features that make it a 'monster' joystick.  This DEMO is designed to work with the PPJoy default settings
right out of the box from a fresh install, however it may not be a desirable configuration for your particular
setup.  Since Windows now sees this virtual joystick as a valid joystick, you can use the option under the
Control panel to configure and customize the virtual joystick to your liking.

Start -> Control Panel -> Parallel Port Joysticks ->
         (Select the PPJoy virtual joystick) and then select Mapping ->
         (Check 'Set a custom mapping for this controller') Next ->

         Now just follow the prompts and a little bit of trial and error
         to customize your ultimate Propeller powered joystick.

======================================================================================================
    

}}
OBJ
    Ser       : "FullDuplexSerial"

PUB MainDEMO
'   FMS_PIC_9600_baud_Generic
    FMS_PIC_9600_baud_0xF0_sync
'   FMS_PIC_19200_baud_0xFF_sync
'   Zhen_Hua_5_byte_protocol

PUB FMS_PIC_9600_baud_Generic|n
    Ser.start(31, 30, 0, 9600)                          '' Initialize serial communication to the PC
    repeat
     repeat n from $00 to $EF
      ser.tx{--}($F0+10)            '$F0 + number of channels used (See Note below)
      ser.tx{01}($00)               'Buttons            %00000000 to %11111111
      ser.tx{02}($00)               'X axis             $00 to $EF
      ser.tx{03}($00)               'Y axis             $00 to $EF
      ser.tx{04}($00)               'Z axis             $00 to $EF
      ser.tx{05}($00)               'Z rotation         $00 to $EF
      ser.tx{06}($00)               'Slider             $00 to $EF
      ser.tx{07}($00)               'X rotion           $00 to $EF
      ser.tx{08}($00)               'Y rotion           $00 to $EF
      ser.tx{09}($00)               'Dial               $00 to $EF
      ser.tx{10}(n)                 'Point of View Hat  $00 to $EF
      repeat 5000                   'Delay

{{   Note:

     - Some Generic receivers don't care about the number of Channels, so if the BYTE is $F0 or greater
       it's considered a SYNC with the exception of BUTTONS.  The PPJoy driver only seems to care that
       the Sync value is $F0 or greater.  

     - With the exception of the BUTTONS and the SYNC, if the transmitted BYTE is above $EF,
       the data will be considered invalid.

}}


PUB FMS_PIC_9600_baud_0xF0_sync|n
    Ser.start(31, 30, 0, 9600)                          '' Initialize serial communication to the PC
    repeat
     repeat n from 100 to 200
      ser.tx{--}($F0+8)             '$F0 + number of channels used minus 1
      ser.tx{01}(%00000000)         'Buttons            %00000000 to %11111111
      ser.tx{02}(100)               'X axis             100 to 200              100 = 1ms ; 200 = 2ms
      ser.tx{03}(100)               'Y axis             100 to 200              100 = 1ms ; 200 = 2ms
      ser.tx{04}(100)               'Z axis             100 to 200              100 = 1ms ; 200 = 2ms
      ser.tx{05}(100)               'Z rotation         100 to 200              100 = 1ms ; 200 = 2ms
      ser.tx{06}(100)               'Slider             100 to 200              100 = 1ms ; 200 = 2ms
      ser.tx{07}(100)               'X rotion           100 to 200              100 = 1ms ; 200 = 2ms
      ser.tx{08}(100)               'Y rotion           100 to 200              100 = 1ms ; 200 = 2ms
      ser.tx{09}(n)                 'Dial               100 to 200              100 = 1ms ; 200 = 2ms
      repeat 5000                   'Delay

{{   Note:

     - The formula for converting a servo signal to an FMS serial value is as follows...
       FMS value = INT((Servo value in us / 10)

     - With the exception of the BUTTONS and the SYNC, if the transmitted BYTE is above 200 or below 100,
       the data will be considered invalid.

}}



PUB FMS_PIC_19200_baud_0xFF_sync|n
    Ser.start(31, 30, 0, 19200)                          '' Initialize serial communication to the PC
    repeat
     repeat n from $00 to $FE
      ser.tx{--}($FF)               '$FF sync
      ser.tx{01}($00)               'X axis             $00 to $FE              $00 = 760us ; $FE = 2284us
      ser.tx{02}($00)               'Y axis             $00 to $FE              $00 = 760us ; $FE = 2284us
      ser.tx{03}($00)               'Z axis             $00 to $FE              $00 = 760us ; $FE = 2284us
      ser.tx{04}($00)               'Z rotation         $00 to $FE              $00 = 760us ; $FE = 2284us
      ser.tx{05}($00)               'Slider             $00 to $FE              $00 = 760us ; $FE = 2284us
      ser.tx{06}($00)               'X rotion           $00 to $FE              $00 = 760us ; $FE = 2284us
      ser.tx{07}($00)               'Y rotion           $00 to $FE              $00 = 760us ; $FE = 2284us
      ser.tx{08}($00)               'Dial               $00 to $FE              $00 = 760us ; $FE = 2284us
      ser.tx{09}(n)                 'Point of View Hat  $00 to $FE              $00 = 760us ; $FE = 2284us
      repeat 5000                   'Delay

{{   Note:

     - The formula for converting a servo signal to an FMS serial value is as follows...
       FMS value = INT((Servo value in us - 760)/6)

     - With the exception of the SYNC, if the transmitted BYTE is $FF the data will be considered invalid.

}}

PUB Zhen_Hua_5_byte_protocol|n
    Ser.start(31, 30, 0, 19200)                          '' Initialize serial communication to the PC
    repeat
     repeat n from 50 to 200
      ser.tx{--}(BitReverse($F7))                        '$F7 sync
      ser.tx{01}(BitReverse(50))                         'X axis             50 to 200
      ser.tx{02}(BitReverse(50))                         'Y axis             50 to 200 
      ser.tx{03}(BitReverse(50))                         'Z axis             50 to 200
      ser.tx{04}(BitReverse(n))                          'Z rotation         50 to 200
      repeat 5000                   'Delay

{{   Note:

     - With the exception of the SYNC, if the transmitted BYTE is above 200 or below 50,
       the data will be considered invalid.

}}

PUB BitReverse(data)
    result := data ><= 8

DAT
{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}

                              