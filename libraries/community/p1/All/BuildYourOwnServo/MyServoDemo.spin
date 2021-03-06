{{ MyOwnServoDemo.spin


Illustrates how to build a simple servo motor.
Materials:
  - Parallax Propeller
  - SN754410 H bridge chip
  - ADC0831 Analog to digital converter chip
  - Potentiometer (I used a small 300Khm pot from an old RC servo)
  - Small DC motor (no more than 0.6 amps)
  - Battery

 Steps:

 1) Hook up the ADC converter
  

                 
              
                         ADC0831          │  Vcc(+5V)
                      ┌───────────────┐   │
   Propellerpin 2 ────┤1 -CS    VCC 8 ├───┘                
                 ┌────┤2 VIN+  CLK  7 ├─────────    Propeller pin 1
                 │  ┌─┤3 VIN-  DO   6 ├───────    Propeller  pin 0 (1K resistor)
                 │  ╋─┤4 GND   Vref 5 ├───────┐  
                 │   └───────────────┘       │                                    
                                             │
              ┌────────────────────────────┻─  +3.3V (or 5V)
                10K                              


2) Hook up the SN754410 H bridge

 
Chip Pin 1 -> Propeller Pin 3
Chip Pin 2 -> Propeller Pin 4
Chip Pin 3 -> Motor
Chip Pin 4 -> Ground
Chip Pin 5 -> Ground
Chip Pin 6 -> Motor
Chip Pin 7 -> Propeller Pin 5
Chip Pin 8 -> V+ of Battery for Motor
Chip Pin 16 -> 5V pin from propeller board

3) At this point by rotating the potentiometer you shall be able to change the speed and
direction of the motor

3) Mechanically connect the pot to the motor so that as the motor runs it rotates the potentiometer.
Make sure the motor is connected so that a negative feedback loop is achieved. If not, simply change
switch the order of the cables driving the motor.

4) By now you shall have a servo that likes to stay at a specific equilibrium point where
the pot provides a value of 127 via the ADC controller. You can easily modify the code
to change the equilibrium point at run time. 


Copyright (c) Javier R. Movellan, 2008
Distribution and use: MIT License (see below)
Versions:  1.0 March 15 2008

              
}}

CON

_CLKMODE = XTAL1 + PLL16X
_XINFREQ = 5_000_000


VAR
byte potentiometer
long stack[50]
long stack2[50]
  
OBJ
  disp : "MySerialDisplay"
  adc : "ADC0831"
  motor : "SN754410"  
  
PUB start

 
  CogNew(runADC, @stack2)
  CogNew(runMotor, @stack)
  disp.init
  
  repeat
    disp.display(@potentiometer)
   
    waitcnt(clkfreq+cnt)   

PUB runMotor
  motor.start

 
  repeat
    
      motor.setp(potentiometer - 127) ' Here we put a simple proportional controller
    
    waitcnt(clkfreq/1000+cnt) 

PUB runADC
  adc.periodicAcquireValue(@potentiometer)
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