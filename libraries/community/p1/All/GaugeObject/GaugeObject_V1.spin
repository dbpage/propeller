


''******************************************
''*  GaugeObject                           *
''*  Author: Gregg Erickson  2011          *
''*  See MIT License for Related Copyright *
''*  See end of file and objects for .     *
''*  related copyrights and terms of use   *
''*                                        *
''*  This used code from and based on:     *
''*  Graphics Demo by Chip Gracey 2005     *
''*  TV Object by Chip Gracey 2004         *
''*  Numbers by Jeff Marten 2005           *
''*  and other Parallax Inc & Forum Demos  *
''******************************************

 {{  The Gauge Object provides a simple gauge face method for use with the Graphics Object by the top object.
 It handles some common overhead issues such as scaling, fitting within the screen, converting readings to
 degrees and uniform handling of colors.  It uses default values but allows customization.  The resulting
 bitmap can be displayed by the TV.SRC or VGA.SRC driver called by the top object.  By using multiple
 copies of the object, many gauges can easily be drawn with minimum effort.
   
 This Object was designed to be used with single or double buffered graphics memory with a minimum of gitter.
 There is plenty of room to refine and optimize the code for a particular application.  
 For more detailed refinements  that optimize each pixel, the programmer can copy/modify the methods and/or
 access the graphics routine directly.  The "Numbers" Object can also be dropped by using predefined
 text instead doing conversions as was done by example for the scale ratio "t" using in ScaleGauge Method.    

 If no other methods in the top object are using graphics then the programmer may chose to add the TV object
 to a version of this object by incorporating related code such as tile definitions and clock speeds into
 this object. It could also be run in automatic mode thus displaying readings independent of other actions if
 the user  modifies it to launch  in another cog with a repeat loop and pointer to the reading variables.  
 For limited term use such as diagnostics, the ability to start and stop cogs would also allow a user to
 determine the need for video (e.g sense the video plug) and only use the resources to run the TV, Graphics
 and Gauge Objects when needed without recompiling or modifying code. 
  
 See GaugeDemo for an Example Use.
 
 }}


OBJ gr    : "graphics"                   ' Create Graphics for Display
    NuCon : "Numbers"                   ' Create string bytes for display

CON
  
 '-----Gauge Default Value Constants -------
 
  maxX=255        ' TV Object Width in Pixels
  maxY=192         'TV Object Height in Pixels
       

VAR


  '-------- Gauge Variables --------------


  Long  Needlereading,Oldreading,SaveReading ' Reading to be Displayed
  Long  NumberPostSave
  Long  GaugeX,GaugeY,GaugeR                 ' Position and Size in Pixels
  Long  LowestReading                        ' Lowest Reading on Gauge
  Long  MaxReading                           ' Highest Reading on Gauge
  Long  TimesX                               ' Multiplier for Gauge


  long  Direction        ' Factor for Angle Calculation
  Long  Zero             ' Orientation of Rotation Origin as per a Clock Face
  Long  Clockwise        ' Clockwise Rotation:=true based upon Rotation
  Long  RotationOffset   ' Offset in Degrees based upon Rotation Origin & Direction

  Long  BeginT,EndT      ' Angle of First and Last Dial Tick from Rotations Origin
  Long  MajorT,MinorT    ' Angle Between Major and Minor Ticks
  Long  BeginB,EndB      ' Angle of Start and End of Band under Ticks
  Long  Scale            ' Ratio of Tick Numbers to Reading
  Long  NeedleOffset     ' Offset due to non-zero begining tick

  Long  GaugeF           ' Color of the Face 
  Long  StartA,EndA      ' Angle of Start and End of Dial Face Arc from Rotation Origin
 
  Long  GaugeC           ' Color of Inner Bezel
  Long  GaugeS           ' Color of Outer Bezel
  Long  GaugeB           ' Thickness of Bezel Lines
  Long  BezelOffset      ' Offset between Inner and Outer Bezel
   
  Long  GaugeQ           ' Background Color of Needle
  Long  GaugeN           ' Color of the Needle
  Long  GaugeW           ' Thickness of the Needle
  Long  GaugeP           ' Color of the NeedlePin    
  Long  GaugeZ           ' Colot of Scale Text
  Long  GaugeD           ' Color of band behind Ticks
  Long  GaugeJ           ' Color of Scale Times X text

