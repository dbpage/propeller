{{Charlieplexer

   Author: Drew Walton
   Version: 1.0 (27 Nov 2010)
   Email: dwalton64@gmail.com
   
   Copyright 2010 Drew Walton
   Send end of file for Open Source License

   Thankyou to Steve Nicholson for his SevenSegment object. I used it as
   the starting point for this object. 

   Charlieplexing is a way of using a few pins on a microcontroller to
   multiplex a larger number of LEDs.  It was first proposed by Charlie
   Allen in a Maxim Integrated Products app note.

   Charlieplexing relies on have IO pins that cansupport three states:

   1)  High (1)           - pin outputs current at voltage of Vdd
   2)  Low  (0)           - pin sinks current
   3)  High impedance (z) - pin has high resistance

   The high impedance state can be set on the propeller by making the pin
   an input.


   Here is a formula for determining how many LEDs can be controlled
   given the number of pins:

         pins * pins - pins = LEDs that can be controlled

   So for 4 pins, we can control 16 - 4 = 12 LEDs.

   With 8 pins, we can control 64 - 8 = 56 LEDs.

   With 28 pins, we can control 784 - 28 = 784 LEDs!

   With 2 pins, we can control 4 - 2 = 2 LEDS which is not worth the effort.
   

   One easy way to visualize how charlieplexing works is to think of the LEDs
   as being in a matrix.  For example, a 4 pin matrix is shown below:


         Pin0    Pin1    Pin2    Pin3
          │       │       │       │     
          │       │ LED0  │ LED1  │ LED2          
          │       ┣┐    ┣┐    ┣┐       Hopefully it is pretty
    Pin0──╋───────┼──┻────┼──┻────┼──┻───    obvious why there are some
          │       │       │       │          intersections in the drawing
          │ LED3  │       │ LED4  │ LED5     that do not have an LED.
          ┣┐    │       ┣┐    ┣┐       Connecting an LED between
    Pin1──┼──┻────╋───────┼──┻────┼──┻───    the first row and column
          │       │       │       │          would mean that the anode
          │ LED6  │ LED7  │       │ LED8     and cathode of the LED would
          ┣┐    ┣┐    │       ┣┐       both be connected to pin 1
    Pin2──┼──┻────┼──┻────╋───────┼──┻───    and that LED could never be
          │       │       │       │          lit.
          │ LED9  │ LED10 │ LED11 │      
          ┣┐    ┣┐    ┣┐    │   
    Pin3──┼──┻────┼──┻────┼──┻────╋──────
          │       │       │       │
          
    Note that I left out current limiting resistors for clarity, but you
    should include them when you use charlieplexing.

    When an LED is forward biased, it lights up.  When an LED is reverse-
    biased or is connected to a pin set for high impedance, the LED is dark.
    With this scheme, only some LEDs can be lit simultaneously.  However, if
    you cycle between lighting LEDs fast enough, it will appear as though
    they are lit at the same time.  This is phenomenon is called persistence
    of vision.

    So you might wonder why we don't always use charlieplexing.  There are
    a few disadvantages:

    1) Charlieplexing is more complicated in software and uses CPU time
       Thankfully this disadvantage can be overcome by using this object
       and dedicating a core to controlling the LEDs.

    2) Charlieplexing LEDs are more complicated to connect in hardware.
    
    3) The LEDs are dimmer since they are only lit part of the time.
       We can only light one row (or column) at a time.  So for a 4 pin
       matrix, the LEDs are lit only 1/4th of the time.

    4) The propeller can only sink so much current in a single pin,
       limiting the brightness of the display, Since this code activates
       a row at a time, the max current can be calculated by multipling
       the number of LEDs in a row times the current per LED.  For
       example, with a 4 pin charlieplexed display, each row will have
       3 LEDs.  If each LED uses 20 mA, the pin sinking the current for
       the row will have to sink 60 mA. This is within the propeller's
       limit of 30 mA per pin, 100 mA per 8 pins, but we would have to
       lower the current per LED if we expanded the size of the array.

    5) LED failures can be hard to diagnose if an LED fails. Failures
       can cause multiple LEDs to light at the wrong time.

    6) Large differences in the LEDs' forward voltages can cause LEDs
       to light unintentionally.  I haven't seen any problems with this
       even when connecting different color LEDs, but it would be a
       problem if an LED has over twice the forward voltage of other LEDs
       in the array. 

     This object needs a way to address LEDs.  The LEDs are numbered in
     the manner shown on the schematic above.  Each row has (NUM_PINS - 1)
     LEDs on it.  The LEDs are numbered, starting at the top row, from
     left to right, skipping columns where the column number equals the
     pin number.  The following examples show how the LED numbering changes
     as NUM_PINS is changed.

    
   Here is an example of how LEDs are numbered if you set NUM_PINS = 5:
     
         Pin0    Pin1    Pin2    Pin3    Pin4    
          │       │       │       │       │      
          │       │ LED0  │ LED1  │ LED2  │ LED3         
          │       ┣┐    ┣┐    ┣┐    ┣┐      
    Pin0──╋───────┼──┻────┼──┻────┼──┻────┼──┻───   
          │       │       │       │       │         
          │ LED4  │       │ LED5  │ LED6  │ LED7    
          ┣┐    │       ┣┐    ┣┐    ┣┐      
    Pin1──┼──┻────╋───────┼──┻────┼──┻────┼──┻───   
          │       │       │       │       │         
          │ LED8  │ LED9  │       │ LED10 │ LED11   
          ┣┐    ┣┐    │       ┣┐    ┣┐      
    Pin2──┼──┻────┼──┻────╋───────┼──┻────┼──┻───   
          │       │       │       │       │         
          │ LED12 │ LED13 │ LED14 │       │ LED15      
          ┣┐    ┣┐    ┣┐    │       ┣┐         
    Pin3──┼──┻────┼──┻────┼──┻────╋───────┼──┻───
          │       │       │       │       │      
          │       │       │       │       │         
          │ LED16 │ LED17 │ LED18 │ LED19 │             
          ┣┐    ┣┐    ┣┐    ┣┐    │             
    Pin4──┼──┻────┼──┻────┼──┻────┼──┻────╋──────
          │       │       │       │             


    Here is an example of how LEDs are numbered if you set NUM_PINs = 3

         Pin0    Pin1    Pin2      
          │       │       │        
          │       │ LED0  │ LED1   
          │       ┣┐    ┣┐     
    Pin0──╋───────┼──┻────┼──┻──── 
          │       │       │        
          │ LED2  │       │ LED3   
          ┣┐    │       ┣┐     
    Pin1──┼──┻────╋───────┼──┻──── 
          │       │       │        
          │ LED4  │ LED5  │        
          ┣┐    ┣┐    │        
    Pin2──┼──┻────┼──┻────╋─────── 

    Note that I left out current limiting resistors for clarity, but you
    should include them when you use charlieplexing.     
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  isEnabled = %0001

