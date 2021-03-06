''***************************************
''*  T6963 driver  V1.1                 *
''*  Author: Erik Friesen               *
''*  Copyright (c) 2009 Erik Friesen    *               
''*  See end of file for terms of use.  *               
''***************************************
'' Tested on 240x128 only
'' loopset command is for auto update option.  If loopset is one or greater you must call updatelcd for the buffer to update.

CON
_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000

mask=1      


pixelwidth = 240
pixelheight= 128
totalsize = (pixelwidth*pixelheight)/8
byteswide = pixelwidth/8
VAR
long    flag,position,shiftdn,shiftrt,height,contrast,off
word    characterposition
byte    chartoprint,sizecolor,loopcommand,loopgo,test3,test4
byte    data[totalsize+1] 
byte    cols,col,rows,row,size,color,move


PUB Start(WRpin,RDpin,CEpin,CDpin,RSTpin,DB0p,DB7p,loopset) |q'no backlight
  waitcnt(5_000_000+cnt)'Wait for screen to stabilize
  'contrast:=%100000
  long[@data]:=@SL       'send address pointers
  long[@data+4]:=@Bl     'to assembly
  long[@data+8]:=@characterposition
  long[@data+12]:=@chartoprint
  data[20]:=WRpin
  data[21]:=RDpin
  data[22]:=CEpin
  data[23]:=CDpin
  data[24]:=RSTpin
  data[25]:=DB0p
  data[26]:=0
  if DB0p>DB7p  'in case of reversed pins
    data[26]:=$FF
    data[25]:=DB7p
  cognew(@entry,@data)
  waitcnt(5_000_000+cnt)
  out($d)   'initialize  with small size )
  out(1) 
  out(0)
  loopcommand:=loopset

  
return @data
PUB Turn_off_lcd
  out(0)
  off:=10
return
pub getit
return data[0]
PUB UpdateLCD
repeat until sizecolor==0
loopgo:=1

PUB str(stringptr)
'' Print a zero-terminated string
  repeat strsize(stringptr)
    out(byte[stringptr++])
  color:=0
PUB strsp(spaces,stringptr)|total
'' Print a zero-terminated string
  total~
  repeat strsize(stringptr)
    out(byte[stringptr++])
    total++
  repeat spaces-total+1
    out(" ")
    
  color:=0
  
pub filestr(stringptr)|a
  repeat a from 0 to 7 
    if byte[stringptr+a]>10
      out(byte[stringptr+a])

  color:=0
pub filestrRev(stringptr)|a
  repeat a from 7 to 0 
    if byte[stringptr+a]>10
      out(byte[stringptr+a])

  color:=0
PUB dec(value,dpoint,clearpoint) | i,a,b,c'with 6 digit floating point limiter

'' Print a decimal number
  if value < 0
    -value
    out("-")
  if value>99999 and clearpoint<7
    value:=value/10
    dpoint:=dpoint-1

  i := 1_000_000_000
  b:=11-dpoint
  c:=clearpoint
  repeat a from 1 to 10 
    if a==b
      if dpoint>0
        out(".")
        c:=c-1 #>0
    if value => i or a=>b
      out(value / i + "0")
      value //= i
      result~~
     c:=c-1 #>0
    elseif result or i == 1
      out("0")
     c:=c-1 #>0
    i /= 10
  repeat c
    out(" ")


PUB SetPixel(x,y)    ' x between 0..63, y between 0..123

' compute the byte in wich the selected pixel is
     data[(x*byteswide)+(y/8)]:=data[(x*byteswide)+(y/8)]| (mask <<(y&%0000111))


PUB ClearPixel(x,y)    ' x between 0..63, y between 0..123

' compute the byte in wich the selected pixel is
     data[(x*byteswide)+(y/8)]:=data[(x*byteswide)+(y/8)] & ! (mask <<(y&%0000111))

pub bytein(bn,byt)

  data[bn]:=byt
PUB hex(value, digits)

'' Print a hexadecimal number

  value <<= (8 - digits) << 2
  repeat digits
    out(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))   
PUB line (xi,yi,xf,yf,state) | dx,dy,i,xinc,yinc,cumul,x1,y1

'Brehsenham algorithm for line drawing (see internet for more details on Brehsenham algorithm)

x1 := xi 
y1 := yi 
dx := xf - xi 
dy := yf - yi

  if dx> 0
    xinc := 1
  else
   xinc := -1

  if dy> 0
    yinc := 1
  else
   yinc := -1
    

dx := ||(dx) 
dy := ||(dy)
 
  if state
    setpixel(x1,y1)
  else
   ClearPixel(x1,y1)

  if ( dx > dy )
     
    cumul := dx >> 2 
    i := 0 
      repeat 
         
        x1 += xinc 
        cumul += dy 
          if (cumul > dx)
            cumul -= dx 
            y1 += yinc 
             
        if state
         setpixel(x1,y1)
        else
         ClearPixel(x1,y1)
      
        i++
      while  i < dx
       
  else 
     cumul := dy >> 2
     i := 0
      repeat 
        y1 += yinc 
        cumul += dx 
          if ( cumul > dy ) 
            cumul -= dy 
            x1 += xinc
 
        if state
         setpixel(x1,y1)
        else
         ClearPixel(x1,y1)
  
        i++
      while i < dy
       

PUB Box(x1, y1, x2, y2, fill,state) | y,ymax,i 

     
       Line(x1, y1, x2, y1,state)
       Line(x1, y2, x2, y2,state)
       Line(x1, y1, x1, y2,state)
       Line(x2, y1, x2, y2,state)



PUB bin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    out((value <-= 1) & 1 + "0")


PUB out(c) | i, k

