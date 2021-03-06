{{
┌─────────────────────────────────────┬──────────────┬──────────┬────────────┐
│ MAX31855 Thermocouple drver demo    │ BR           │ (C)2014  │ 25Aug2014  │
├─────────────────────────────────────┴──────────────┴──────────┴────────────┤
│ Demo of driver object for interfacing with the MAX31855                    │
│ temperature-compensated Thermocouple-to-Digital Converter.                 │
│                                                                            │
│ See end of file for terms of use.                                          │
└────────────────────────────────────────────────────────────────────────────┘
}}
CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  'pin definitions
  tc_dpin=6
  tc_cpin=4
  tc_cspin=5

  
OBJ
  pst: "parallax serial terminal"
  tc : "max31855_simple"
  

PUB go |t1, t2, t3

  'initialize term
  pst.start(115_200)

  waitcnt(clkfreq*5+cnt)
  pst.str(string("MAX31855 demo",13))
  pst.str(string("Thot   Tcold    Raw",13))
  pst.str(string("(degF) (degF)   bin",13))

  repeat
    t1 := tc.readTC(tc_dpin,tc_cpin,tc_cspin)
    t2 := tc.getCJ
    t3 := tc.getraw
    pst.dec(t1)            
    pst.str(string("      "))             
    pst.dec(t2)             
    pst.str(string("      "))             
    pst.bin(t3,32)             
    pst.newline             

    waitcnt(clkfreq+cnt)
    

dat
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