VAR
  long myStack[10]
  long NUM_LEDS
  long NUM_PINS
  long flags
  long runningCogID
  long lowPin
  long highPin
  long led_rows[27]                            ' Holds the array that indicates
                                               ' which LEDs are lit.  It is
                                               ' only 28 longs because this
                                               ' object supports only 28 pins
  long blink_rate
  long blink_rows[27]                          ' keeps track of which LEDs are
                                               ' blinking. 1 = blinking   



PUB Start(numPins, startPin, enabled)
'' Start the display
'' Parameters:

  NUM_PINS := numPins
   
  if (startPin < 0) | (NUM_PINS < 2) | (NUM_PINS > 28)                               
    ' would like to stop compiling, but how?
    reboot  ' that will get your attention that something is wrong . . .          

  NUM_LEDS := NUM_PINS * NUM_PINS - NUM_PINS   

  lowPin := startPin
  highPin := startPin + (NUM_PINS - 1)
  
  
  if enabled                                            'Set initial enabled state
    flags |= isEnabled
  else
    flags~
  
  blink_rate := clkfreq/4
  
  stop
  runningCogID := cognew(Charlieplexer, @myStack) + 1

PUB GetNumLeds
  return NUM_LEDS

PUB Stop
'' Stop the display
  if runningCogID
    cogstop(runningCogID~ - 1)