'' Output a character
''
''     $00 = clear screen
''     $01 = home
''     $08 = backspace
''     $09 = tab (8 spaces per)
''     $0A = set X position (X follows)
''     $0B = set Y position (Y follows)
''     $0C = set color (color follows)
''     $0D = set size (size follows)(1-4)
''     $0E = set downshift  (for precise placement on screen)
''     $0F = set rightshift
''  others = printable characters

  case flag
    $00: case c
           $00: bytefill(@data,%00000000,totalsize) 'clears screen
                col := row := 0
           $01: col := row := shiftdn := shiftrt := 0 
       
           $08: if col
                  col--
           $09: repeat
                  print(" ")
                while col & 7
           $0A..$0F: flag := c
                     return
           $C1:color:=0
           $C2:color:=1
           $CC: newline
           $cf: shiftrt:=shiftrt+2
           $d0..$d7:col:=0
             row:= (c-$d0)//rows
           other: print(c)
           
    $0A: col := c // cols
    $0B: row := c // rows
    $0C: color := c & 3-1
    $0D: if c==4
             cols:=byteswide/2
             height:=32
             rows:=pixelheight/32'2
             move:=16
             shiftdn:=0
             shiftrt:=0
         if c==3
             cols:=byteswide*2/3 
             height:=16
             rows:=pixelheight/16'4
             move:=12
             shiftdn:=0
             shiftrt:=0 
         if c==2
             cols:=byteswide
             height:=12
             rows:=pixelheight/12'5
             move:=8
             shiftdn:=0
             shiftrt:=0
         if c==1
             cols:=(byteswide*8)/6
             height:=8
             rows:=pixelheight/8
             move:=6
             shiftdn:=0
             shiftrt:=0     
     col := row := 0
     size:=c            
    $0E: shiftdn:=c*pixelwidth
    $0F: shiftrt:=c*4
  flag := 0


PRI newline | i

  col := 0
  if ++row => rows
    row:=0  
    

PUB Print(chr)
  position:=((pixelwidth*height)*row)+(col*move+shiftrt)+shiftdn
  repeat until sizecolor==0
  characterposition:=position
  chartoprint:=chr
  sizecolor :=(size<<1+color)
  if ++col == cols
    newline

PUB writegraphics|place,hold1,hold2
  repeat until sizecolor==0 'wait til previous letter printed  
  place:=0
  characterposition:=0
  chartoprint:=0
  sizecolor:=(5<<1+color)

dat
                             'size 1-5x8 letters
