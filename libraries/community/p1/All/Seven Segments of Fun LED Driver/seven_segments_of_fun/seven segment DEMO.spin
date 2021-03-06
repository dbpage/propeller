{{
*********************************************************************
TITLE:       Super Seven Segment Driver DEMO
DESCRIPTION: Shows off 8 digit full alphanumeric ASCII 7 segment display driver
AUTHOR:      Thomas B. Talbot, MD
Copyright (c) <2012> <Thomas Talbot>
July 2012
*********************************************************************

}}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        
VAR


OBJ
  segs   :      "seven_segments_of_fun"

PUB firstprocedure | i
  segs.start(0,23,16)
  delay(50)
  segs.print(string("--------"))
  delay(800)                                  
  segs.sequence(string(" Seven  Segments oF Fun   test  "), 3, 4)
  delay(4_000)
  segs.scroll(string("        Propeller 7-SEG driver by thomas talbot         "), 3,1)
  delay(9_500)
  segs.blank
  repeat i from 0 to 255 
    delay(30)
    segs.dec(i)
    segs.hexByte(0,i)                     
  delay(2_500)
  segs.blank
  segs.blink(string("BLINK   "),6)
  delay(5_000)
  segs.blank
  delay(1_000)
  segs.print(string("TESTover"))
  repeat

PRI delay(ms)                                           ' delay in milliseconds
    waitcnt (clkfreq / 1000 *ms + cnt)

  
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