PUB start(GX,GY,GZ,Display_base)  '--- Initialize Gauge Object
     ' Pixels, Pixels, Pixels,Memory Address
     ' Set the X and Y Location where 0 is the center of the screen
gr.start                                    'Start Graphic object
gr.setup(16, 12, 128, 96, display_base)     'Setup Graphics and point to video memory used

'-------- Store Initial Values from Start  -------------------------
GaugeX:=GX   ' X Location in Pixels
GaugeY:=GY   ' Y Location in Pixels
GaugeR:=GZ   ' Radius in Pixels
'------- Set Default Values, These Can Be Changed Via Methods ---------
Zero:=6                   ' Use 6 O'Clock Position as the Origin
clockwise:=true           ' Make Rotation Clockwise
BeginT:=45                ' Start Ticks at 45 Degrees Clockwise from Origin
EndT:=315                 ' End Ticks at 45 Degrees Before Orgin, Mirrored Image
StartA:=45                ' Match Face Shading to Range of Ticks Starting at 45 Degrees After Origin
EndA:=315                 ' Match Face Shading to Range of Ticks Ending at 45 Degrees Before Origin 
MajorT:=30                ' Place Major (Longer) Ticks Every 30 Degrees
MinorT:=10                ' Place Minor (Shorter) Ticks Every 10 Degrees
BeginB:=215               ' Place Band in Upper Range
EndB:=275                 '


'------ Set Default Color & Thickness Values Based Upon Palette Defined in Video Memory Block -----
'                          These Can Be Changed Via Methods. 
'                   Normal Usage is 3=text,2=dial,1=needle,0=background   

GaugeC:=2                 ' Set Inner Bezel to Typical Dial Color
GaugeS:=1                 ' Set Out Bezel to 1 for Colot Contrast
GaugeB:=0                 ' Keep Bezel Thin
BezelOffset:=1            ' Place Inner Bezel 1 Pixel from the Outer
GaugeF:=3                 ' Set Faceplate Color to Typical
GaugeD:=3                 ' Set color of band behind ticks
GaugeP:=1                 ' Set the NeedlePin Color to Typical Needle Color
GaugeN:=1                 ' Set Color of the Needle to Typical Needle
GaugeQ:=GaugeF            ' Set the Needle Background Color to Faceplate Color to Hide Movement.
GaugeW:=2                 ' Set Needlewidth to double thickness
GaugeZ:=1                 ' Set color of scale text
GaugeJ:=1                 ' Set Colot of Times X Text


'------ Set Default for Readings -----------------

SaveReading:=0            ' Assume First Reading is Zero

'==========  Parameter Methods ========================================


Pub Size(x,y,r) '-----  Set the Location and Radius of the Gauge -------------
                 'Format = Pixels, Pixels, Pixels, See Desc in Start
 GaugeX:=X
 GaugeY:=y
 GaugeR:=r
 GaugeAdjust
  
Pub Offsets(Origin,Rotation,First,Last,Major,Minor) '---- Orient and Scale Markings -----------
            'Format = Clock Face 3/6/9/12, True/False, Degrees, Degrees, Degrees, Degrees
            'See Variables Section for Description

     Zero:=Origin
     clockwise:=Rotation
     BeginT:=First
     EndT:=Last
     StartA:=BeginT
     EndA:=EndT
     MajorT:=Major
     MinorT:=Minor

     GaugeAdjust
 
Pub GaugeAdjust  '----- Adjust Gauge Size to Fit and Calculate Rotation Offsets ----------

    gaugeR:=gaugeR<#MaxY/2
    gaugeX:=-1*((maxX/2)-(GaugeR))#>(GaugeX)<#((MaxX/2)-(GaugeR))
    gaugeY:=-1*((maxY/2)-(GaugeR))#>(GaugeY)<#((MaxY/2)-(GaugeR)-1)

    direction:=1
    If clockwise==true
       direction:=-1
  
    Case Zero
          12:RotationOffset:=(90*direction)
          3: RotationOffset:=0
          6: RotationOffset:=(-90*direction)
          9: RotationOffset:=(180*direction)