SL            long      %00_00000_00100_00000_00000_00100_00000     '12
              long      %00_00000_00100_01010_01010_01111_11001
              long      %00_00000_00100_00000_11111_10100_00010
              long      %00_00000_00100_00000_01010_01110_00100
              long      %00_00000_00100_00000_01010_00101_01000
              long      %00_00000_00000_00000_11111_11110_10011
              long      %00_00000_00100_00000_01010_00100_00000
              long      %00_00000_00000_00000_00000_00000_00000
               '              &     '      (    )     *     +
              long      %00_01100_00100_00100_00100_00000_00000
              long      %00_10010_00100_01000_00010_00100_00100
              long      %00_10100_00000_01000_00010_10101_00100
              long      %00_01000_00000_01000_00010_01110_11111  
              long      %00_10101_00000_01000_00010_10101_00100  
              long      %00_10010_00000_01000_00010_00100_00100  
              long      %00_01101_00000_00100_00100_00000_00000  
              long      %00_00000_00000_00000_00000_00000_00000  
                            '  ,    -     .     /     0     1
              long      %00_00000_00000_00000_00000_01110_00100      '24
              long      %00_00000_00000_00000_00001_10001_01100
              long      %00_00000_00000_00000_00010_10011_00100
              long      %00_00000_11111_00000_00100_10101_00100
              long      %00_00000_00000_00000_01000_11001_00100
              long      %00_00000_00000_00110_10000_10001_00100
              long      %00_00010_00000_00110_00000_01110_11111
              long      %00_00010_00000_00000_00000_00000_00000
                        '     2     3     4     5     6     7
              long      %00_01110_01110_00010_11111_01110_11111
              long      %00_10001_10001_00110_10000_10001_00001
              long      %00_00001_00001_01010_10000_10000_00010
              long      %00_00010_00110_10010_11110_11110_00100
              long      %00_00100_00001_11111_00001_10001_01000
              long      %00_01000_10001_00010_10001_10001_01000
              long      %00_11111_01110_00010_01110_01110_01000
              long      %00_00000_00000_00000_00000_00000_00000
                        '     8     9     :     ;     <     =
              long      %00_01110_01110_00000_00000_00000_00000      '36
              long      %00_10001_10001_00000_00000_00011_00000
              long      %00_10001_10001_00100_00100_01100_11111
              long      %00_01110_01111_00000_00000_10000_00000
              long      %00_10001_00001_00100_00100_01100_11111
              long      %00_10001_10001_00000_01000_00011_00000
              long      %00_01110_01110_00000_00000_00000_00000
              long      %00_00000_00000_00000_00000_00000_00000
                         '    >     ?     @     A     B     C
              long      %00_00000_01110_01110_01110_11110_01110
              long      %00_11000_10001_10001_10001_10001_10001
              long      %00_00110_00001_10101_10001_10001_10000
              long      %00_00001_00010_10110_11111_11110_10000
              long      %00_00110_00100_10110_10001_10001_10000
              long      %00_11000_00000_10001_10001_10001_10001
              long      %00_00000_00100_01110_10001_11110_01110
              long      %00_00000_00000_00000_00000_00000_00000

              long      %00_11110_11111_11111_01110_10001_11111      '48
              long      %00_10001_10000_10000_10001_10001_00100
              long      %00_10001_10000_10000_10000_10001_00100
              long      %00_10001_11110_11110_10000_11111_00100
              long      %00_10001_10000_10000_10011_10001_00100
              long      %00_10001_10000_10000_10001_10001_00100
              long      %00_11110_11111_10000_01110_10001_11111
              long      %00_00000_00000_00000_00000_00000_00000

              long      %00_00001_10001_10000_10001_10001_01110
              long      %00_00001_10010_10000_11011_10001_10001
              long      %00_00001_10100_10000_10101_11001_10001
              long      %00_00001_11000_10000_10101_10101_10001
              long      %00_00001_10100_10000_10001_10011_10001
              long      %00_10001_10010_10000_10001_10001_10001
              long      %00_01110_10001_11111_10001_10001_01110
              long      %00_00000_00000_00000_00000_00000_00000
                        
              long      %00_11110_01110_11110_01110_11111_10001      '60
              long      %00_10001_10001_10001_10001_10101_10001
              long      %00_10001_10001_10001_01000_00100_10001
              long      %00_11110_10001_11110_00100_00100_10001
              long      %00_10000_10001_10010_00010_00100_10001
              long      %00_10000_10101_10001_10001_00100_10001
              long      %00_10000_01110_10001_01110_00100_01110
              long      %00_00000_00010_00000_00000_00000_00000
                           '  V     W     X     Y     Z     [
              long      %00_10001_10001_10001_10001_11111_11110
              long      %00_10001_10001_01010_10001_00001_10000
              long      %00_10001_10001_01010_01010_00010_10000
              long      %00_10001_10001_00100_00100_00100_10000
              long      %00_10001_10101_01010_00100_01000_10000
              long      %00_01010_10101_01010_00100_10000_10000
              long      %00_00100_01010_10001_00100_11111_11110
              long      %00_00000_00000_00000_00000_00000_00000
                                                           'a
              long      %00_00000_01111_00000_00000_00000_00000      '72
              long      %00_10000_00001_00000_00000_00000_00000
              long      %00_01000_00001_00100_00000_01000_01110
              long      %00_00100_00001_01010_00000_00100_00001
              long      %00_00010_00001_01010_00000_00000_01111
              long      %00_00001_00001_10001_00000_00000_10001
              long      %00_00000_01111_00000_11111_00000_01111
              long      %00_00000_00000_00000_00000_00000_00000
                         '    b      c     d    e     f      g
              long      %00_10000_00000_00001_00000_00110_00000
              long      %00_10000_00000_00001_00000_01001_00000
              long      %00_10110_01110_01101_01110_01000_01110
              long      %00_11001_10001_10011_10001_11100_10001
              long      %00_10001_10000_10001_11111_01000_10001
              long      %00_10001_10001_10001_10000_01000_01111
              long      %00_11110_01110_01111_01110_01000_00001
              long      %00_00000_00000_00000_00000_00000_01110
                         '    h     i     j     k     l     m
              long      %00_10000_00000_00000_10000_01100_00000      '84
              long      %00_10000_00100_00100_10000_00100_00000
              long      %00_10000_00000_00000_10010_00100_11010
              long      %00_11110_01100_01100_10100_00100_10101
              long      %00_10001_00100_00100_11000_00100_10101
              long      %00_10001_00100_00100_10100_00100_10001
              long      %00_10001_01110_10100_10010_01110_10001
              long      %00_00000_00000_01000_00000_00000_00000
                         '    n     o     p     q    r      s
              long      %00_00000_00000_00000_00000_00000_00000
              long      %00_00000_00000_00000_00000_00000_00000
              long      %00_10110_01110_11110_01111_10110_01111
              long      %00_11001_10001_10001_10001_11001_10000
              long      %00_10001_10001_10001_10001_10000_01110
              long      %00_10001_10001_11110_01111_10000_00001
              long      %00_10001_01110_10000_00001_10000_11110
              long      %00_00000_00000_10000_00001_00000_00000
                         '    t    u      v     w     x     z
              long      %00_00100_00000_00000_00000_00000_00000      '96
              long      %00_00100_00000_00000_00000_00000_00000
              long      %00_11111_10001_10001_10001_10001_10001
              long      %00_00100_10001_10001_10001_01010_10001
              long      %00_00100_10001_10001_10001_00100_10001
              long      %00_00101_10001_01010_10101_01010_01101
              long      %00_00010_01110_00100_01010_10001_00010
              long      %00_00000_00000_00000_00000_00000_01100

              long      %00_00000_00110_00100_1111000000_10000
              long      %00_00000_01000_00100_1000000110_10010
              long      %00_11111_01000_00100_1110001001_10100
              long      %00_00010_11000_00100_0001001001_01010
              long      %00_00100_01000_00100_1110100110_10101
              long      %00_01000_01000_00100_0001001001_00001 
              long      %00_11111_00110_00100_0010001001_00010
              long      %00_00000_00000_00000_0000000110_00111

                  'size 2-7x11 letters            #