PUB Enable
'' Enable the display
  flags |= isEnabled

PUB Disable
'' Disable the display
  flags &= !isEnabled

PUB LedOn(theLed) | row, col
  CalcLedRowCol(theLed, @row, @col)
  led_rows[row] |= (1 << col)


PUB LedOff(theLed) | row, col
  CalcLedRowCol(theLed, @row, @col)
  led_rows[row] &= !(1 << col)

PUB BlinkLed(theLed) | row, col
  CalcLedRowCol(theLed, @row, @col)
  blink_rows[row] |= (1 << col)

PUB StopBlinking(theLed) | row, col
  CalcLedRowCol(theLed, @row, @col)
  blink_rows[row] &= !(1 << col)

PUB BlinkAll | led
  repeat led from 0 to NUM_LEDS
    BlinkLed(led)
    
PUB StopBlinkingAll | led
  repeat led from 0 to NUM_LEDS  
    StopBlinking(led)
    
PUB SetBlinkCycles(numCycles)                    
  blink_rate := numCycles
    

PRI CalcLedNum(rowPin, columnPin)| LedNum
' Converts a row and column pin number to a LedNum.
' This function is the inverse of CalcLedRowCol.

  ' Check to see if this is a valid location for an LED
  if (columnPin == rowPin)
    return -1  

  LedNum := (rowPin - lowPin)  * (NUM_PINS - 1)

  LedNum += (columnPin - lowPin)

  ' Correct to account for LEDs not being connected when the row and
  ' column pin are the same pin. 
  if (columnPin > rowPin)
    LedNum -= 1

  return LedNum
  

PRI CalcLedRowCol(ledNum, rowPtr, colPtr) | tmpRow, tmpCol
' Converts a LedNum to a row pin and a column pin.  This function is the
' inverse of CalcLedNum.

  if ledNum => NUM_LEDS
    ' ledNum is invalid
    long[rowPtr] := -1
    long[colPtr] := -1

  tmpRow := ledNum /  (NUM_PINS - 1)
  tmpCol := ledNum // (NUM_PINS - 1)

  ' Correct to account for LEDs not being connected when the row and
  ' column pin are the same pin. 
  if (tmpCol => tmpRow)
    tmpCol++
  
  long[rowPtr] := tmpRow + lowPin
  long[colPtr] := tmpCol + lowPin 

  
PRI Charlieplexer | row,  blinkState, startTime, blinkRowVal
' ShowValue runs in its own cog and continually updates the display

  blinkState := 1
  startTime := cnt
  
  repeat

    if flags & isEnabled
      if ((cnt - startTime) => blink_rate)              'if it is time to change blink_state
        blinkState ^= 1                                 'toggle blink_state
        startTime += blink_rate                         'calculate next time to toggle

      repeat row from lowPin to highPin
      
        blinkRowVal :=  led_rows[row] & !blink_rows[row]
        
        dira[highPin..lowPin]~ 
        if blinkState ==0                               'check to see if it is time to blink
          outa := blinkRowVal
          dira := blinkRowVal | (|< row)                'enable outputs on only pins that are
                                                        'supposed to be lit.  Tri-state the
                                                        'others.
        else                                            'not time to blink
          outa := led_rows[row]
          dira := led_rows[row] | (|< row)              'enable outputs on only pins that are
                                                        'supposed to be lit.  Tri-state the
                                                        'others.


        waitcnt (clkfreq / 20_000 + cnt)                'the delay value can be tweaked to reduce
                                                        'flicker.  It has limited ability to
                                                        'alter brightness.
                                                        'With a delay of 1/20,000th of a second
                                                        'the display takes about 165.33 uSec to
                                                        'display a row.  Since the biggest
                                                        'matrix supported has 27 rows, it would
                                                        'take 4.6293 mSec to cycle through all
                                                        '27 rows. This would cause the display
                                                        'to be drawn 216.01 times a second, which
                                                        'should be fast enough to prevent
                                                        'noticable flicker. 



    else
      dira[highPin..lowPin]~                            'disable all LEDs
      outa[highPin..lowPin]~                            'disable all LEDs
      waitcnt (clkfreq / 10 + cnt)                      'wait 1/10 second before checking again


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