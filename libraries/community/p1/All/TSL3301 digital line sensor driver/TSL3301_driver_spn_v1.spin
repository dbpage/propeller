con
  SDIN = 1      'Prop IO pin hooked to the TSL3301 SDIN pin
  SDOUT = 0     'Prop IO pin hooked to the TSL3301 SDOUT pin
  SCLK = 2      'Prop IO pin hooked to the TSL3301 SCLK pin

{{

┌──────────────────────────────────────────┐
│ TSL3301_driver_spn_v1                    │
│ Author: Marty Lawson                     │               
│ Copyright (c) 2012 Marty Lawson          │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘


This code is a direct translation of the TAOS app-note on how to interface
with a TSL3301 with a microcontroller. It's fairly slow in Spin with a minimum
integration time of about 1mS, But does not require a cog.}}

Pub init
'initialise pins, variables, etc for this code
'mod so that pins are passed into the object here
  dira[SDIN] := 1 'make the pin sending data to the TSL3301 an output
  dira[SCLK] := 1 'make the clock pin to the TSL3301 an output

pub reset
'reset the TSL3301 chip to put it in a known state
  outa[SCLK] := 0               'clear the clock pin
  outa[SDIN] := 0               'clear the data to sensor pin
  pulse_sclk(30)                'pulse sclk 30 times
  outa[SDIN] := 1               'set the data to sensor pin
  pulse_sclk(10)                'pulse sclk 10 times
  send($1B)                     'reset command
  pulse_sclk(5)                 'clocks to implement reset
  send($5F)                     'write to mode register
  send($00)                     'clear mode register


pub set_gains(offset, GC)
'setup the TSL3301 gain and offset registers to appropriate values
'later mod to allow specified values
  GC := 0 #> GC <# 31           'limit the gain codes to a valid range
  if offset < 0                 'if offset is negative
    offset := ||offset          'start converting to sign magnitude by taking the absolute value
    offset &= $7F               'limit to 7-bit magnitude
    offset |= $80               'set sign bit
  else
    offset &= $7F               'otherwise just limit to 7-bits of magnitude and clear sign bit
  'set gain and offset registers
  send($40)                     'left offset
  send(offset)                     '-1
  send($41)                     'left gain
  send(GC)                     'gain code 5
  send($42)                     'center offset
  send(offset)                     '-1
  send($43)                     'center gain
  send(GC)                     'gain code 5
  send($44)                     'right offset
  send(offset)                     '-1
  send($45)                     'right gain
  send(GC)                     'gain code 5


pub start_int
'start integration of photons
  send($08)                     'start integration command
  pulse_sclk(22)                'clocks for internal state machine

pub stop_int
'stop integrating photons
  send($10)
  pulse_sclk(5)

pub start_read
'start the readout of pixels
  send($02)                     'start read command
  repeat while ina[SDOUT] == 1  'wait for a start bit on SDOUT
    pulse_sclk(1)
  
pub read_pix(data_ptr) | idx
'read pixel data into the byte array pointed to by data_ptr
  repeat idx from 0 to 101
    byte[data_ptr][idx] := recieve

pri recieve : bite
'recieve data sent by the TSL3301 chip
  pulse_sclk(1)                 'get past start bit
  bite := 0                     'clear output variable
  repeat 8
    bite >>= 1                  'shift bite one position right (placed here so we don't shift the last bit   
    if ina[SDOUT] == 1          'if a one is seen on the data from TSL3301 pin
      bite |= $80               'set bit position 7 to a one
    pulse_sclk(1)               'clock next bit
  pulse_sclk(1)                 'clock into next start bit                      

pri send(bite)
'send a byte to the TSL3301 chip
'might be useful to modify to accept strings of bytes
  outa[SDIN] := 0               'clear SDIN
  pulse_sclk(1)
  repeat 8
    outa[SDIN] := bite & $00000001                      'set SDIN to the lsb of bite and mask out other bits
    pulse_sclk(1)               'pulse sclk
    bite >>= 1
  outa[SDIN] := 1               'set SDIN
  pulse_sclk(1)
  

pri pulse_sclk(num)
'pulse just SCLK some number of times
  repeat (num #> 0)
    outa[SCLK] := 1
    outa[SCLK] := 0             'pulse the SCLK num times


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