BL            long  %00000000_00000000_00000000_00000000
              long  %00000000_00110000_01101100_00101000
              long  %00000000_00110000_01101100_00101000
              long  %00000000_00110000_00100100_11111110
              long  %00000000_00110000_00000000_00101000
              long  %00000000_00110000_00000000_00101000
              long  %00000000_00110000_00000000_00101000
              long  %00000000_00000000_00000000_11111110
              long  %00000000_00110000_00000000_00101000
              long  %00000000_00110000_00000000_00101000
              long  %00000000_00000000_00000000_00000000 
                  '    $         %        &        '
              long  %00010000_11100010_01110000_00000000 
              long  %00111000_10100110_11011000_00110000 
              long  %01010100_11101100_11010000_00110000                       
              long  %01010000_00001000_01100000_00010000 
              long  %00111000_00011000_01100000_00000000   
              long  %00010100_00110000_11110010_00000000                              
              long  %00010100_01100000_11011100_00000000           
              long  %01010100_01001110_11001100_00000000                           
              long  %00111000_11001010_11011110_00000000          
              long  %00010000_10001110_01110010_00000000
              long  %00000000_00000000_00000000_00000000
              '(                )         *         +
              long  %00011000_00110000_00000000_00000000
              long  %00110000_00011000_00000000_00000000
              long  %00110000_00011000_00010000_00011000
              long  %01100000_00001100_01010100_00011000
              long  %01100000_00001100_00111000_01111110
              long  %01100000_00001100_00010000_01111110
              long  %00110000_00011000_00111000_00011000
              long  %00110000_00011000_01010100_00011000
              long  %00011000_00110000_00010000_00000000
              long  %00000000_00000000_00000000_00000000
              long  %00000000_00000000_00000000_00000000

              long  %00000000_00000000_00000000_00000010
              long  %00000000_00000000_00000000_00000110        
              long  %00000000_00000000_00000000_00000100 
              long  %00000000_00000000_00000000_00001000
              long  %00000000_01111110_00000000_00011000
              long  %00000000_01111110_00000000_00110000
              long  %00000000_00000000_00000000_00100000
              long  %00000000_00000000_00000000_01000000
              long  %00110000_00000000_00110000_11000000
              long  %00110000_00000000_00110000_10000000
              long  %00010000_00000000_00000000_00000000
        
                         '0     1         2         3
              long  %01111100_00011000_01111100_01111100
              long  %11000110_00111000_11000110_11000110
              long  %11000110_01111000_00000110_00000110
              long  %11000110_00011000_00001100_00000110
              long  %11010110_00011000_00011000_00111100
              long  %11010110_00011000_00110000_00000110
              long  %11000110_00011000_01100000_00000110
              long  %11000110_00011000_11000010_00000110
              long  %11000110_00011000_11000110_11000110
              long  %01111100_01111110_11111110_01111100
              long  %00000000_00000000_00000000_00000000
                      '4        5       6          7
              long  %00001100_11111110_00111000_11111110
              long  %00011100_11000000_01100000_11000110
              long  %00111100_11000000_11000000_00000110
              long  %01101100_11000000_11000000_00001100
              long  %11001100_11111100_11111100_00001100
              long  %11001100_00000110_11000110_00011000
              long  %11111110_00000110_11000110_00011000
              long  %00001100_11000110_11000110_00110000
              long  %00001100_11100110_11000110_00110000
              long  %00011110_01111100_01111100_00110000
              long  %00000000_00000000_00000000_00000000
                       '8        9
              long  %01111100_01111100_00000000_00000000
              long  %11000110_11000110_00000000_00000000
              long  %11000110_11000110_00011000_00011000
              long  %11000110_11000110_00011000_00011000
              long  %01111100_11000110_00000000_00000000
              long  %11000110_01111110_00000000_00000000
              long  %11000110_00000110_00000000_00011000
              long  %11000110_00000110_00011000_00011000
              long  %11000110_00001100_00011000_00001000
              long  %01111100_01111000_00000000_00000000
              long  %00000000_00000000_00000000_00000000
                    '<           =       >          ?
              long  %00000000_00000000_00000000_01111000
              long  %00000110_00000000_11000000_11001100
              long  %00011000_00000000_00110000_00001100
              long  %01100000_01111100_00001100_00001100
              long  %11000000_00000000_00000110_00011000
              long  %11000000_00000000_00000110_00011000
              long  %01100000_01111100_00001100_00110000
              long  %00011000_00000000_00110000_00000000
              long  %00000110_00000000_11000000_00110000
              long  %00000000_00000000_00000000_00110000
              long  %00000000_00000000_00000000_00000000
                '       @       A         B        C
              long  %00000000_00111000_11111100_01111100
              long  %00000000_01101100_11000110_11000110
              long  %00111000_11000110_11000110_11000000
              long  %01000100_11000110_11000110_11000000
              long  %01011100_11000110_11111100_11000000
              long  %01010100_11111110_11000110_11000000
              long  %01011100_11000110_11000110_11000000
              long  %01000000_11000110_11000110_11000000
              long  %01000100_11000110_11000110_11000110
              long  %00111000_11000110_11111100_01111100
              long  %00000000_00000000_00000000_00000000
                    '  D         E        F       G
              long  %11111100_11111110_11111110_01111100
              long  %11000110_11000000_11000000_11000110
              long  %11000110_11000000_11000000_11000000
              long  %11000110_11000000_11000000_11000000
              long  %11000110_11111100_11111100_11000000
              long  %11000110_11000000_11000000_11011110
              long  %11000110_11000000_11000000_11000110
              long  %11000110_11000000_11000000_11000110
              long  %11000110_11000000_11000000_11000110
              long  %11111100_11111110_11000000_01111100
              long  %00000000_00000000_00000000_00000000
                    '  H          I        J        K
              long  %11000110_01111110_00000110_11000110
              long  %11000110_00011000_00000110_11001100
              long  %11000110_00011000_00000110_11011000
              long  %11000110_00011000_00000110_11110000
              long  %11111110_00011000_00000110_11100000
              long  %11000110_00011000_00000110_11100000
              long  %11000110_00011000_11000110_11110000
              long  %11000110_00011000_11000110_11011000
              long  %11000110_00011000_11000110_11001100
              long  %11000110_01111110_01111100_11000110
              long  %00000000_00000000_00000000_00000000
              '          L      M         N        O
              long  %11000000_11000110_11000110_01111100
              long  %11000000_11101110_11000110_11000110
              long  %11000000_11101110_11100110_11000110
              long  %11000000_11111110_11100110_11000110
              long  %11000000_11010110_11010110_11000110
              long  %11000000_11000110_11010110_11000110
              long  %11000000_11000110_11001110_11000110
              long  %11000000_11000110_11001110_11000110
              long  %11000000_11000110_11000110_11000110
              long  %11111110_11000110_11000110_01111100
              long  %00000000_00000000_00000000_00000000
                      'P        Q         R        S
              long  %11111100_01111100_11111100_01111100
              long  %11000110_11000110_11000110_11000110
              long  %11000110_11000110_11000110_11000000
              long  %11000110_11000110_11000110_11000000
              long  %11111100_11000110_11111100_01111100
              long  %11000000_11000110_11110000_00000110
              long  %11000000_11000110_11011000_00000110
              long  %11000000_11000110_11001100_00000110
              long  %11000000_11010110_11000110_11000110
              long  %11000000_01111100_11000110_01111100
              long  %00000000_00000100_00000000_00000000
                    '   T        U       V        W
              long  %01111110_11000110_11000110_11000110
              long  %00011000_11000110_11000110_11000110
              long  %00011000_11000110_11000110_11000110
              long  %00011000_11000110_11000110_11000110
              long  %00011000_11000110_11000110_11000110
              long  %00011000_11000110_11000110_11010110
              long  %00011000_11000110_11000110_11010110
              long  %00011000_11000110_01101100_11010110
              long  %00011000_11000110_01101100_11010110
              long  %00011000_01111100_00111000_01101100
              long  %00000000_00000000_00000000_00000000             

                      'X        Y         Z       [
              long  %11000110_01100110_11111110_01111110
              long  %11000110_01100110_00000110_01100000
              long  %01101100_01100110_00000110_01100000
              long  %01101100_01100110_00001100_01100000
              long  %00111000_00111100_00011000_01100000
              long  %00111000_00011000_00110000_01100000
              long  %01101100_00011000_01100000_01100000
              long  %01101100_00011000_11000000_01100000
              long  %11000110_00011000_11000000_01100000
              long  %11000110_00011000_11111110_01111110
              long  %00000000_00000000_00000000_00000000             

                       '\       ]         ^        _
              long  %11000000_01111110_00010000_00000000
              long  %01100000_00000110_00111000_00000000
              long  %01100000_00000110_01101100_00000000
              long  %00110000_00000110_11000110_00000000
              long  %00110000_00000110_10000010_00000000
              long  %00011000_00000110_00000000_00000000
              long  %00011000_00000110_00000000_00000000
              long  %00001100_00000110_00000000_00000000
              long  %00001100_00000110_00000000_00000000
              long  %00000110_01111110_00000000_11111111
              long  %00000000_00000000_00000000_00000000             
                      '`         a        b       c
              long  %00000000_00000000_11000000_00000000
              long  %01100000_00000000_11000000_00000000
              long  %01100000_00000000_11000000_00000000
              long  %00100000_01111100_11111100_01111100
              long  %00000000_11000110_11000110_11000110
              long  %00000000_00000110_11000110_11000000
              long  %00000000_01111110_11000110_11000000
              long  %00000000_11000110_11000110_11000000
              long  %00000000_11000110_11000110_11000110
              long  %00000000_01111110_11111100_01111100
              long  %00000000_00000000_00000000_00000000
                        'd        e       f        g
              long  %00000110_00000000_00000000_00000000
              long  %00000110_00000000_00011100_00000000
              long  %00000110_00000000_00110000_00000000
              long  %01111110_01111100_00110000_01111100
              long  %11000110_11000110_00110000_11000110
              long  %11000110_11000110_11111100_11000110
              long  %11000110_11111100_00110000_11000110
              long  %11000110_11000000_00110000_01111110
              long  %11000110_11000110_00110000_00000110
              long  %01111110_01111100_00110000_00000110
              long  %00000000_00000000_00000000_01111100
                      'h       i            j      k
              long  %11000000_00000000_00000000_00000000
              long  %11000000_00011000_00011000_11000000
              long  %11000000_00011000_00011000_11000000
              long  %11000000_00000000_00000000_11000110
              long  %11111100_00111000_00111000_11001100
              long  %11000110_00011000_00011000_11011000
              long  %11000110_00011000_00011000_11110000
              long  %11000110_00011000_00011000_11011000
              long  %11000110_00011000_00011000_11001100
              long  %11000110_00111100_00011000_11000110
              long  %00000000_00000000_01110000_00000000
                       ' l         m       n        o
              long  %00111000_00000000_00000000_00000000
              long  %00011000_00000000_00000000_00000000
              long  %00011000_00000000_00000000_00000000
              long  %00011000_11000110_11011100_01111100
              long  %00011000_11101110_11100110_11000110
              long  %00011000_11010110_11000110_11000110
              long  %00011000_11010110_11000110_11000110
              long  %00011000_11000110_11000110_11000110
              long  %00011000_11000110_11000110_11000110
              long  %01111110_11000110_11000110_01111100
              long  %00000000_00000000_00000000_00000000
                       'p       q        r        s
              long  %00000000_00000000_00000000_00000000
              long  %00000000_00000000_00000000_00000000
              long  %00000000_00000000_00000000_00000000
              long  %11111100_01111110_11011100_01111100
              long  %11000110_11000110_11100110_11000110
              long  %11000110_11000110_11000110_11000000
              long  %11000110_11000110_11000000_01111100
              long  %11000110_11000110_11000000_00000110
              long  %11111100_01111110_11000000_11000110
              long  %11000000_00000110_11000000_01111100
              long  %11000000_00000110_00000000_00000000
                     't         u         v        w
              long  %00000000_00000000_00000000_00000000
              long  %00011000_00000000_00000000_00000000
              long  %00011000_00000000_00000000_00000000
              long  %00011000_11000110_01100110_11000110
              long  %01111110_11000110_01100110_11000110
              long  %00011000_11000110_01100110_11000110
              long  %00011000_11000110_01100110_11010110
              long  %00011000_11000110_01100110_11010110
              long  %00011000_11001110_00111100_11010110
              long  %00001110_01110110_00011000_11101110
              long  %00000000_00000000_00000000_00000000
                      'x          y       z       {
              long  %00000000_00000000_00000000_00011100
              long  %00000000_00000000_00000000_00011000
              long  %00000000_00000000_00000000_00110000
              long  %11000110_11000110_11111110_00110000
              long  %01101100_11000110_00001100_01100000
              long  %00111000_11000110_00011000_01100000
              long  %00111000_11000110_00110000_00110000
              long  %00111000_11000110_01100000_00110000
              long  %01101100_01111110_11000000_00011000
              long  %11000110_00000110_11111110_00011100
              long  %00000000_01111100_00000000_00000000 
   
        
