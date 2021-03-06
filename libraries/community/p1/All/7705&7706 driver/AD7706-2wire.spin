{{

  AD7705 Driver

  Author: Jev Kuznetsov & spiritplumber@gmail.com

  Version 1.3

  Date: 24 November 2008  


22.06.2009 : Fixed channel switch bug, changed data line to default high for a more robust interface

03/03/2010 by spiritplumber@gmail.com added support for adc7706 and using only 2 wires instead of 4

  
Please notice that the pin notation is:
propeller       adc7705
RXpin-------------dout
TXpin------------din
sclk-------------sclk
ndrdy------------ndrdy

                                             
to combine tx and rx wires:

                +3/+5                       
                ┬
        220       10k
TRXpin────────╋───────dout
                └───────din
sclk────────────────────sclk
                   ────ndrdy

                   
Use ConfigureChannel funcitons after initialisation to configure the channels.
TEST_PIN code can be omitted, it is being used for checking conversion speed and timing on an oscilloscope

}}

CON
  WAIT_MS        = 1000      ' ms before DRDY timeout
  WAIT_MS_NOLINE = 20        ' same if there's no DRDY line (adjust based on refresh rate for the read, should be same or lower)
   
VAR

  byte Cpin, RXpin, TXpin, ndrdy
 
PUB init(_sclk, _dout, _din, _ndrdy)
' initialise the 7705 chip


  Cpin := _sclk
  RXpin := _dout
  TXpin := _din
  ndrdy := _ndrdy
  

  'set output directions
  dira[Cpin]~~  ' output
  dira[TXpin]~~
  dira[RXpin]~  'input
  dira[ndrdy]~
  'set initial line states
  outa[Cpin]~~  ' set clock high
  outa[TXpin]~
  outa[RXpin]~
  
  ResetChip                     ' put adc in its initial state

PUB ConfigureChannel1(_clk_reg, _setup_reg)
' write configuration for channel 1

  WaitForDRDY

  ' configure channel 1
  WriteToReg(%0010_0000) ' active channel is 1, next operation a write to the clock register
  WriteToReg(_clk_reg) 'clock register 
  WriteToReg(%0001_0000) ' active Channel is 1, next opration as write to the setup register
  WriteToReg(_setup_reg) ' setup register

  WaitForDRDY 

PUB ConfigureChannel2(_clk_reg, _setup_reg)
' write configuration for channel 2

  WaitForDRDY

  ' configure channel 2
  WriteToReg(%0010_0001) ' active channel is 2, next operation a write to the clock register
  WriteToReg(_clk_reg) 'clock register 
  WriteToReg(%0001_0001) ' active Channel is 2, next opration as write to the setup register
  WriteToReg(_setup_reg) ' clock register    

  WaitForDRDY 

PUB ConfigureChannel3(_clk_reg, _setup_reg)
' write configuration for channel 3

  WaitForDRDY

  ' configure channel 3
  WriteToReg(%0010_0011) ' active channel is 2, next operation a write to the clock register
  WriteToReg(_clk_reg) 'clock register 
  WriteToReg(%0001_0011) ' active Channel is 2, next opration as write to the setup register
  WriteToReg(_setup_reg) ' clock register    

  WaitForDRDY 
  
PUB GetChannel1 : adc_val
  WriteToReg(%0_011_1_0_00)'$38) ' set the next operation for 16 bit read from the data register___
  WaitForDRDY
  adc_val := ReadResult

  WaitForDRDY 
  
PUB GetChannel2 : adc_val
   
  WriteToReg(%0_011_1_0_01)'$39) ' set the next operation for 16 bit read from the data register
  WaitForDRDY
  adc_val := ReadResult

  WaitForDRDY 

PUB GetChannel3 : adc_val
   
  WriteToReg(%0_011_1_0_11)'$3A) ' set the next operation for 16 bit read from the data register
  WaitForDRDY
  adc_val := ReadResult

  WaitForDRDY 

  
PRI ResetChip
  if (TXpin == RXpin)
    dira[Txpin]~~ ' out
' writing 23 ones will reset the 7705
  outa[TXpin]~~
  repeat 64
    !outa[Cpin]                                             ' cycle clock          
    !outa[Cpin]

  outa[TXpin]~
  if (TXpin == RXpin)
    dira[RXpin]~ ' in
  
  waitcnt(cnt+8_000_000)        ' wait for 100ms


PRI  WriteToReg(Value) '| bits
' write a byte to the 7705  msbfirst

 'bits := 8

 if (TXpin == RXpin)
    dira[Txpin]~~ ' out
 REPEAT 8 'bits                                                             
    outa[TXpin] := Value >> 7'(bits-1)                     ' Set output           
    Value := Value << 1                                    ' Shift value right    
    !outa[Cpin]                                            ' cycle clock          
    !outa[Cpin]                                                                   
    waitcnt(1000 + cnt)                                    ' delay                
    outa[TXpin]~~                                           ' Set data to high, making serial interface more robust, see 7705 notes
 if (TXpin == RXpin)
    dira[Rxpin]~  ' in

PRI ReadResult : Value | InBit
 ' read 16 bits of data, mode is msbpost
  Value~
                                                          
  REPEAT 16                                                ' for number of bits                    
    !outa[Cpin]                                            ' cycle clock                         
    !outa[Cpin]                                               
    InBit:= ina[RXpin]                                     ' get bit value                          
    Value := (Value << 1) + InBit                          ' Add to  value shifted by position                                         
   ' waitcnt(1000 + cnt)                                    ' time delay    
{
PRI WaitForDRDY
  repeat while (ina[ndrdy] == 1) ' wait for /drdy to go low
}

PRI WaitForDRDY | t 
' wait with a timeout WAIT_MS

  t := cnt


  ' we could probably read the comm word here instead, anyone up to changing it?

  if (ndrdy < 0 or ndrdy > 31)
      repeat until (cnt - t) / (clkfreq / 1000) > WAIT_MS_NOLINE
      return

      
  repeat until (ina[ndrdy] == 0) or (cnt - t) / (clkfreq / 1000) > WAIT_MS

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