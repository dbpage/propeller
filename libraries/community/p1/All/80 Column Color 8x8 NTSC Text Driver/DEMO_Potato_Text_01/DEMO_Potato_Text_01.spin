{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   NTSC 8x8 Character Driver (C) 2009-06-29 Doug Dingus                                       │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                    TERMS OF USE: Parallax Object Exchange License                                            │                                                            
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

''Auto Hardware Detect by Graham Coley  (Demoboard, HYBRID, and HYDRA)
''Based off of the very nice template contributed by Eric Ball
'TODO:  Add Mouse Pointer Code
'done:  Clean up, document, release 1.0


''This demo shows off how to use the text driver code.  Many different character type displays are possible.
''Color space is managed in this driver, simplifying how color is specified and preventing illegal colors
''
''Driver can do 64 character x 25 rows @ 80 Mhz
''80 x 25 is possible in two color mode at 80Mhz
''80 x 25 is possible at 96Mhz or above.

''I'm putting off the mouse, releasing this as a text only driver because I've another project
''that caught my eye.  Two screen colors are reserved for the mouse pointer, leaving that option
''open at a later time.



OBJ
        TEXT           : "Potato_Text_Start_01.spin"                                  'TV Video Cog   
 
 
PUB main

    TEXT.Start(40)                                        'Launch the text display driver

    Demo                                                  'Do some basic stuff with the display



Pub   Demo | i, j, k, l

'two_colors, no_burst, no_interlace, numwtvd, vsclactv all live and updated once each frame
      TEXT.CharsPerLine(40)               'Change this per your clock speed and text resolution needs.
      TEXT.ColorMode($070b)
      TEXT.ClearText($20)
      TEXT.ClearColors((8*15)+2, $07)

      
      waitcnt(cnt + 100_000_000)

      
      l := 0
      
      repeat i from 0 to 16
        repeat j from 0 to 7
          'WAITCNT (CNT + 1_000_000)
          TEXT.SetTextAt(i, j, $20)
          TEXT.SetTextAt(i, j+9, $82)
          TEXT.SetColorCell(i, j, l, 7)
          TEXT.SetColorCell(i, j+9, l, 06)

          TEXT.SetTextAt(i+20, j, l)
          TEXT.SetTextAt(i+20, j+9, $82)
          TEXT.SetColorCell(i+20, j, l, j + 1)
          TEXT.SetColorCell(i+20, j+9, l, 02)

          
          l := l + 1
      
      TEXT.Interlace(0)

      

      TEXT.SetColors(8*5+2, 8*8+5)

      TEXT.PrintStringAt(2,18, string("Sample Color Palette Demo-->"))

      TEXT.SetTextAt(32, 18, $84)
      TEXT.Redefine ($84, $ff, $F0, $0F, $F0, $FF, $F0, $0F, $FF)
      TEXT.SetTextAt(34, 18, $85)
      TEXT.RedefineDat($85, @Smile)
      TEXT.SetTextAt(36, 18, $86)
      TEXT.RedefineDat($86, @Bound)
      

      TEXT.SetColors(8*12+2, 8*16+6)

      TEXT.PrintStringAt(2,20, string("With Custom Characters Defined"))

      TEXT.SetColors(0, 8*9+6)

      TEXT.PrintStringAt(2,22, string("Color Space = 8 * HUE + Intensity"))
      TEXT.PrintStringAt(2,23, string("Intensity = 0..7  Hue = 0..17"))

      repeat 2
        TEXT.ColorMode(0)

        waitcnt(cnt + 200_000_000)
        TEXT.ColorMode($070b)

        waitcnt(cnt + 200_000_000)

      TEXT.ColorMode(0)


      'Ok, so let's scroll it!

      i := 0
              
      repeat 10
        TEXT.SetColors(0, (i*8)+6)
        TEXT.Scroll(0,24)
        TEXT.PrintStringAt(i*2, 24, string("Full Screen Scrolling"))
        waitcnt(cnt + 100_000_000)
        i := i + 1



      'Let's write a batch of characters to the screen

      TEXT.PrintStringAt(0,0, string("x"))

      i := cnt
      repeat 4000
        i := i&%01111111
        TEXT.SetColors(0, (i*3)+3)
        TEXT.PrintChar(i)
        i ++
        waitcnt(cnt + 100_000)
      

      'Let's write a batch strings to the screen!

      i := 0
      repeat 400
        j := i
        j := j & %01111111
        TEXT.SetColors(0, (i*3)+3)
        TEXT.PrintString(string("A Sample String! "))
        i++

      waitcnt(cnt + 100_000_000)
        
      'Finally, a batch of numbers!

      repeat i from 0 to 10_000
        TEXT.SetColors(0, (i*3)+3)
        TEXT.PrintDec(i)
        TEXT.PrintString(string(", "))

         
      
Dat
Smile
        byte  %00000000
        byte  %01101100
        byte  %01101100
        byte  %00000000
        byte  %00010000
        byte  %10010010
        byte  %01000100
        byte  %00110000

Bound   byte  %11100111
        byte  %10000001        
        byte  %10000001
        byte  %00011000
        byte  %00011000
        byte  %10000001
        byte  %10000001
        byte  %11100111      

Line    byte  %10000001
        byte  %01000000
        byte  %00100000
        byte  %00010000
        byte  %00001000
        byte  %00000100
        byte  %00000010
        byte  %10000001

      
tt     byte  "A longer test string to see what happens", 0


                  