DAT

'**************************************
'* Assembly language KS0713 driver    *
'**************************************

                        org  
'                                                         
entry                   mov     pointer,par
                        mov     temp1,par
                        rdlong  Sltable,temp1  'get lettertable pointers
                        wrlong  zero,temp1
                        add     temp1,#4
                        rdlong  Bltable,temp1
                        wrlong  zero,temp1 
                        add     temp1,#4
                        rdlong  charpospointer,temp1
                        wrlong  zero,temp1 
                        add     temp1,#4
                        rdlong  chartoprintpointer,temp1
                        wrlong  zero,temp1                         
                        mov     sizecolorpointer,chartoprintpointer
                        add     sizecolorpointer,#1
                        mov     loopcommandpointer,chartoprintpointer
                        add     loopcommandpointer,#2
                        mov     loopgopointer,chartoprintpointer
                        add     loopgopointer,#3 'set up pointers here

                        mov     temp1,par
                        add     temp1,#20'lets get the pins here
                        'first pin
                        mov     WRS,#1
                        rdbyte  pinset,temp1
                        shl     WRS,pinset
                        'second
                        mov     RD,#1
                        add     temp1,#1
                        rdbyte  pinset,temp1
                        shl     RD,pinset
                        'third
                        mov     CE,#1
                        add     temp1,#1
                        rdbyte  pinset,temp1
                        shl     CE,pinset
                        'fourth
                        mov     CD,#1
                        add     temp1,#1
                        rdbyte  pinset,temp1
                        shl     CD,pinset
                        'fifth
                        mov     reset,#1
                        add     temp1,#1
                        rdbyte  pinset,temp1
                        shl     reset,#pinset
                        'db0-7
                        add     temp1,#1
                        rdbyte  DB0,temp1
                        mov     datapins,#$FF
                        shl     datapins,db0

                        add     temp1,#1
                        rdbyte  reversed,temp1 'hold here for reversed pins or not
                        'config pins
                        or      dira,datapins
                        'or     dira,outs
                        or      dira,reset
                        or      outa,reset
                        or      outa,WRS
                        or      dira,WRS
                        or      outa,RD
                        or      dira,RD
                        or      outa,CE
                        or      dira,CE
                        or      outa,CD
                        or      dira,CD 
                        andn    outa,reset 
                        call    #delayms
                        or      outa,reset
                        call    #delayms

                        
                        'SetGraphicsBaseAddress(GraphicsBaseAddress)                        
                        mov     first,zero
                        mov     second,zero
                        mov     cmd,#$42  'GraphicsAddressCmd
                        call    #sendcommand2

                        'mode set or
                        mov     cmd,#%1000_0000
                        call    #sendcommand
                        
                        mov     cmd,#%1001_1000 'graphics on
                        call    #sendcommand

                        mov     first,#byteswide
                        mov     second,#8
                        mov     cmd,#$43
                        call    #sendcommand2

                        
                        'done initializing 
