{{
┌──────────────────────────────────────────┐
│ vs1002 Decoder example                   │
│ Author: Kit Morton                       │               
│ Copyright (c) 2008 Kit Morton            │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

  This is example code for using the vs1002 mp3 decoder object.
  It requires a sd card on pins 8-11 and a vs1002 on pins 0-5.

}}
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

VAR
    Byte SDBuffer[32]

    Long Stack2[1000]

OBJ
  MP3 : "vs1002 mp3"
  sdfat : "fsrw"

PUB Start | Bytes, Read, Count, Poss
  MP3.start (0,1,2,3,4)         ' Start mp3 object  

  dira[5]~
     
  sdfat.mount(8)
  sdfat.popen(string("01DARL~1.MP3"), "r")              ' <<-- Change mp3 file name here.
  MP3.WriteReg(3,38912)                                 ' <<-- Set clock devider. This is verry improtant, if you do not it will play very slowly
  MP3.SetVolume(190,0)                                                          ' Volume defalts to zero on startup, so it must be set.
  DataOut

PUB DataOut | Bytes, Read, Count, Poss         
  repeat
    if ina[5] == 1
      Poss += sdfat.pread(@SDBuffer,32)
                                                        
      Count~
      if Bytes <  32
        repeat Bytes
          MP3.WriteDataByte(SDBuffer[Read++])
        quit        
      MP3.WriteDataBuffer(@SDBuffer)

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