Pub Colors(C1,S1,P1,B1,O1,F1,W1,N1,Q1,D1,J1)  ' --------- Set Colors, -------------
            ' Format = Integers, Colors 0-3, Needle Width can vary from 0 to 12
            ' See Variables Section for Description

GaugeC:=C1
GaugeS:=S1
GaugeP:=P1
GaugeB:=B1
BezelOffset:=O1
GaugeF:=F1
GaugeW:=W1
GaugeN:=N1
GaugeQ:=Q1
GaugeD:=D1
GaugeJ:=J1
 
Pub GaugeScale(base,Increment,multiplier)|z,w,t ,format '---Plot Scale Numbers at Every Other Major ticks
               ' Format = Integer, Integer, 1/10/100/1000
               ' See Variables Section for Description
    scale:=1000*multiplier*Increment/(MajorT*2)  ' Define a Factor to Convert Reading to Degrees
    TimesX:=multiplier
    w:=base
    LowestReading:=base

    NeedleOffset:=multiplier*1000*LowestReading/scale
    gr.colorwidth(1,0)
    gr.textmode(GaugeR/40,GaugeR/30,6,%0101) 

    repeat z from (BeginT+RotationOffset) to (EndT+RotationOffset) step majorT*2   ' Post Numbers

     If w>999
        format:=%101_01010
     elseif w>99
        format:=%100_01010
     elseif w>9
        format:=%011_01010
     else
        format:=%010_01010

     gr.textarc(GaugeX,GaugeY,9*GaugeR/12, 9*GaugeR/12, direction*Z*23, Nucon.ToStr(w,format))
     gr.finish
     maxreading:=w
     w:=w+increment

Pub GaugeTimes|t
    gr.textmode(1,1,6,%0101)
    gr.colorwidth(Gaugej,0)


    case TimesX                    ' Select Appropriate Scalar Text

     1:    t:=@A1x
     10:   t:=@A10x
     100:  t:=@A100x
     1000: t:=@A1000x
     10000:t:=@A10000x
 
'    gr.text(GaugeX,GaugeY-(GaugeR/3),T) ' Note the Scale on the Face
    gr.textarc(GaugeX,GaugeY,2*GaugeR/3,2*GaugeR/3, direction*RotationOffset*23, T)

'============= Display Only Methods ===========================

Pub GaugeTicks|i  '--- Plot Major and Minor Ticks -----

    gr.arc(GaugeX,GaugeY,GaugeR,GaugeR,direction*23*(BeginT+RotationOffset),23,1,0)      'Draw First Tick
    gr.arc(GaugeX,GaugeY,GaugeR-(GaugeR/6),GaugeR-(GaugeR/6),direction*23*(BeginT+RotationOffset),23,1,1)

    gr.arc(GaugeX,GaugeY,GaugeR,GaugeR,direction*23*(EndT+RotationOffset),23,1,0)      'Draw Last Tick
    gr.arc(GaugeX,GaugeY,GaugeR-(GaugeR/6),GaugeR-(GaugeR/6),direction*23*(EndT+RotationOffset),23,1,1)

    repeat i from (BeginT+RotationOffset) to (EndT+RotationOffset) step MinorT
       gr.arc(GaugeX,GaugeY,GaugeR,GaugeR,direction*23*i,23,1,0)                   'Draw Minor Ticks
       gr.arc(GaugeX,GaugeY,GaugeR-(GaugeR/12),GaugeR-(GaugeR/12),direction*23*i,23,1,1)

    repeat i from (BeginT+RotationOffset) to (EndT+RotationOffset) step MajorT
       gr.arc(GaugeX,GaugeY,GaugeR,GaugeR,direction*23*i,23,1,0)                   'Draw Major Ticks
       gr.arc(GaugeX,GaugeY,GaugeR-(GaugeR/6),GaugeR-(GaugeR/6),direction*23*i,23,1,1)

Pub GaugePin     '---- Plots a Pivot Pin for the Needle ------------------------
                         ' Note: this feature slows the redrawing

       gr.colorwidth(GaugeP,1)      'Thick pivot pin like real gauge
       gr.arc(GaugeX,GaugeY,GaugeR/16,GaugeR/16,0,23,360,3)

