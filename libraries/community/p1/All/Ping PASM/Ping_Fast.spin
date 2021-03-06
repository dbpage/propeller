{{
┌──────────────────────────────────────────┐
│ Ping_Fast.spin                           │
│ Author: Wm Dygon (pogertt@wi.rr.com)     │               
│ Copyright (c) 2012 Wm Dygon              │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

 Object to read a Ping)) sensor over it's entire range as fast and as consistantly as possible.

       
  ┌───────────────────┐
  │┌───┐         ┌───┐│    Connection To Propeller
  ││ ‣ │ PING))) │ ‣ ││    Remember PING))) Requires
  │└───┘         └───┘│    +5V Power Supply
  │    GND +5V SIG    │
  └─────┬───┬───┬─────┘
        │  │    3.3K
          └┘   └ Pin


 The assembly portion executes in 2_000_000 clock cycles'
 at 80_000_000 hertz clock, that gives an execution time of
 .025 seconds or 40.000 reads per second.

        
    
     │  │              │               │←───────────────→│← Next Trigger Pulse
    →│  │←Trigger Pulse│← Echo Return →│                 │ 
     │← Echo Holdoff  →│               │← Delay B4 Next →│
 

    Echo Holdoff  =    60_000
    Echo Return   = 1_924_000
    Delay B4 Next =    16_000
    Total Clocks  = 2_000_000
         
 Deivating from the Parallax data sheet:
 
 I start my Echo Holdoff time from when the trigger pulse starts, rather than when it ends.
 
 I have found the Maximum Echo Return Pulse to be between 21.6 and 21.7 milliseconds.
 By allowing 24.050 milliseconds Echo Return, I ensure the potential maximum detection distance
 has been seen.
 This value also pads exicution time so the read has a regular 25 millisecond repeat rate.
 
}}
CON
        _clkmode = xtal1 + pll16x                       'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        Ping_Pin = 11                                   '  Pin that Ping))) Sensor is wired to
        DPu = 13512
{{      DPu assumes Speed of Sound to be 1126 Feet per Second in Dry Air @ 68 °F.
        1126 * 12 = 1352 inches per second

}}        
VAR

        long          Sensor_Pin    
        long          Echo_Length
        long          Distance
        long          uSec
        long          Raw_Distance
        long          Remainder

OBJ

        pst : "Parallax Serial Terminal"
      
PUB   start  :  okay       

      pst.start(115_200)                    ' Start the Display
       
      Sensor_Pin := Ping_Pin                ' Prepare Variable
      
      cognew (@entry,@Sensor_Pin)           ' Start Assembly Routine in a new COG
      
      waitcnt(clkfreq + cnt)                ' Wait a second

      ' Prepare Display screen with Labels for data to be shown
      
      pst.str(string("          PING))) Demo",13,13))
      pst.str(string("  Raw Count in CLOCK Cycles........",13,13))
      pst.str(string("  One Way Time in CLOCK Cycles.....",13,13))  
      pst.str(string("  µSeconds to Target...............",13,13)) 
      pst.str(string("  Distance in Inches...............",13,13)) 
  
    repeat
        pst.Position(34,2)
        pst.ClearEnd      
        pst.dec(Echo_Length)      'Raw Count in CLOCK Cycles

        Distance := Echo_Length >> 1
        pst.Position(34,4)
        pst.ClearEnd
        pst.dec(Distance)         'One Way Time in CLOCK Cycles

        uSec := Distance / 80
        pst.Position(34,6)
        pst.ClearEnd
        pst.dec(uSec)             'µSeconds to Target
         
        pst.Position(34,8)
        pst.ClearEnd
        Raw_Distance := uSec * DPu  / 1_000_000
        Remainder := uSec * DPu // 1_000_000
        pst.dec(Raw_Distance)     'Distance in Inches
        pst.char(46)              'Print decimal point
        pst.dec(Remainder)        'Distance fractional portion

        waitcnt(clkfreq/4 + cnt)  'Wait to do it again


Dat

entry         org       0
              rdlong    P_Pin, par                      'Read Main Ram to find out Pin Ping)) is wired to.
              mov       Pin, #1                         'Set a 1 into "Pin"
              shl       Pin, P_Pin                      'Shift the 1 to Pin bit
              add       Trigger_Counter, P_Pin          'Add Pin into APIN of Counter
              add       Echo_Counter, P_Pin             'Add Pin into APIB of Counter
              mov       Echo_to_Main_Ram, par           'Echo_to_Main_Ram is distance to be returned.
              add       Echo_to_Main_Ram, #4            'Make it the second Variable in the list
              mov       frqa, #1                        'Set frqa to count 1 per clock
              mov       time, cnt                       'Get original time stamp

:loop         add          time, Echo_Holdoff           'Add Echo_Holdoff to time   
              mov          ctra, Trigger_Counter        'Set counter to NCO single-ended mode
              or           dira, pin                    'Set APIN to be an output
              neg          phsa, Trigger_Pulse          'Send Trigger Pulse 2 µsec pulse  
              waitcnt      time, Echo_Pulse             'Wait for Echo_Holdoff 750 µsec  
              muxc         dira, pin                    'Make Ping))) Pin into an Input    
              mov          ctra, Echo_Counter           'Time Echo Return Pulse     
              mov          phsa, #0                     'Clear the accumulator 
              waitcnt      time, Delay_B4_Next          'Wait for pulse to complete  ≈ 21.7 msec max 
              mov          Echo, phsa                   'Read Echo Return Pulse length
              wrlong       Echo, Echo_to_Main_Ram       'Write the result to Main Ram
              waitcnt      time, #0                     'Wait B4 taking another measurment
              jmp          #:loop                       'Loop forever

Trigger_Counter         long    %00100_000_00000000_000000_000_<< 6  'NCO single-ended Mode
Echo_Counter            long    %11010_000_00000000_000000_000_<< 6  'LOGIC A Mode

Trigger_Pulse           long    160                     '2 µsec Trigger Pulse Width
Echo_Holdoff            long    60_000                  '750 µsec wait B4 Measuring Echo Pulse
Echo_Pulse              long    1_924_000               '1_924_000 for 40 reads per second
Delay_B4_Next           long    16_000                  '200 µsec Delay B4 Next Cycle

Pin                     res     1
P_Pin                   res     1
time                    res     1
Echo                    res     1
Echo_to_Main_Ram        res     1


             fit

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