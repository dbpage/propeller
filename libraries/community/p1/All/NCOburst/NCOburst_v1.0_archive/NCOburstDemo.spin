
{program NCOburst.spin  v1.0
author, Tracy Allen, 1/5/2011, 2/3/2011, 7/30/11 formatted for OBEX

Uses a pair of cog counters to create a high frequency burst of pulses on command from Spin.
Frequency within burst number of pulses in burst are entered at terminal.
and can range from 1 Hertz up to 39.999999 MHz.

This demo uses an auxiliary counter running in POSEDGE mode in a second cog to verify the number of pulses produced.
The demo asks the user via a serial terminal (PST) to enter a frequency and the number of pulses desired in the burst.
The burst is produced and the second cog counts the pulses and the result is printed, which should match the number desired.

An oscilloscope or logic analyzer can be synched to the burst as visual verification.  A auxiliary pin is used by the demo only as
a stadrt stop signal between the cogs and is also useful as a 'scope sync for verification.

See the NCOburst object for details of the operation.

Note that the pulses are active low.
}
CON
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

  mypin = 0      ' main burst output
  auxpin = 1     ' secondary pin for counting the result using a monitor in another cog
                 ' do not connect the two pins
                 ' Auxpin is used to signal between two cogs, & as a 'scope sync pulse for the demo only.


VAR
  long   myHertz, myBurstN, howMany, stack[32]

OBJ
  pst : "Parallax serial terminal"
  burst : "NCOburst"
  
PUB  NCOburstDemo
  pst.start(9600)     ' for user entry and for display of results
  pause(200)
  outa[mypin]~~           ' pin to use for the burst, initially a high output
  dira[mypin]~~             '
  dira[auxpin]~~                ' this pin is a helper for the damo, to signal the monitor cog to start counting
  outa[auxpin]~
  cognew(monitor, @stack)          ' use auxiliary cog to check the number of pulses actually produced
  
  repeat
    pst.str(string(13,10,"enter frequency within burst: "))       ' interactive to explore the frequency and burst range
    myHertz := pst.decIn
    if myHertz > clkfreq/2
      pst.str(string(13,10,"sorry! choice exceeds clkfreq/2."))
      next
    pst.str(string(13,10,"enter number of pulses in burst: "))
    myBurstN := pst.decIn

    howMany := 0                ' this variable will report the number of pulses actually produced
    outa[auxpin]~~               ' enable the auxiliary cog, high at start of burst

    burst.make(mypin, myHertz, myBurstN)     ' <--------- THIS IS THE MAIN EVENT, MAKES THE BURST

    outa[auxpin]~              ' tell the monitor cog to stop counting and to tell us how many it counted
    pst.str(string(13,10,"verify N counted: "))
    pst.dec(howMany)
   

PRI pause(ms)
  waitcnt(clkfreq/1000 * ms + cnt)


PRI monitor         ' verifies the number of pulses produced by the above algorithm.   
  ctra := constant(%01010 << 26 + mypin)    ' posedge detect on the burst pin
  frqa := 1                                 ' count number of edges
  repeat
    waitpeq(|<auxpin,|<auxpin,0)    ' wait for auxpin to go high, burst is starting
    phsa := 0                     
    waitpeq(0,|<auxpin,0)    ' wait for the auxpin to return low, burst finished
    howMany := phsa

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

