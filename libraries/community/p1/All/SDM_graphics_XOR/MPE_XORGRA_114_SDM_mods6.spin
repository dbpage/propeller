{{
┌──────────────────────────────────────────┐
│ MPE_XORGA_114_SDM_mods6                  │
│ Author: Steven Messenger mod,            │
│         deSilva original                 │               
│ Copyright (c) 2008 Steven Messenger and  │
│                    deSilva               │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘
}}

''*  MPE_XORGRA 320x224 v1.14        
' *  Chcking XOR vrsion og GRAPHICS
' *  V 1.14 Feb. 2008 by deSilva
'    Modded by Steven for my proto board and to use drawGlyph for arc locations.
' ---------------------------------------------------

{parameters for test on Hydra
  _clkmode  = xtal1 + pll8x
  _xinfreq  = 10_000_000
  videoPin  =  24
}

'{parameters for standard
  _clkmode  = xtal1 + pll16x
  _xinfreq  = 5_000_000
  videoPin  =  12
'}
  
CON
  PAL        = 0
  maxcols    = 20 '
  maxrows    = 4*7
  nChars     = 20
  screensize = maxcols * 2* maxrows
  lastrow    = screensize - 2 * maxcols
  midX       = nChars*8
  midY       = maxrows*4 + 16  
 bitmap_2    =  $8000-2*nChars*2*15*16 '21kB only, leaves 11k for program code! 
VAR

  long  col, row, color, flag, cols , xrows
  word  screen[screensize]
  long  fourColors, c1,c2,c3,c4,c5
  
  byte  digbuf[12]
   
OBJ

  tv : "tv.spin"
  gr : "SDM_graphics_XOR_025"

                          
PUB demo  | oldvals[64]
  start(videoPin, nChars, 0)   ' simplified configure tiled screen
  gr.start                      
  fourColors := $02_9b_7e_0c
  c3 := $02020606 'even chars  'font color #1
  c2 := $02060206 'odd chars
  c5 := $02020404 'even chars  'font color #2
  c4 := $02040204 'odd chars

  setupFull                    ' re-init graphics and text
  
  repeat
     setupFull
     gr.textMode(1,1,8,0) 
' test getting colours from bitmap
     testColors
     setupFull
     makeTechDisplay(0,0)
     longfill(@oldVals, 0, 32)
     repeat 100
        histogram(32, 0, @oldVals)
             
     someDemos(0)
   

    'someDemos(3)
    