autoloop                call    #printchar     'sets to 8 repeats
                        rdbyte  auto,loopcommandpointer wz 'if command is 1 then wait for a command to write screen
              if_z      jmp     #_skip
              if_nz     rdbyte  auto,loopgopointer wz     'if loopgopointer is zero then don't write
              if_z      jmp     #autoloop
_skip                   call    #bufferwrite
                        wrbyte  zero,loopgopointer 'zero out to signal it is done
                        jmp     #autoloop 'start all over

bufferwrite
                        mov     first,zero
                        mov     second,zero
                        mov     cmd,#$24
                        call    #sendcommand2
                        mov     cmd,#$B0
                        call    #sendcommand
                        call    #waitstatus
                        mov     rep1,loop
                        mov     temp4,par
_looper                 call    #waitstatus3
                        rdbyte  bytebuffer,temp4
                        rev     bytebuffer,#24 'this screen is reverse to others so it is this way
                        add     temp4,#1
                        call    #writedata
                        call    #printchar
                        djnz    rep1,#_looper
                        call    #waitstatus3
                        mov     cmd,#$B2 'end auto command
                        call    #sendcommand
bufferwrite_ret         ret

sendcommand2
              call      #waitstatus
              mov       bytebuffer,first
              call      #writedata
              call      #waitstatus
              mov       bytebuffer,second
              call      #writedata     
              call      #waitstatus
              mov       bytebuffer,cmd
              call      #writecommand  
sendcommand2_ret        ret

sendcommand1
              call      #waitstatus
              mov       bytebuffer,first
              call      #writedata
              call      #waitstatus
              mov       bytebuffer,cmd
              call      #writecommand  
sendcommand1_ret        ret

sendcommand
              call      #waitstatus
              mov       bytebuffer,cmd
              call      #writecommand
sendcommand_ret         ret


                       
writecommand            and     bytebuffer,#$FF
                        or      dira,datapins
                        cmp     reversed,#$FF wz
              if_z      rev     bytebuffer,#24 '   ' for reversed pins activate these lines
                        rol     bytebuffer,DB0   'shift left to output pins
                        or      outa,bytebuffer 'put byte out
                        call    #delay
                        andn    outa,WRS 'pulse pin
                        andn    outa,CE
                        call    #delay
                        or      outa,WRS     'low
                        or      outa,CE
                        call    #delay
                        andn    outa,datapins  'clear datapins
                        'call   #delay          'done wait a little
writecommand_ret ret

writedata               and     bytebuffer,#$FF
                        cmp     reversed,#$FF wz
              if_z      rev     bytebuffer,#24 ' ' for reversed pins activate these lines
                        rol     bytebuffer,DB0   'shift left to output pins
                        or      outa,bytebuffer 'put byte out
                        nop
                        andn    outa,CD
                        andn    outa,WRS
                        andn    outa,CE
                        call    #delay
                        or      outa,WRS     
                        or      outa,CE
                        or      outa,CD
                        call    #delay
                        andn    outa,datapins  'clear datapins
                        'call   #delay          'done wait a little
writedata_ret ret


delay
              mov       temp2,cnt
              add       temp2,tdelay
              waitcnt   temp2,tdelay
