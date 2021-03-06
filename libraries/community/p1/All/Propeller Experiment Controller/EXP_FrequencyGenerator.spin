{{

┌────────────────────────────────────────────┐
│ Frequency Generator v1.0                   │
│ Author: Christopher A Varnon               │
│ Created: 12-24-2012                        │
│ See end of file for terms of use.          │
└────────────────────────────────────────────┘

  This frequency generator uses a cog's two counters to generate a square wave on a user provided pin.
  An optional inverted pin can be used.
  This object was designed to be used with Experimental Functions, but it can also be used independently.

}}

VAR
  Byte CounterAB                                                                ' Notes the state of Counter A and Counter B
  ' 00 Both off
  ' 01 A on
  ' 10 B on
  ' 11 Both on

PUB SquareWave(CTRX, Pin, InvertedPin)
  '' Sets up a counter to generate a square wave on a pin.
  '' Optionally, an inverted wave will also be generated on the inverted pin.
  '' Set inverted pin to -1 if no inverted signal is desired.

  if CTRX=="A"
    CTRA[5..0]:=Pin
    dira[Pin]~~
    if InvertedPin<0
      CTRA[30..26]:=%00100
    else
      CTRA[14..9]:=InvertedPin
      dira[InvertedPin]~~
      CTRA[30..26]:=%00101

  if CTRX=="B"
    CTRB[5..0]:=Pin
    dira[Pin]~~
    if InvertedPin<0
      CTRB[30..26]:=%00100
    else
      CTRB[14..9]:=InvertedPin
      dira[InvertedPin]~~
      CTRB[30..26]:=%00101

PUB SetFrequency(CTRX, Frequency) | FrequencyRegister
  Frequency:=Frequency #> 0 <# 500_000
  '' Updates the frequency.

  'FrequencyRegister=frequency*(2^32/clkfreq)
  repeat 33
    FrequencyRegister<<=1
    if frequency=>clkfreq
      frequency-=clkfreq
      FrequencyRegister++
    frequency<<=1

  if CTRX=="A"
    FRQA:=FrequencyRegister
  if CTRX=="B"
    FRQB:=FrequencyRegister

PUB GetCounter
  '' Returns the state of the counters.
  return CounterAB

PUB StopCounter(CTRX,Pin,InvertedPin)
  '' Stop the counters and reset all related variables.

  if CTRX=="A"
    CTRA:=0
    PHSA:=0
    FRQA:=0

  if CTRX=="B"
    CTRB:=0
    PHSB:=0
    FRQB:=0

  dira[pin]~
  dira[invertedpin]~

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