Pub GaugeFace     '-------- Fill in Arc on Face of Gauge

      EndA:=EndA-StartA

      gr.colorwidth(GaugeF,1)
      gr.arc(GaugeX,GaugeY,GaugeR-(GaugeR/6)-3,GaugeR-(GaugeR/6)-1,23*(StartA+RotationOffset)*direction,direction*23,EndA,3)

Pub SetTickBand(B,E)

  BeginB:=B
  EndB:=E

Pub TickBand|i

    gr.colorwidth(GaugeF,1)

    repeat i from (BeginB+RotationOffset) to (EndB+RotationOffset)
       gr.arc(GaugeX,GaugeY,GaugeR,GaugeR,direction*23*i,23,1,0)                   'Draw Major Ticks
       gr.arc(GaugeX,GaugeY,GaugeR-(GaugeR/6),GaugeR-(GaugeR/6),direction*23*i,23,1,1)


Pub FullFace         '----- Draws 360 Degree Circle on Gauge Face
      gr.colorwidth(GaugeF,1)
      gr.arc(GaugeX,GaugeY,GaugeR-(GaugeR/6)-3,GaugeR-(GaugeR/6)-1,23*(StartA+RotationOffset)*direction,direction*23,360,3)

Pub GaugeBezel      ' ------- Draw Bezel Rings ----------
    '(note: 1 degree is about 23 ticks for angle calculation ) ----------

    gr.width(GaugeB)
    '---draw dial---
    gr.color(GaugeS)
    gr.arc(GaugeX,GaugeY,GaugeR,GaugeR,0,23,360,0)
    gr.color(GaugeC)
    gr.arc(GaugeX,GaugeY,GaugeR-BezelOffset,GaugeR-BezelOffset,0,23,360,0)           'Draw Starboard Dial

 '====== Output Methods ==========================

Pub SmartNumber(Reading)| Tcolor


    TColor:=GaugeZ
    GaugeZ:=GaugeQ
    PostNumber(NumberPostSave)
    GaugeZ:=TColor
    PostNumber(Reading)
    NumberPostSave:=Reading

Pub PostNumber(Reading) | format ' -------- Post the Reading as a Number on the Face --------------
          ' Format = Integer
 '   Reading:=lowestreading#>Reading

{    gr.color(GaugeF)
    gr.box(GaugeX-(GaugeR/3),GaugeY+(GaugeR/7),5*GaugeR/6,GaugeR/3)
    gr.finish
}
    gr.colorwidth(GaugeZ,0)
 
    gr.textmode(GaugeR/40,GaugeR/30,6,%0101)
  
    if Reading>999
        format:=%101_01010
    elseif Reading>99
        format:=%100_01010
    elseif Reading>9
        format:=%011_01010
    else
        format:=%010_01010
  
    gr.text(GaugeX-(GaugeR/12),GaugeY+(GaugeR/4),Nucon.ToStr(Reading,format))
    gr.finish
 
Pub SmartNeedle(NReading)| TempColor ' --- Calls Method to Redraw over Old Needle (Cleaner in Single Buffer) and Draw New Needle
                ' Format = Integer

     TempColor:=GaugeN
     GaugeN:=GaugeQ
     SingleNeedle(TimesX*Lowestreading#>SaveReading<#Maxreading*TimesX)
     GaugeN:=TempColor
     NReading:=TimesX*lowestreading#>NReading<#Maxreading*TimesX
     SingleNeedle(NReading)
     SaveReading:=NReading
   
Pub SingleNeedle(SReading) '-- Draw Needle ---
                 ' Format = Integer
    gr.colorwidth(GaugeN,GaugeW)
    gr.arc(GaugeX,GaugeY,GaugeR-(GaugeR/6)-2,GaugeR-(GaugeR/6)-2,direction*23*((1000*(SReading)/scale)+RotationOffset+beginT-needleoffset),23,1,3)
    gr.finish
  
DAT

XText                   byte    "x",0
A1X                      byte    "1x",0
A10X                     byte    "10x",0
A100X                    byte    "100x",0
A1000X                   byte    "1000x",0
A10000X                  byte    "10000x",0

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