delay_ret     ret                        

delayms
              mov       temp2,cnt
              add       temp2,ms
              waitcnt   temp2,ms
delayms_ret   ret

checkstatus
  
               andn     dira,datapins
               or       outa,CD
               or       outa,WRS
               andn     outa,CE
               andn     outa,RD
               call     #delay
               mov      bytetest,ina
               ror      bytetest,DB0
               cmp     reversed,#$FF wz
        if_z   rev      bytetest,#24
               and      bytetest,#$FF 
               or       dira,datapins
               or       outa,CE
               or       outa,RD

checkstatus_ret         ret

waitstatus
              call      #checkstatus
              and       bytetest,#%11
              cmp       bytetest,#%11 wz
              if_z      jmp #waitstatus_ret
              jmp       #waitstatus
waitstatus_ret          ret

waitstatus3
              call      #checkstatus
              and       bytetest,#%1000
              cmp       bytetest,#%1000 wz
              if_z      jmp #waitstatus3_ret
              jmp       #waitstatus3
waitstatus3_ret         ret



'******************* character printing ***********************************************
printchar
        rdword          charposition,charpospointer  '0 to 8 or top to bottom                                             
        rdbyte          character,chartoprintpointer
        rdbyte          colorsize,sizecolorpointer wz
        if_z jmp        printchar_ret   'skip if colorsize is 0
        wrbyte          zero,sizecolorpointer 'set main memory to 0 for next character
        mov             startpos,charposition
        and             startpos,#%111   'drop top 29 bits & leave position
        shr             charposition,#3
        add             charposition,pointer   'set byte address to start character  
        mov             ramaddress,ramstart    'set to start of character ram
        mov             temp1,character
        shr             character,#1 wc    'set c for even or even
        shl             character,#7       'multiply *128 (bytes)
        mov             even,#1
        if_c mov        even,#0   'set even low if even # character                       
        add             ramaddress,character       'set character
        shr             colorsize,#1   wc      'set c flag to color (1 normal, 0 invert)
        if_c mov        invert,#0
        if_nc mov       invert,#1
        subs            colorsize,#4  wz,nr   'set z  if size  big
        mov             rep4,#32
        if_z  call      #size4 
        subs            colorsize,#3  wz,nr   'set z  if size smaller
        if_z  call      #size3
        subs            colorsize,#2  wz,nr   'set z if size smaller
        if_z call       #size2
        subs            colorsize,#1  wz,nr   'set z  if size smallest
        if_z call       #size1
        subs            colorsize,#5  wz,nr
        if_z  mov       rep4,grheight '
        if_z  mov       grep,grwidth
        if_z  mov       ramaddress,displaybase
        if_z  mov       even,#1
        if_z  call      #graphic
printchar_ret   ret        

'***************5 graphics

graphic mov             cbuffer,#0  
        rdlong          lbuffer,ramaddress   'read character memory
        mov             rep5,#16
        shl             lbuffer,even
grrdram shl             cbuffer,#1
        shl             lbuffer,#2              wc  '2 or 4 for size 1 or 2 
        muxc            cbuffer,bit0        'set bit
        djnz            rep5,#grrdram 'repeat 8 or 16
        'xor            cbuffer,allbits 'if inverted graphics view wanted uncomment this line
        wrbyte          cbuffer,charposition    'write byte to main memory
        shr             cbuffer,#8
        add             charposition,#1
        wrbyte          cbuffer,charposition
        add             charposition,spacing 'next row
        add             ramaddress,#4
        djnz            rep4,#graphic    '8, 16, or 32 repeats
        mov             rep4,grheight
        sub             charposition,nextrow
        djnz            grep,#graphic
graphic_ret ret
'***************4
size4   mov             cbuffer,#0  
        rdlong          lbuffer,ramaddress   'read character memory
        mov             rep5,#16
        shl             lbuffer,even
rdram   shl             cbuffer,#1
        shl             lbuffer,#2              wc  '2 or 4 for size 1 or 2 
        muxc            cbuffer,bit0        'set bit
        djnz            rep5,#rdram 'repeat 8 or 16
        sub             invert,#1 wc,nr
        if_c  xor       cbuffer,allbits
        wrbyte          cbuffer,charposition    'write byte to main memory
        shr             cbuffer,#8
        add             charposition,#1
        wrbyte          cbuffer,charposition
        add             charposition,spacing 'next row
        add             ramaddress,#4
        djnz            rep4,#size4    '8, 16, or 32 repeats
size4_ret ret
'***************************3
size3   mov             rep4,#16
        add             ramaddress,#12        
middle3 mov             cbuffer,#0   
        subs            startpos,#4 wz,nr   'set z if odd
        if_z  rdbyte    temp1,charposition
        if_z  and       temp1,leftbits 'clear lefts bits of byte
        if_nz add       charposition,#1
        if_nz rdbyte    temp1,charposition
        if_nz shl       temp1,#8
        if_nz and       temp1,rightbits 'clear right bits or lsb "opposite"
        if_nz sub       charposition,#1
        sub             invert,#1 wc,nr
        rdlong          lbuffer,ramaddress 'read character memory
        mov             rep5,#8
        shr             lbuffer,even
        shr             lbuffer,#2
rdram3  shl             lbuffer,#2              wc  '2 or 4 for size 1 or 2 
        muxc            cbuffer,bit0        'set bit
        shl             cbuffer,#1          'shift left 
        shl             lbuffer,#2              wc  '2 or 4 for size 1 or 2 
        muxc            cbuffer,bit0        'set bit
        shl             cbuffer,#1
        shl             lbuffer,#2
        subs            rep5,#3 wz,nr 'fixes number shape
        if_z  shl       lbuffer,#2
        djnz            rep5,#rdram3 'repeat 8
        shl             cbuffer,even
        sub             invert,#1 wc,nr
        subs            startpos,#4 wz,nr
        if_z shr        cbuffer,#1
        if_nz shr       cbuffer,#5
        if_c_and_nz xor cbuffer,oddbits
        if_c_and_z xor  cbuffer,evenbits   
        add             cbuffer,temp1
        wrbyte          cbuffer,charposition 'write byte to main memory
        shr             cbuffer,#8
        add             charposition,#1
        wrbyte          cbuffer,charposition
        add             charposition,spacing 'next row
        subs            rep4,#10 wz,nr   'shape fix
        if_z  sub       ramaddress,#4
        add             ramaddress,#8
        djnz            rep4,#middle3    '16 repeats