PUB someDemos(width)  | i , ran, dx, dy, x,y , glyph, theWidth, st
    setupFull
    gr.clear
        
    fourColors := $02_9b_7e_0c

    gr.setFont(gr#ROM)
    gr.textMode(1,1,16,0)
    gr.text(0,192,string("MPE_XORGRA"))
    gr.text(0,160,string("vers 114  SDM mods4"))
    gr.text(0,128,string("ROMglyphs"))  
    gr.text(0,96,string("worms"))   
    gr.text(0,64,string("txtwheel"))
    gr.text(0,32,string("pulsing"))
    gr.text(0,0,string("XORtext"))
    gr.textMode(1,1,8,0)
    gr.setFont(gr#Clemens)

    waitcnt(cnt+clkfreq*2)
     
    setupFull                     ' re-init graphics and text 


' Blow-Up
    REPEAT theWidth FROM 0 to 7
       gr.setOverwrite
       gr.width(0)
       gr.color(1)
       gr.box(0,0,midX,midY)
       gr.color(2)
       gr.box(midX,0,midX,midY)
       gr.color(3)
       gr.box(0,midY,midX,midY)
       gr.color(0)
       gr.box(midX,midY,midX,midY)
       st := string("width = 0 - XORing")
       byte[st][8] := "0"+theWidth
       gr.text(midx,10, st)
       gr.setXOR
       gr.width(theWidth)
       gr.drawGlyph( midX-(theWidth+1)*8, midY-(theWidth+1)*16, 0, 0,0,0,@pixDef, "R")
       waitcnt(cnt+clkfreq*5)
    waitcnt(cnt+clkfreq*3)
    gr.clear 


    gr.setXOR 
    gr.width(width)  

' moving Glyphs
    glyphMove(20)   ' seconds running
     

' a worm
   theWorm(10, 100)  'length, delay 
   theWorm(QSIZE/2-1, 0)  'length, delay in ms

   
'  rotated Text
      gr.clear
      gr.setXOR       
      repeat i from 1 to 400 
         gr.color(3)
         moveTextInCircle(320/2, 240/2-16, 2, (i-1)*100, i*100, string("Drawn without Double Buffer"))
         IF i<100
            waitcnt(cnt+clkfreq/i)


'  rotated Glyphs (ROM font)
      gr.clear
      gr.setXOR       
      repeat i from 1 to 400 
         gr.color(3)
         moveGlyphsInCircle(320/2, 240/2-16, 2, (i-1)*100, i*100, string("Drawn without Double Buffer"))
         IF i<100
            waitcnt(cnt+clkfreq/i)

' pulsing frame
      gr.color(1)
      gr.setXOR
      REPEAT 5       
        gr.clear  
        repeat i from 1 to 100
          moveRect(midX+20,midY+10,i-1,i)
          moveRect(midX-30,midY-10,i-1,i)
          moveRect(midX-20,midY+30,i-1,i)
          moveRect(midX,midY,i-1,i)
          waitcnt(cnt+clkfreq/200) 
        repeat i from 99 to 0
          moveRect(midX+20,midY+10,i+1,i)
          moveRect(midX-30,midY-10,i+1,i)
          moveRect(midX-20,midY+30,i+1,i)
          moveRect(midX, midY, i+1,i)
          waitcnt(cnt+clkfreq/200) 


'  framed Text      
      repeat 1
         gr.clear 
         gr.color(3)
         gr.textmode(3, 3, 8, %%10)  ' center

         gr.setOverWrite
         'gr.setXOR 
         REPEAT 2
           gr.plot(10,10)
           gr.line(10,230)         
           gr.line(300,230)         
           gr.line(300,10)
           gr.line(10,10)
           
           gr.text(320/2, 240/2, string("No Double Buffer"))
           waitcnt(cnt+clkfreq*6)
           gr.setXOR
                                  
' pulsing BOXES

      gr.color(2)
      gr.setXOR
      'gr.setOverWrite
      REPEAT 3       
        gr.clear  
        repeat i from 2 to 100
          moveBox(midX+20,midY+10,i-1,i)
          moveBox(midX-30,midY-10,i-1,i)
          moveBox(midX-20,midY+30,i-1,i)
          moveBox(midX,midY,i-1,i)
          'waitcnt(cnt+clkfreq/200) 
        repeat i from 99 to 1
          moveBox(midX+20,midY+10,i+1,i)
          moveBox(midX-30,midY-10,i+1,i)
          moveBox(midX-20,midY+30,i+1,i)
          moveBox(midX, midY, i+1,i)
          'waitcnt(cnt+clkfreq/200)



PUB testColors|temp,temp2
  gr.clear
  gr.setOverWrite
  gr.color(2)
  gr.plot(200,200)

  temp2:=0
  gr.setXOR
  gr.setFont(gr#Clemens)
  temp2:=gr.pixelColor(200,200)
  if temp2>99
    temp.byte[0]:=(temp2/100)//10+"0"
    temp.byte[1]:=(temp2/10)//10+"0"
    temp.byte[2]:=temp2//10+"0"  
    gr.text(50,50,@temp)
  elseif temp2>9
    temp.byte[0]:=(temp2/10)//10+"0"
    temp.byte[1]:=temp2//10+"0"  
    gr.text(50,50,@temp)
  else
    temp2:=temp2+"0"
    gr.text(50,50,@temp2)
  
  waitcnt(cnt+clkfreq*2)




DAT
theGlyph                LONG    0
pixdef                  word     
                        byte    2,32,0,0
                        word    0[64]
                        long    0

PRI moveBox(mX, mY, iOld, iNew)
' restricted to drawing in vertical sync only 
   if iNew>1 
      repeat until tv_params==1
      gr.boxXOR(mX-iNew,mY-iNew, 2*iNew, 2*iNew)   
   if iOld >1
      repeat until tv_params==1       
      gr.boxXOR(mX-iOld,mY-iOld, 2*iOld, 2*iOld)  


PRI glyphMove(runningS) |NN, x,y,xx,yy,dx,dy, oldCNT , glyph, gcount
    gcount := 0
    NN := 0
    gr.setXOR
    gr.clear
    qin:=qout:=0 
    XX:=X:= cnt
    yy:=y := cnt
    dx := cnt
    dy := cnt
     
    REPEAT glyph FROM "0" to "0"+QSIZE/5-1
      ?dx
      ?dy
      x := gcount//16 *18
      y := gcount/16 * 32
      queue(glyph)
      queue(dx//10)
      queue(dy//10)
      queue(x)
      queue(y)
      ++gcount         
      gr.drawGlyph( ||x//300, ||y//220, 0, 0, 0, 0, @pixDef, glyph)
      
    waitcnt(cnt+clkfreq*10)
    oldCNT := CNT 
    repeat until CNT-oldCNT > clkfreq*runningS
       repeat gcount
         queue(glyph := dequeue)
         dx := dequeue                  
         dy := dequeue   
         x:= dequeue
         y:= dequeue
         if x<0 or x>300
           -dx
         queue(dx)   
         if y<0 or y>220
           -dy
         queue(dy)
         gr.drawGlyph( ||x//300, ||y//220, 0, 0, 0, 0, @pixDef, glyph)
 
         queue(x += dx)
         queue(y += dy)
         gr.drawGlyph( ||x//300, ||y//220, 0, 0, 0, 0, @pixDef, glyph)

PRI theWorm(wlength, delayMS) |x,y,xx,yy,dx,dy, oldCNT
    gr.setXOR
    gr.color(3)
    gr.clear
    qin:=qout:=0   
                                                 
    XX:=X:= 320/2                                                        
    yy:=y := 240/2                                                       
    dx := cnt                                                            
    dy := cnt                                                            
    gr.plot(x,y)                                                         
    gr.plot(x,y)                                                         
    REPEAT wlength                                                                    
      x += (?dx)//20                                                     
      y += (?dy)//20                                                     
      x := ||x//320                                                      
      y := ||y//240                                                      
      queue(x)                                                           
      queue(y)                                                           
      gr.line(x,y)                                                       
                                                                    
    oldCNT := CNT                                                        
    repeat until CNT-oldCNT > clkfreq*5                                  
      gr.plot(x, y)                                                      
      gr.plot(x, y)                                                      
      x += (?dx)//20                                                     
      y += (?dy)//20                                                     
      x := ||x//320                                                      
      y := ||y//240                                                      
      queue(x)                                                           
      queue(y)                                                           
      gr.line(x, y)                                                      
       gr.plot(xx,yy)                                                    
       gr.plot(xx,yy)                                                    
       xx:= dequeue                                                      
       yy:= dequeue                                                                  
       gr.line(xx, yy)                                                   
       IF delayMS                                                        
          waitcnt(cnt+clkfreq/1000*delayMS)                              

            
PRI moveRect(mX, mY, iOld, iNew)
   gr.plot(mX-iNew,mY-iNew)                    
   gr.line(mX-iNew,mY+iNew)                    
   gr.line(mX+iNew,mY+iNew)                    
   gr.line(mX+iNew,mY-iNew)                    
   gr.line(mX-iNew,mY-iNew)
                       
   if iOld   
      gr.plot(mX-iOld,mY-iOld) 
      gr.line(mX-iOld,mY+iOld)
      gr.line(mX+iOld,mY+iOld) 
      gr.line(mX+iOld,mY-iOld)
      gr.line(mX-iOld,mY-iOld)

PRI moveTextInCircle(x,y, csize, oldOffset, newOffset, theString)  | i, rad, charCount, radOffset, shortStr
  charCount := strsize(theString)
  radOffset := 1024*8/(charCount+1)
  gr.textmode(csize, csize, 0, %%10)  ' center  
  rad := charcount*csize*8/5
  shortStr := 0
  REPEAT i from 0 to charCount-1
     shortStr := BYTE[theString][i]
     If oldOffset>0
       gr.textarc(x, y, rad, rad, oldOffset+charCount-i*radOffset, @shortStr)       
     gr.textarc(x, y, rad, rad, newOffset+charCount-i*radOffset, @shortStr)
     gr.finish


PRI moveGlyphsInCircle(x,y, csize, oldOffset, newOffset, theString)  | {
    local vars: }      buffer, i, rad, charCount, radOffset
  charCount := strsize(theString)
  radOffset := 1024*8/(charCount+1) 
  rad := charcount*csize*2

  REPEAT i from 0 to charCount-1
     If oldOffset>0
       gr.drawGlyph(x,y,rad,rad,oldOffset+charCount-i*radOffset,0,@pixDef,BYTE[theString][i])
     gr.drawGlyph(x,y,rad,rad,newOffset+charCount-i*radOffset,0,@pixDef,BYTE[theString][i])
     gr.finish

CON
    tdXX = 3
    tdYY = 6
    tdXXsize = 320/tdXX
    tdYYsize = 240/tdYY

PRI makeTechDisplay(size, vec)| xx,yy, bg
    REPEAT xx FROM 0 to tdXX-1
       REPEAT yy FROM 0 to tdYY-1
         gr.setOverwrite
         gr.color(xx+yy)
         gr.boxXOR(xx*tdXXsize, yy*tdYYsize,tdXXsize-1, tdYYsize-1)
         gr.setXOR

Pri histogram(tdX, yVec,lasty)|y,xx,yy,y2, tdXsize
    tdXsize := 320/tdX
    gr.setXOR
    REPEAT xx FROM 0 to tdX-1
         gr.color(xx//3+1)
        ?yy
          
        y2 := long[lastY][xx]
        
        y := ||(y2 + yy//10) #> 0
        if y-y2>0   
          repeat until tv_params==1
          gr.boxXOR(xx*tdXsize, y2,tdXsize-1, y-y2)
        elseif y-y2<0
          repeat until tv_params==1
          gr.boxXOR(xx*tdXsize, y,tdXsize-1, y2-y)
        long[lastY][xx] := y

PRI setupFull|dx,dy
  'init tile screen
  repeat dx from 0 to cols - 1
    repeat dy from 0 to xrows - 1
      screen[dy * cols + dx] := bitmap_2 >> 6 + dy + dx * xrows + (0 << 10)

  gr.setup(nChars, 15, 0, 0, bitmap_2) 

CON
  QSIZE =300
  
VAR
  LONG Q[QSIZE]
  LONG qIn,qOut
  
PRI queue(x)
  Q[qIn++]:=x
  qIn //= QSIZE

PRI deQueue:x
  x := Q[qOut++]
  qOut //= QSIZE  
      
'===================================================================
'Routines from MPE_TEXT
'===================================================================                 
PUB start(basepin, colRequest, interlaced) : okay
'' Start terminal - starts a cog
'' returns false if no cog available 
  tv_pins := (basepin & $38) << 1 | (basepin & 4 == 4) & %0101
  tv_screen := @screen
  tv_colors := @fourColors
  
  okay := tv.start(@tv_params)

  configure(colRequest,interlaced)    


PUB configure(colRequest,interlaced)
  cols := colRequest <# maxcols
  xrows := maxrows
 
'' cols*vt_hx have to be <=180, e.g. 20-9, or 30-6, or 45-4 
  tv_hx := 180/cols
  if tv_hx<4
     tv_hx:= 3
     cols := maxcols  ' 40 for interlaced
     

  tv_mode &= !2

  if interlaced
    cols := cols <# 40 
    tv_mode |=  2
  else
    xrows := 15'xrows/4*2 ' keep even
     
  tv_rows := xrows  
  tv_cols := cols

DAT

tv_params               long    0               'status
                        long    1               'enable
tv_pins                 long    %0              'pins
tv_mode                 long    %00001             'mode

''  tv_mode
''
''    bit 4 selects between 16x16 and 16x32 pixel tiles:
''      0: 16x16 pixel tiles (tileheight = 16)
''      1: 16x32 pixel tiles (tileheight = 32)
''
''    bit 3 controls chroma mixing into broadcast:
''      0: mix chroma into broadcast (color)
''      1: strip chroma from broadcast (black/white)
''
''    bit 2 controls chroma mixing into baseband:
''      0: mix chroma into baseband (composite color)
''      1: strip chroma from baseband (black/white or s-video)
''
''    bit 1 controls interlace:
''      0: progressive scan (243 display lines for NTSC, 286 for PAL)
''           less flicker, good for motion
''      1: interlaced scan (486 display lines for NTSC, 572 for PAL)
''           doubles the vertical display lines, good for text
''
''    bit 0 selects NTSC or PAL format
''      0: NTSC
''           3016 horizontal display ticks
''           243 or 486 (interlaced) vertical display lines
''           CLKFREQ must be at least 14_318_180 (4 * 3_579_545 Hz)*
''      1: PAL
''           3692 horizontal display ticks
''           286 or 572 (interlaced) vertical display lines
''           CLKFREQ must be at least 17_734_472 (4 * 4_433_618 Hz)*
''
''      * driver will disable itself while CLKFREQ is below requirement
                          
tv_screen               long    0               'screen
tv_colors               long    0               'colors
tv_cols                 long    40              'hc
tv_rows                 long    26              'vc
tv_hx                   long    4               'hx
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    0               'broadcast
                        long    0               'auralcog

{ original TV.SPIN


                        '       fore   back
                        '       color  color
palette                 byte    $07,   $0A    '0    white / dark blue
                        byte    $07,   $BB    '1    white / red
                        byte    $9E,   $9B    '2   yellow / brown
                        byte    $04,   $07    '3     grey / white
                        byte    $3D,   $3B    '4     cyan / dark cyan
                        byte    $6B,   $6E    '5    green / gray-green
                        byte    $BB,   $CE    '6      red / pink
                        byte    $3C,   $0A    '7     cyan / blue
}

'Change deSilva for simple Black/White
                        '       fore   back
                        '       color  color
palette
                        byte    $06,   $7E
'                        byte    $06,   $02    '0    white / black
                        byte    $02,   $06    '1    black / white
                        byte    $03,   $02    '2    gray  / black
                        byte    $02,   $03    '3    black / gray
                        byte    $04,   $06    '4    gray / white
                        byte    $06,   $04    '5    white / gray
                        byte    $06,   $02    '6    white / black
                        byte     0,    0


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