size3_ret ret        
'************************************2*************************************************
size1   mov             rep4,#8
        sub             temp1,#31   
        mov             cbuffer,temp1
        mov             temp1,#0
divide  sub             cbuffer,#7 wc,nr  'set c if under 5
        if_c jmp        #middle1
        sub             cbuffer,#6
        add             temp1,#32 'add 8 for next long set
        if_nc jmp       #divide
middle1 rdbyte          charbfr0,charposition  'read existing for close spacing
        add             charposition,#1
        rdbyte          charbfr1,charposition
        sub             charposition,#1
        shl             charbfr1,#8
        add             charbfr0,charbfr1
        mov             temp3,Sltable
        add             temp3,temp1
        rdlong          lbuffer,temp3
        add             temp1,#4 'next long
        rev             lbuffer,#32 
        rol             lbuffer,#3
        mov             rep5,cbuffer
mult    sub             rep5,#1 wc    'pick number out of long
        if_c  jmp       #write
        ror             lbuffer,#5
        jmp             #mult                           
write   sub             invert,#1 wc,nr
        and             lbuffer,smallbits   'clear all but 5
        shl             lbuffer,#1          'clear space to left
        if_c  xor       lbuffer,#%1111111
        mov             lbyte2,#%1111111
        shl             lbuffer,startpos    'move to position in byte
        shl             lbyte2,startpos     'make mask
        andn            charbfr0,lbyte2       'clear masked bits
        add             lbuffer,charbfr0      'place character in slot
        mov             ebuffer,lbuffer
        wrbyte          ebuffer,charposition 'write byte to main memory
        shr             lbuffer,#8
        add             charposition,#1                                                         
        wrbyte          lbuffer,charposition
        add             charposition,spacing 'next row
        djnz            rep4,#middle1  '8 repeats
size1_ret ret
'*************************************1*************************************************   
size2  mov             rep4,#11      'height
        sub             temp1,#31     'set ahead for letters
        mov             cbuffer,temp1
        mov             temp1,#0
divide2 sub             cbuffer,#5 wc,nr  'set c if under 5
        if_c jmp        #middle2
        sub             cbuffer,#4  '
        add             temp1,#44 'add 4 for next long set
        if_nc jmp       #divide2
middle2 rdbyte          charbfr0,charposition  'read existing for close spacing
        add             charposition,#1
        rdbyte          charbfr1,charposition
        sub             charposition,#1
        shl             charbfr1,#8
        add             charbfr0,charbfr1
        mov             temp3,Bltable
        add             temp3,temp1
        rdlong          lbuffer,temp3
        add             temp1,#4 'next long
        rev             lbuffer,#32 
        rol             lbuffer,#8
        mov             rep5,cbuffer
mult1   sub             rep5,#1 wc    'pick number out of long
        if_c  jmp       #write2
        ror             lbuffer,#8
        jmp             #mult1                          
write2  sub             invert,#1 wc,nr
        and             lbuffer,#%11111111  'clear all but 8
        if_c  xor       lbuffer,#%11111111
        mov             lbyte2, #%11111111
        shl             lbuffer,startpos    'move to position in byte
        shl             lbyte2,startpos     'make mask
        andn            charbfr0,lbyte2       'clear masked bits
        add             lbuffer,charbfr0      'place character in slot
        wrbyte          lbuffer,charposition 'write byte to main memory
        shr             lbuffer,#8
        add             charposition,#1
        wrbyte          lbuffer,charposition
        add             charposition,spacing 'next row
        djnz            rep4,#middle2  '8 repeats
        
size2_ret ret


'***************************************************************************************

'program
tdelay        long      25 'this sets delay for lcd   
ms            long      80_0000  
allbits       long      $FFFF_FFFF
bit0          long      |<0

zero          long      0
leftbits      long      %00000000_00001111     'masks for character placement
rightbits     long      %11110000_00000000     'in half slots
evenbits      long      %11111111_11110000
oddbits       long      %00001111_11111111 
smallbits     long      %00000000_00011111
ladd          long      totalsize+1
ramstart      long      $8000
grheight      long      pixelheight
grwidth       long      byteswide/2
spacing       long      byteswide-1
displaybase   long      $6000
nextrow       long      totalsize-2
loop          long      totalsize

'
'
' Uninitialized data
'
Sltable                 res     1
Bltable                 res     1
charpospointer          res     1
chartoprintpointer      res     1
sizecolorpointer        res     1
loopcommandpointer      res     1
loopgopointer           res     1
dowrite                 res     1
auto                    res     1
temp3                   res     1
temp4                   res     1
cbuffer                 res     1
lbuffer                 res     1
ebuffer                 res     1
pointer                 res     1
memaddress              res     1
charposition            res     1
character               res     1
colorsize               res     1
ramaddress              res     1
countpage               res     1
lbyte2                  res     1
rep1                    res     1
rep2                    res     1
rep3                    res     1
rep4                    res     1
rep5                    res     1
countleft               res     1
bytebuffer              res     1
even                    res     1
invert                  res     1
startpos                res     1
temp1                   res     1
temp2                   res     1
charbfr0                res     1
charbfr1                res     1
cntrst                  res     1
onoff          res     1
grep          res       1
bytetest      res       1
first         res       1
second        res       1
cmd           res       1
pinset        res       1
WRS           res       1
RD            res       1
CE            res       1
CD            res       1
reset         res       1
datapins      res      1
db0           res      1
reversed      res       1
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