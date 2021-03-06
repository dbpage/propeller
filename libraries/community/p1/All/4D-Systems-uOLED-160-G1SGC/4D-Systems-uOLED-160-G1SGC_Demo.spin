{{
File.......... 4D-Systems-uOLED-160-G1SGC_Demo.spin
Purpose....... Demo code for the 4D Systems uOLED-160-G1SGC display.
Attribution... Most of this code was adapted from the µOLED-160-GMD1 Demo object written
               by Steve McManus.
Author........ Jim Edwards
E-mail........ jim.edwards4@comcast.net
History....... v1.0 - Initial release
Copyright..... Copyright (c) 2011 Jim Edwards
Terms......... See end of file for terms of use.

Information:

This program demonstrates the capabilities of the 4D Systems uOLED-160-G1SGC display
module. The G1SGC models from 4D Systems utilize a custom-built embedded graphics
processor (GOLDELOX-SGC) to provide a simple serial interface to the OLED display module.
A downloadable PmmC (Personality module micro-Code) provides custom firmware for each
display module where the GOLDELOX-SGC is used. This demo exercises most of the available
commands for the display device. If you do not have an SD card inserted, set the constant
DemoSD to FALSE. If you are not using a carrier board that provides support for a
joystick/button or a speaker, set the constants DemoJoystick and DemoSound to FALSE,
respectively. The DisplaySetup and DisplayShutdown methods are required for proper
operation. The other calls in the DisplayDemo method may be commented out or arranged to suit
}}

OBJ

  Delay         : "Clock"
  Fmt           : "Format"  
  Oled          : "4D-Systems-uOLED-160-G1SGC"

CON

  ' General constants
  
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000
  DemoJoystick  = TRUE   ' Set false if hardware doesn't have joystick/button
  DemoSound     = TRUE   ' Set false if hardware doesn't have speaker
  DemoSD        = TRUE   ' Set false if hardware doesn't have SD card

VAR

  long SAddr
  byte uSD_Sector[512]
  byte strbuf[64]          ' Buffer for assembling formatted strings

PUB DisplayDemo

  DisplaySetup(TRUE)
  if (DemoSD)
    DemoClearSectors
  
  repeat
    DemoDeviceInfo
    if (DemoJoystick)
      DemoJoystickInput
    if (DemoSound)
      DemoSoundOutput
    DemoTextSize
    DemoBigText
    DemoStopSign
    DemoWireFrame
    DemoSolid
    DemoStringArt
    DemoWalker
    DemoPutPixel
    DemoTextButtons
    DemoFastScroll
    DemoWitch
    if (DemoSD)
      DemoWitchToSD
    DemoStripChart
    if (DemoSD)
      DemoStripChartToSD
    DemoMonitor
    if (DemoSD) 
      DemoMonitorToSD
      DemoMonitorFromSD
      DemoStripChartFromSD
      DemoWitchFromSD
      DemoPartScreensFromSD
      DemoFastImagesFromSD
    DemoContrast
    DemoShutdown
  
PRI DisplaySetup(init_enable)

  if (init_enable)
    Oled.DisplayInitialize
  Oled.DisplaySetErrorCheckingOff
  Oled.DisplayClearScreen
  Oled.DisplayReplaceBackgndColor(0, 0, 0) 
  Oled.DisplaySetContrast(12)
  Oled.TextSetOpaque
 
PRI DemoDeviceInfo | dev_type, hw_rev, fw_rev, hor_res, vert_res, index
    
  Oled.TextDrawStrFixed(0, 0, Oled#TextFontSet5x7, 255, 255, 255, string("Device Info:")) 
  Oled.DisplayGetDeviceInfo(Oled#DisplayInfoOutputSerial, @dev_type, @hw_rev, @fw_rev, @hor_res, @vert_res)

  index := Fmt.bprintf(@strbuf, 0, string("dev_type = [%x hex] "), dev_type.byte[0])  
  case dev_type.byte[0]
    Oled#DisplayInfoDeviceTypeuOLED:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("uOLED")) 
    Oled#DisplayInfoDeviceTypeuLCD:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("uLCD"))  
    Oled#DisplayInfoDeviceTypeuVGA:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("uVGA")) 
    other:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("unknown"))
  strbuf[index] := 0
  Oled.TextDrawStrFixed(0, 2, Oled#TextFontSet5x7, 0, 255, 0, @strbuf)

  Fmt.sprintf(@strbuf, string("hw_rev = %d"), hw_rev.byte[0])
  Oled.TextDrawStrFixed(0, 3, Oled#TextFontSet5x7, 0, 255, 0, @strbuf)
   
  Fmt.sprintf(@strbuf, string("fw_rev = %d"), fw_rev.byte[0])
  Oled.TextDrawStrFixed(0, 4, Oled#TextFontSet5x7, 0, 255, 0, @strbuf) 

  index := Fmt.bprintf(@strbuf, 0, string("hor_res = [%x] "), hor_res.byte[0])  
  case hor_res.byte[0]
    Oled#DisplayInfoResolution220Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("220 pixels"))
    Oled#DisplayInfoResolution128Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("128 pixels")) 
    Oled#DisplayInfoResolution320Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("320 pixels")) 
    Oled#DisplayInfoResolution160Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("160 pixels"))   
    Oled#DisplayInfoResolution64Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("64 pixels")) 
    Oled#DisplayInfoResolution176Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("176 pixels")) 
    Oled#DisplayInfoResolution96Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("96 pixels")) 
    other:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("unknown"))
  strbuf[index] := 0
  Oled.TextDrawStrFixed(0, 5, Oled#TextFontSet5x7, 0, 255, 0, @strbuf)
  
  index := Fmt.bprintf(@strbuf, 0, string("vert_res = [%x] "), vert_res.byte[0])  
  case vert_res.byte[0]
    Oled#DisplayInfoResolution220Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("220 pixels"))
    Oled#DisplayInfoResolution128Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("128 pixels")) 
    Oled#DisplayInfoResolution320Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("320 pixels")) 
    Oled#DisplayInfoResolution160Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("160 pixels"))   
    Oled#DisplayInfoResolution64Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("64 pixels")) 
    Oled#DisplayInfoResolution176Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("176 pixels")) 
    Oled#DisplayInfoResolution96Pixels:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("96 pixels")) 
    other:
      index := Fmt.bprintf(@strbuf, index, string("%s"), string("unknown"))
  strbuf[index] := 0
  Oled.TextDrawStrFixed(0, 6, Oled#TextFontSet5x7, 0, 255, 0, @strbuf)
  Delay.PauseSec(5)
  DisplaySetup(FALSE)
  
PRI DemoJoystickInput | idle_start, status

  Oled.TextDrawStrFixed(0, 0, Oled#TextFontSet5x7, 255, 255, 255, string("Joystick Demo"))  
  Oled.TextDrawStrFixed(0, 2, Oled#TextFontSet5x7, 0, 255, 0, string("Press any joystick"))
  Oled.TextDrawStrFixed(0, 3, Oled#TextFontSet5x7, 0, 255, 0, string("position to test"))  
  Oled.TextDrawStrFixed(0, 4, Oled#TextFontSet5x7, 0, 255, 0, string("Exits if idle >= 5 Secs"))
  Delay.PauseSec(1)
  idle_start := cnt

  repeat
    status := Oled.JoystickGetStatus(Oled#JoystickOptionReturnStatus)
    case status
      Oled#JoystickStatusNoPress:
        Fmt.sprintf(@strbuf, string("%s"), string("Joystick = No press    "))
      Oled#JoystickStatusUpPress:
        Fmt.sprintf(@strbuf, string("%s"), string("Joystick = Up press    "))
      Oled#JoystickStatusLeftPress:                                
        Fmt.sprintf(@strbuf, string("%s"), string("Joystick = Left press  "))
      Oled#JoystickStatusDownPress:
        Fmt.sprintf(@strbuf, string("%s"), string("Joystick = Down press  "))
      Oled#JoystickStatusRightPress:                                 
        Fmt.sprintf(@strbuf, string("%s"), string("Joystick = Right press "))
      Oled#JoystickStatusFirePress:
        Fmt.sprintf(@strbuf, string("%s"), string("Joystick = Fire press  "))
        
    Oled.TextDrawStrFixed(0, 8, Oled#TextFontSet5x7, 0, 255, 0, @strbuf) 
    if (status <> Oled#JoystickStatusNoPress)
      idle_start := cnt
    Fmt.sprintf(@strbuf, string("Idle time = %d Secs"), (cnt - idle_start) / clkfreq)
    Oled.TextDrawStrFixed(0, 7, Oled#TextFontSet5x7, 0, 255, 0, @strbuf)
    if ((cnt - idle_start) => (5* clkfreq))
      DisplaySetup(FALSE)
      return

PRI DemoSoundOutput | octave

  Oled.TextDrawStrFixed(0, 0, Oled#TextFontSet5x7, 255, 255, 255, string("Sound Demo")) 
  Repeat octave from 1 to 84
    Oled.SoundPlayNoteOrFrequency(octave, 50)
  Delay.PauseSec(1)
  DisplaySetup(FALSE)
            
PRI DemoTextSize

  Oled.TextDrawStrFixed(0, 1, Oled#TextFontSet8x12, 255, 255, 255, string("Font 0: 5x7"))
  Oled.TextDrawStrFixed(0, 4, Oled#TextFontSet5x7, 255, 255, 0, string(" ! @ # $ % ^ & * ( ) _ + - = 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z { } [ ] | \ ; : ' < > ? , . /"))
  Delay.PauseSec(5)
  Oled.DisplayClearScreen
   
  Oled.TextDrawStrFixed(0, 1, Oled#TextFontSet8x12, 255, 255, 255, string("Font 1: 8x8"))
  Oled.TextDrawStrFixed(0, 4, Oled#TextFontSet8x8, 0, 255, 255, string(" ! @ # $ % ^ & * ( ) _ + - = 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z { } [ ] | \ ; : ' < > ? , . /"))
  Delay.PauseSec(5)
  Oled.DisplayClearScreen
   
  Oled.TextDrawStrFixed(0, 1, Oled#TextFontSet8x12, 255, 255, 255, string("Font 2: 8x12"))
  Oled.TextDrawStrFixed(0, 3, Oled#TextFontSet8x12, 255, 255, 255, string(" ! @ # $ % ^ & * ( ) _ + - = 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z { } [ ] | \ ; : ' < > ? , . /"))
  Delay.PauseSec(5)                                          
  Oled.DisplayClearScreen
   
  Oled.TextDrawStrFixed(0, 1, Oled#TextFontSet5x7, 200, 200, 200, string("This is just a lot of text to demonstrate text wrap on the screen"))
  Delay.PauseSec(3)
  Oled.TextDrawStrFixed(0, 6, Oled#TextFontSet8x8, 200, 200, 0, string("You can go small as above, or you can go"))
  Delay.PauseSec(2)
  Oled.TextDrawStrScaled(30, 90, Oled#TextFontSet8x12, 255, 255, 0, 3, 3, string("BIG"))
  Delay.PauseSec(3)
  DisplaySetup(FALSE)

PRI DemoBigText | temp

  repeat temp from 1 to 3
    Oled.TextDrawCharScaled("T", 4, 4, Oled#TextFontSet8x8, 200, 200, 0, 14, 14)
    Delay.PauseMSec(200)
    Oled.TextDrawCharScaled("E", 4, 4, Oled#TextFontSet8x8, 200, 200, 0, 14, 14)
    Delay.PauseMSec(200)
    Oled.TextDrawCharScaled("S", 4, 4, Oled#TextFontSet8x8, 200, 200, 0, 14, 14)
    Delay.PauseMSec(200)
    Oled.TextDrawCharScaled("T", 4, 4, Oled#TextFontSet8x8, 200, 200, 0, 14, 14)
    Delay.PauseMSec(200)
    Oled.DisplayClearScreen
    Delay.PauseSec(1)
    Oled.TextDrawStrScaled(30, 5, Oled#TextFontSet8x8, 200, 200, 200, 2, 2, string("Temp"))
    
    case temp
      1:
        Oled.TextDrawStrScaled(5, 45, Oled#TextFontSet8x12, 0, 255, 0, 3, 3, string("125 C"))
      2:
        Oled.TextDrawStrScaled(5, 45, Oled#TextFontSet8x12, 200, 255 ,0, 3, 3, string("248 C"))
      3:
        Oled.TextDrawStrScaled(5, 45, Oled#TextFontSet8x12, 255, 0, 0, 3, 3, string("327 C"))
    Delay.PauseSec(2)
    Oled.DisplayClearScreen
    
  Oled.TextDrawCharScaled("S", 4, 4, Oled#TextFontSet8x8, 120, 0, 0, 14, 14)
  Delay.PauseMSec(200)
  Oled.TextDrawCharScaled("T", 4, 4, Oled#TextFontSet8x8, 120, 0, 0, 14, 14)
  Delay.PauseMSec(200)
  Oled.TextDrawCharScaled("O", 4, 4, Oled#TextFontSet8x8, 120, 0, 0, 14, 14)
  Delay.PauseMSec(200)
  Oled.TextDrawCharScaled("P", 4, 4, Oled#TextFontSet8x8, 120, 0, 0, 14, 14)
  Delay.PauseMSec(200)
  Oled.DisplayClearScreen
  Delay.PauseSec(1)
  DisplaySetup(FALSE)
        
PRI DemoStopSign

  Oled.GraphicsDrawPolygon6(35, 10, 0, 62, 35, 116, 85, 116, 116, 62, 85, 10, 155, 0, 0)
  Oled.TextSetTransparent
  Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 120, 0, 0, 3, 4, string("STOP"))

  Oled.GraphicsSetPenModeSolid
  Oled.GraphicsDrawCircle(60, 108, 4, 200, 0, 0)
  Oled.GraphicsDrawRectangle(58, 78, 62, 108, 200, 0, 0)
  Oled.GraphicsDrawRectangle(59, 75, 61, 94, 0, 0, 0)
  Oled.GraphicsDrawCircle(60, 78, 2, 200, 0, 0)

  Oled.GraphicsDrawLine(60, 98, 50, 103, 200, 0, 0)
  Oled.GraphicsDrawLine(60, 98, 70, 103, 200, 0, 0)
   
  Oled.GraphicsDrawLine(50, 103, 40, 98, 200, 0, 0)
  Oled.GraphicsDrawLine(70, 103, 80, 98, 200, 0, 0)
   
  Oled.GraphicsDrawLine(40, 98, 35, 103, 200, 0, 0)
  Oled.GraphicsDrawLine(80, 98, 85, 103, 200, 0, 0)
  Delay.PauseMSec(500)
   
  repeat 3
    Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 0, 0, 0, 3, 4, string("STOP"))
    Delay.PauseMSec(200)
    Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 120, 0, 0, 3, 4, string("STOP"))
    Delay.PauseMSec(500)
  
  Delay.PauseSec(1)
  Oled.DisplayScrollControl(Oled#DisplayScrollLeft, 5)
  Oled.DisplayScrollEnable
  
  repeat 4
    Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 0, 0, 0, 3, 4, string("STOP"))
    Delay.PauseMSec(500)
    Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 120, 0, 0, 3, 4, string("STOP"))
    Delay.PauseMSec(500)
    
  Oled.DisplayScrollControl(Oled#DisplayScrollRight, 5)
  Oled.DisplayScrollEnable
  
  repeat 4
    Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 0, 0, 0, 3, 4, string("STOP"))
    Delay.PauseMSec(500)
    Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 120, 0, 0, 3, 4, string("STOP"))
    Delay.PauseMSec(500)
    
  Oled.DisplayScrollControl(Oled#DisplayScrollLeft, 5)
  Oled.DisplayScrollEnable
  
  repeat 4
    Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 0, 0, 0, 3, 4, string("STOP"))
    Delay.PauseMSec(500)
    Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 120, 0, 0, 3, 4, string("STOP"))
    Delay.PauseMSec(500)

  Oled.DisplayScrollControl(Oled#DisplayScrollRight, 5)
  Oled.DisplayScrollEnable
  
  repeat 4
    Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 0, 0, 0, 3, 4, string("STOP"))
    Delay.PauseMSec(500)
    Oled.TextDrawStrScaled(12, 48, Oled#TextFontSet8x8, 120, 0, 0, 3, 4, string("STOP"))
    Delay.PauseMSec(500)
     
  Oled.DisplayScrollControl(Oled#DisplayScrollLeft, 0)
  Oled.DisplayScrollDisable
  Delay.PauseSec(3)
  DisplaySetup(FALSE)
    
PRI DemoWireFrame

  Oled.TextDrawStrFixed(1, 0, Oled#TextFontSet8x8, 255, 255, 255, string("Wire Frame (Pen 1)"))
  Oled.GraphicsSetPenModeWireFrame 
  Oled.GraphicsDrawTriangle(40, 20, 20, 100, 110, 80, 0, 255, 0)
  Delay.PauseSec(2)
  Oled.GraphicsDrawCircle(60, 50, 20, 255, 0, 0)
  Delay.PauseSec(2)
  Oled.GraphicsDrawRectangle(80, 20, 120, 120, 255, 255, 0)
  Delay.PauseSec(2)
  Oled.GraphicsDrawPolygon6(70, 20, 20, 60, 40, 75, 20, 120, 110, 100, 70, 60, 0, 0, 255)
  Delay.PauseSec(3)
  DisplaySetup(FALSE)
    
PRI DemoSolid

  Oled.GraphicsSetPenModeSolid
  Oled.TextDrawStrFixed(3, 0, Oled#TextFontSet8x8, 255, 255, 255, string("Solid (Pen 0)"))
  Oled.GraphicsDrawTriangle(40, 20, 20, 100, 110, 80, 0, 255, 0)
  Delay.PauseSec(2)
  Oled.GraphicsDrawCircle(60, 50, 20, 255, 0, 0)
  Delay.PauseSec(2)
  Oled.GraphicsDrawRectangle(80, 20, 120, 120, 255, 255, 0)
  Delay.PauseSec(3)
  DisplaySetup(FALSE)

PRI DemoStringArt | p1, p2, p3, p4, p5, p6

  Oled.GraphicsDrawPixel(63, 63, 0, 255, 0)
  Delay.PauseSec(2)
  
  p1 := 62
  p3 := 64
  repeat 40
    Oled.GraphicsDrawLine(p1--, 63, p3++, 63, 0, 255, 0)
    Delay.PauseMSec(30)

  Delay.PauseMSec(700)

  p4 := 63
  repeat 35
    Oled.GraphicsDrawLine(63, 63, p3, p4++, 0, 0, 0)
    Oled.GraphicsDrawLine(63, 63, p3, p4, 0, 255, 0)
    Delay.PauseMSec(30)

  Delay.PauseMSec(700)

  p2 := 63
  repeat 25
    Oled.GraphicsDrawLine(63, 63, p1, p2++, 0, 0, 0)
    Oled.GraphicsDrawLine(63, 63, p1, p2, 0, 255, 0)
    Delay.PauseMSec(30)

  Delay.PauseMSec(700)
  
  p5 := p3 -1
  repeat until p5 == p1
    Oled.GraphicsDrawLine(p5--, p4, p3, p4, 0, 255, 0)
    Delay.PauseMSec(30)

  Delay.PauseMSec(700)
  
  p6 := p4
  repeat until p6 == p2
    Oled.GraphicsDrawLine(p3, p4, p5, p6--, 0, 0, 0)
    Oled.GraphicsDrawLine(p3, p4, p5, p6, 0, 255, 0)
    Delay.PauseMSec(40)

  Delay.PauseMSec(700)
    
  Oled.GraphicsSetPenModeWireFrame
  p1 := 63
  p2 := 63
  repeat until p6 == 63
    Oled.GraphicsDrawPolygon3(p1++, p2, p5, p6--, p3--,p4, 0, 0, 0)
    Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 0, 255, 0)
    Delay.PauseMSec(30)

  Delay.PauseMSec(700)
  
  repeat 5
    Oled.GraphicsDrawPolygon3(p1, p2--, p5,  p6, p3, p4, 0, 0, 0)
    Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 0, 255, 0)
    Delay.PauseMSec(30)       

  Delay.PauseMSec(700)

  repeat 3
     
    repeat 10
      Oled.GraphicsDrawPolygon3(p1, p2, p5, p6--, p3, p4, 0, 0, 0)
      Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 0, 255, 0)
      Delay.PauseMSec(30)
     
    Delay.PauseMSec(700)
     
    repeat 10
      Oled.GraphicsDrawPolygon3(p1, p2--, p5, p6, p3, p4, 0, 0, 0)
      Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 0, 255, 0)
      Delay.PauseMSec(30)       
     
    Delay.PauseMSec(700)

  repeat 5
      Oled.GraphicsDrawPolygon3(p1, p2, p5, p6--, p3,p4, 0, 0, 0)
      Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 0, 255, 0)
      Delay.PauseMSec(30)
     
  Delay.PauseSec(2)
  Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 255, 0, 0)
  Oled.TextDrawStrFixed(3, 0, Oled#TextFontSet8x12, 255, 0, 0, string("Catch"))
  Delay.PauseMSec(500)
  Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 255, 0, 0)
  Oled.TextDrawStrFixed(9, 0, Oled#TextFontSet8x12, 255, 0, 0, string("UP!"))
  Delay.PauseMSec(300)
  Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 0, 255, 0)
  Delay.PauseSec(2)

  repeat 20
    Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4--, 0, 0, 0)
    Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 0, 255, 0)
    Delay.PauseMSec(20)

  repeat 9
    Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3--,p4--, 0, 0, 0)
    Oled.GraphicsDrawPolygon3(p1, p2, p5, p6, p3, p4, 0, 255, 0)
    Delay.PauseMSec(20)

  Delay.PauseMSec(200)
  Oled.TextDrawStrFixed(3, 0, Oled#TextFontSet8x12, 255, 0, 0, string("          "))
  Delay.PauseSec(4)
  DisplaySetup(FALSE)

PRI DemoWalker | temp, p1, p2, p3, p4, p5 ,p6, p7, p8, p9, p10, p11, p12
  
  p1 := 0
  p2 := 50

  p3 := 0
  p4 := 90

  p5 := 20
  p6 := 90

  p7 := 70
  p8 := 90

  p9 := 90
  p10 := 90

  p11 := 90
  p12 := 50

  Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, 100, 100, 0)
  Delay.PauseSec(3)

  repeat 35
    Oled.GraphicsDrawPolygon6(p1, p2--, p3, p4, p5, p6--, p7, p8--, p9, p10, p11 ,p12--, 0, 0, 0)
    Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, 100, 100, 0)
    Delay.PauseMSec(40)

  Delay.PauseSec(1)  

  repeat 11

    repeat 15
      Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10--, p11, p12, 0, 0, 0)
      Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, 100, 100, 0)
      Delay.PauseMSec(5)
     
    repeat 15
      Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7, p8, p9++, p10, p11, p12, 0, 0, 0)
      Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, 100, 100, 0)
      Delay.PauseMSec(5)
     
    repeat 15
      Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10++, p11, p12, 0, 0, 0)
      Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, 100, 100, 0)
      Delay.PauseMSec(5)
     
    repeat 15
      Oled.GraphicsDrawPolygon6(p1++, p2, p3, p4--, p5++, p6, p7++, p8, p9, p10, p11++, p12, 0, 0, 0)
      Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, 100, 100, 0)
      Delay.PauseMSec(5)
     
    repeat 15
      Oled.GraphicsDrawPolygon6(p1, p2, p3++, p4, p5, p6, p7, p8, p9, p10, p11, p12, 0, 0, 0)
      Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, 100, 100, 0)
      Delay.PauseMSec(5)
     
    repeat 15
      Oled.GraphicsDrawPolygon6(p1, p2, p3, p4++, p5, p6, p7, p8, p9, p10, p11, p12, 0, 0, 0)
      Oled.GraphicsDrawPolygon6(p1, p2, p3, p4, p5, p6, p7 ,p8, p9, p10, p11, p12, 100, 100, 0)
      Delay.PauseMSec(5)

  p1 := 160
  P2 := 25

  Delay.PauseSec(1)
  Oled.GraphicsSetPenModeWireFrame

  repeat 45
    Oled.GraphicsDrawCircle(p1--, p2++, 5, 0, 0, 0)
    p2++
    Oled.GraphicsDrawCircle(p1, p2, 5, 100, 100, 0)
    Delay.PauseMSec(20)

  Oled.GraphicsSetPenModeSolid
  Oled.GraphicsDrawCircle(p1, p2, 5, 100, 100, 0)
  Delay.PauseSec(4)
  DisplaySetup(FALSE)
   
PRI DemoPutPixel | temp

  Oled.DisplayReplaceBackgndColor(120, 0, 0)
  Oled.TextDrawStrFixed(1, 13, Oled#TextFontSet8x8, 255, 255, 255, string("Put Pixel"))
  Delay.PauseSec(1)
   
  repeat temp from 10 to 80 step 2                      'Down
   Oled.GraphicsDrawPixel(10,temp, 255, 255, 255)
   Delay.PauseMSec(20)
   
  repeat temp from 10 to 80 step 2                      'Right
   Oled.GraphicsDrawPixel(temp,80, 255, 255, 255)
   Delay.PauseMSec(20)
   
  repeat temp from 80 to 10 step 2                      'Up
   Oled.GraphicsDrawPixel(80,temp, 255, 255, 255)
   Delay.PauseMSec(20)

  repeat temp from 80 to 10 step 2                      'Left
   Oled.GraphicsDrawPixel(temp,10, 255, 255, 255)
   Delay.PauseMSec(20)

  Delay.PauseSec(2)
  DisplaySetup(FALSE)
    
PRI DemoTextButtons

  Oled.GraphicsSetPenModeSolid
  Oled.TextSetTransparent
  Oled.TextDrawButton(Oled#TextButtonStateUp, 5, 16, 200, 0, 0, Oled#TextFontSet5x7, 255, 255, 255, 1, 1, string(" FIRST "))
  Oled.TextDrawButton(Oled#TextButtonStateUp, 30, 42, 0, 200, 0, Oled#TextFontSet8x8, 255, 255, 255, 1, 1, string(" NEXT "))
  Oled.TextDrawButton(Oled#TextButtonStateUp, 5, 70, 0, 0, 200, Oled#TextFontSet8x12, 255, 255, 255, 2, 2, string(" LAST "))
  Delay.PauseSec(2)
   
  Oled.TextDrawButton(Oled#TextButtonStateDown, 5, 16, 200, 0, 0, Oled#TextFontSet5x7, 0, 0, 0, 1, 1, string(" FIRST "))
  Delay.PauseSec(2)
  Oled.TextDrawButton(Oled#TextButtonStateDown, 30, 42, 0, 200, 0, Oled#TextFontSet8x8, 0, 0, 0, 1, 1, string(" NEXT "))
  Delay.PauseSec(2)
  Oled.TextDrawButton(Oled#TextButtonStateDown, 5, 70, 0, 0, 200, Oled#TextFontSet8x12, 0, 0, 0, 2, 2, string(" LAST "))
  Delay.PauseSec(2)
  DisplaySetup(FALSE)
    
PRI DemoFastScroll | temp

  temp := 10
  repeat 35
    if temp > 1
      Oled.GraphicsScreenCopyPaste(0, 60, temp - 5,temp - 5, 30, 40)
    Oled.TextDrawButton(Oled#TextButtonStateUp, temp, temp, 0, 100, 100, Oled#TextFontSet8x8, 200, 0, 0, 2, 2, string("X"))
    Temp += 2
    Delay.PauseMSec(5)
    
  Delay.PauseSec(1)
  Oled.TextSetOpaque
  Oled.TextDrawStrFixed(4, 2, Oled#TextFontSet8x8, 255, 255, 0, string("Count:"))

  Oled.DisplayScrollControl(Oled#DisplayScrollRight, 7)
  Oled.DisplayScrollEnable
  Delay.PauseSec(3)
  Oled.DisplayScrollDisable
  Delay.PauseSec(1)
  
  repeat temp from 0 to 256 step 25
    Oled.TextDrawNumFixed(11, 2, Oled#TextFontSet8x8, 255, 255, 0, temp)
    Delay.PauseMSec(500)
    
  Delay.PauseSec(2)
  DisplaySetup(FALSE)
      
PRI DemoWitch

  Oled.GraphicsDrawRectangle(0, 0, 159, 70, 0, 0, 255)    'Sky
  Oled.GraphicsDrawRectangle(0, 71, 159, 127, 0, 0, 125)  'Water
  Oled.GraphicsDrawCircle(35, 20, 10, 255, 255, 0)        'Sun
  Oled.GraphicsDrawLine(78, 90, 107, 90, 0, 0, 0)         'Hat
  Oled.GraphicsDrawLine(78, 91, 107, 91, 0, 0, 0)
  Oled.GraphicsDrawLine(78, 92, 107, 92, 0, 0, 0)
  Oled.GraphicsDrawTriangle(92, 58, 83, 90, 102, 90, 0, 0, 0)
  
  Oled.GraphicsDrawTriangle(5, 55, 0, 55, 0, 70, 150, 150, 150) 'Ship
  Delay.PauseMSec(200)
  Oled.GraphicsDrawTriangle(10, 55, 0, 55, 0, 75, 150, 150, 150)
  Delay.PauseMSec(200)
  Oled.GraphicsDrawTriangle(15, 55, 0, 55, 0, 80, 150, 150, 150)
  Delay.PauseMSec(200)
  Oled.GraphicsDrawTriangle(20, 55, 0, 55, 0, 85, 150, 150, 150)
  Delay.PauseMSec(200)
  Oled.GraphicsDrawTriangle(25, 55, 0, 55, 0, 90, 150, 150, 150)
  Delay.PauseMSec(200)
  Oled.GraphicsDrawTriangle(35, 55, 0, 55, 0, 95, 150, 150, 150)
  Delay.PauseMSec(200)
  
  Oled.GraphicsDrawTriangle(40, 55, 0, 55, 0, 95, 150, 150, 150)
  Delay.PauseMSec(200)
  Oled.GraphicsDrawTriangle(45, 55, 0, 55, 0, 95, 150, 150, 150)
  Delay.PauseMSec(200)
  Oled.GraphicsDrawTriangle(50, 55, 0, 55, 0, 95, 150, 150, 150)
  Delay.PauseMSec(200)
  Oled.GraphicsDrawTriangle(55, 55, 0, 55, 0, 95, 150, 150, 150)
  Delay.PauseMSec(200)
  Oled.GraphicsDrawTriangle(60, 55, 0, 55, 0, 95, 150, 150, 150)
 
  Delay.PauseSec(1)                                       'Answer
  Oled.TextSetTransparent
  Oled.TextDrawStrFixed(2, 13, Oled#TextFontSet5x7, 255, 255, 255, string("A ship arriving too late to save a drowning witch"))
  Delay.PauseSec(3)
  
  IF (not DemoSD)
    DisplaySetup(FALSE)

PRI DemoClearSectors | temp

  'Clears 240 sectors on the uSD card
  
  repeat temp from 0 to (Oled#MemCardSectorSize - 1) ' Clear uSD buffer
    uSD_Sector[temp] := $00
    
  Oled.TextDrawStrFixed(4, 2, Oled#TextFontSet8x12, 255, 255, 255, string("Clearing "))
  Oled.TextDrawStrFixed(4, 3, Oled#TextFontSet8x12, 255, 255, 255, string(" Sector  "))
     
  repeat temp from 0 to 239
    Oled.MemCardWriteSector(temp, @uSD_Sector)
    Oled.TextDrawNumScaled(30, 55, Oled#TextFontSet8x12, 0, 240, 0, 3, 3, temp)

  Delay.PauseSec(1)
  DisplaySetup(FALSE)
  
PRI DemoWitchToSD

  'Copy the previous screen, "WITCH" to the uSD card at Sector 0 (80 Sectors)
  
   Oled.MemCardSaveImage(0, 0, Oled#GraphicsPixelWidth, Oled#GraphicsPixelHeight, 0)
   Oled.TextSetOpaque
   Oled.TextDrawStrFixed(1, 5, Oled#TextFontSet8x12, 255, 255, 255, string("Screen Copied"))
   Delay.PauseSec(3)
   DisplaySetup(FALSE)
     
PRI DemoStripChart
    
  Oled.GraphicsDrawRectangle(0, 0, 159, 15, 100, 100, 100)
  Oled.GraphicsDrawRectangle(0, 110, 159, 127, 100, 100, 100) 
   
  Oled.GraphicsDrawLine(7, 113, 7, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(15, 113, 15, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(23, 113, 23, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(31, 113, 31, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(39, 113, 39, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(47, 113, 47, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(55, 113, 55, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(63, 113, 63, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(71, 113, 71, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(79, 113, 79, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(87, 113, 87, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(95, 113, 95, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(103, 113, 103, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(111, 113, 111, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(119, 113, 119, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(127, 113, 127, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(135, 113, 135, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(143, 113, 143, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(151, 113, 151, 123, 0, 0, 0)
  Oled.GraphicsDrawLine(159, 113, 159, 123, 0, 0, 0)
   
  Oled.GraphicsDrawLine(0, 33, 159, 33, 255, 0, 0)
  Oled.GraphicsDrawLine(0, 63, 159, 63, 200, 200, 200)
  Oled.GraphicsDrawLine(0, 93, 159, 93, 255, 0, 0)
  Delay.PauseSec(1)
    
  Oled.GraphicsDrawLine(0, 63, 7, 40, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(7, 40, 15, 80, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(15, 80, 23, 25, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(23, 25, 31, 50, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(31, 50, 39, 65, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(39, 65, 47, 90, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(47, 90, 55, 40, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(55, 40, 63, 90, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(63, 90, 71, 30, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(71, 30, 79, 88, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(79, 88, 87, 60, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(87, 60, 95, 20, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(95, 20, 103, 106, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(103, 106, 111, 35, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(111, 35, 119, 88, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(119, 88, 127, 63, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(127, 63, 135, 45, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(135, 45, 143, 30, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(143, 30, 151, 94, 0, 255, 0)
  Delay.PauseMSec(100)
  Oled.GraphicsDrawLine(151, 94, 159, 63, 0, 255, 0)
    
  Oled.DisplayScrollControl(Oled#DisplayScrollLeft, 5)
  Oled.DisplayScrollEnable
  Delay.PauseMSec(11800)
  Oled.DisplayScrollControl(Oled#DisplayScrollLeft, 0)
  Oled.DisplayScrollDisable
  Delay.PauseSec(3)
    
  IF (not DemoSD)
    DisplaySetup(FALSE)

PRI DemoStripChartToSD

  'Copy the previous screen, "STRIPCHART" to the uSD card at Sector 80 (80 Sectors)
  
  Oled.MemCardSaveImage(0, 0, Oled#GraphicsPixelWidth, Oled#GraphicsPixelHeight, 80)
  Oled.TextSetOpaque
  Oled.TextDrawStrFixed(1, 5, Oled#TextFontSet8x12, 255, 255, 255, string("Screen Copied"))
  Delay.PauseSec(3)
  DisplaySetup(FALSE)

PRI DemoMonitor

  Oled.GraphicsSetPenModeSolid
  Oled.GraphicsDrawRectangle(0, 0, 159, 127, 100, 100, 100)
  Oled.GraphicsSetPenModeWireFrame
  Oled.GraphicsDrawRectangle(3, 3, 159 - 4, 124, 200, 200, 200)
  Oled.GraphicsDrawRectangle(4, 4, 159 - 4, 123, 200, 200, 200)
  Oled.GraphicsDrawRectangle(5, 5, 159 - 5, 122, 200, 200, 200)
  Oled.GraphicsDrawRectangle(6, 6, 159 - 6, 121, 30, 30, 30)
   
  Oled.GraphicsSetPenModeSolid
  Oled.GraphicsDrawRectangle(8, 8, 91, 39, 0, 0, 0)

  Oled.TextSetTransparent
  Oled.TextDrawStrScaled(9, 45, Oled#TextFontSet8x12, 0, 0, 0, 1, 1, string("PULSE"))
  Oled.TextSetOpaque
  Oled.TextDrawStrScaled(56, 45, Oled#TextFontSet8x12, 255, 255, 0, 1, 1, string("78"))
   
  Oled.GraphicsDrawLine(10, 30, 12, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(12, 30, 14, 28, 0, 255, 0)
  Oled.GraphicsDrawLine(14, 28, 16, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(16, 30, 18, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(18, 30, 20, 16, 0, 255, 0)
  Oled.GraphicsDrawLine(20, 16, 22, 34, 0, 255, 0)
  Oled.GraphicsDrawLine(22, 34, 26, 26, 0, 255, 0)
  Oled.GraphicsDrawLine(26, 26, 28, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(28, 30, 30, 30, 0, 255, 0)
   
  Oled.GraphicsDrawLine(30, 30, 32, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(32, 30, 34, 28, 0, 255, 0)
  Oled.GraphicsDrawLine(34, 28, 36, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(36, 30, 38, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(38, 30, 40, 16, 0, 255, 0)
  Oled.GraphicsDrawLine(40, 16, 42, 34, 0, 255, 0)
  Oled.GraphicsDrawLine(42, 34, 46, 26, 0, 255, 0)
  Oled.GraphicsDrawLine(46, 26, 48, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(48, 30, 50, 30, 0, 255, 0)
   
  Oled.GraphicsDrawLine(50, 30, 52, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(52, 30, 54, 28, 0, 255, 0)
  Oled.GraphicsDrawLine(54, 28, 56, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(56, 30, 58, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(58, 30, 60, 16, 0, 255, 0)
  Oled.GraphicsDrawLine(60, 16, 62, 34, 0, 255, 0)
  Oled.GraphicsDrawLine(62, 34, 66, 26, 0, 255, 0)
  Oled.GraphicsDrawLine(66, 26, 68, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(68, 30, 70, 30, 0, 255, 0)
   
  Oled.GraphicsDrawLine(70, 30, 72, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(72, 30, 74, 28, 0, 255, 0)
  Oled.GraphicsDrawLine(74, 28, 76, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(76, 30, 78, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(78, 30, 80, 16, 0, 255, 0)
  Oled.GraphicsDrawLine(80, 16, 82, 34, 0, 255, 0)
  Oled.GraphicsDrawLine(82, 34, 86, 26, 0, 255, 0)
  Oled.GraphicsDrawLine(86, 26, 88, 30, 0, 255, 0)
  Oled.GraphicsDrawLine(88, 30, 90, 30, 0, 255, 0)
   
  Oled.GraphicsDrawRectangle(8, 58, 91, 90, 0, 0, 0)
  Oled.TextSetTransparent
  Oled.TextDrawStrScaled(9, 95, Oled#TextFontSet8x12, 0, 0, 0, 1, 1, string("RESP"))
  Oled.TextSetOpaque
  Oled.TextDrawStrScaled(47, 95, Oled#TextFontSet8x12, 255, 255, 0, 1, 1, string("20"))
   
  Oled.GraphicsDrawLine(10, 84, 14, 66, 0, 255, 0)
  Oled.GraphicsDrawLine(14, 66, 18, 84, 0, 255, 0)
  Oled.GraphicsDrawLine(18, 84, 22, 66, 0, 255, 0)
  Oled.GraphicsDrawLine(22, 66, 26, 84, 0, 255, 0)
  Oled.GraphicsDrawLine(26, 84, 30, 66, 0, 255, 0)
   
  Oled.GraphicsDrawLine(30, 66, 34, 84, 0, 255, 0)
  Oled.GraphicsDrawLine(34, 84, 38, 66, 0, 255, 0)
  Oled.GraphicsDrawLine(38, 66, 42, 84, 0, 255, 0)
  Oled.GraphicsDrawLine(42, 84, 46, 66, 0, 255, 0)
  Oled.GraphicsDrawLine(46, 66, 50, 84, 0, 255, 0)
   
  Oled.GraphicsDrawLine(50, 84, 54, 66, 0, 255, 0)
  Oled.GraphicsDrawLine(54, 66, 58, 84, 0, 255, 0)
  Oled.GraphicsDrawLine(58, 84, 62, 66, 0, 255, 0)
  Oled.GraphicsDrawLine(62, 66, 66, 84, 0, 255, 0)
  Oled.GraphicsDrawLine(66, 84, 70, 66, 0, 255, 0)
   
  Oled.GraphicsDrawLine(70, 66, 74, 84, 0, 255, 0)
  Oled.GraphicsDrawLine(74, 84, 78, 66, 0, 255, 0)
  Oled.GraphicsDrawLine(78, 66, 82, 84, 0, 255, 0)
  Oled.GraphicsDrawLine(82, 84, 86, 66, 0, 255, 0)
  Oled.GraphicsDrawLine(86, 66, 90, 84, 0, 255, 0)

  Oled.TextSetTransparent
  Oled.TextDrawButton(Oled#TextButtonStateUp, 68, 100, 255, 0, 0, Oled#TextFontSet8x8, 0, 0, 0, 1, 1, string("RESET"))
   
  Oled.GraphicsSetPenModeWireFrame
  Oled.GraphicsDrawRectangle(100, 15, 110, 75, 0, 0, 0)
  Oled.GraphicsSetPenModeSolid
  Oled.GraphicsDrawRectangle(101, 16, 109, 30, 150, 150, 150)
  Oled.GraphicsDrawLine(101, 31, 109, 31, 0, 0, 0)
  Oled.GraphicsDrawRectangle(101, 32, 109, 74, 0, 150, 0)
  Oled.TextDrawCharScaled("O", 97, 77, Oled#TextFontSet8x8, 0, 0, 0, 1, 1)
  Oled.TextDrawCharScaled("2", 105, 80, Oled#TextFontSet5x7, 0, 0, 0, 1, 1)
   
  Oled.GraphicsDrawRectangle(138, 20, 141, 90, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 25, 143, 25, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 30, 143, 30, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 35, 143, 35, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 40, 143, 40, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 45, 143, 45, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 50, 143, 50, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 55, 143, 55, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 60, 143, 60, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 65, 143, 65, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 70, 143, 70, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 75, 143, 75, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 80, 143, 80, 0, 0, 0)
  Oled.GraphicsDrawLine(136, 85, 143, 85, 0, 0, 0)
   
  Oled.GraphicsDrawLine(135, 52, 144, 52, 220, 220, 220)
  Oled.GraphicsDrawLine(134, 53, 145, 53, 100, 100, 100)
  Oled.GraphicsDrawLine(134, 54, 145, 54, 0, 0, 0)
   
  Oled.GraphicsDrawCircle(140, 110, 6, 200, 0, 0)
  Oled.GraphicsDrawCircle(139, 110, 3, 255, 100, 100)
  Oled.GraphicsDrawPixel(138, 110, 255, 255, 255)
  Delay.PauseSec(3)

  IF (not DemoSD)
    DisplaySetup(FALSE)

PRI DemoMonitorToSD

  'Copy the previous screen, "MONITOR" to the uSD card at Sector 160 (80 Sectors)
  
  Oled.MemCardSaveImage(0, 0, Oled#GraphicsPixelWidth, Oled#GraphicsPixelHeight, 160)
  Oled.TextDrawStrFixed(1, 5, Oled#TextFontSet8x12, 255, 255, 255, string("Screen Copied"))
  Delay.PauseSec(3)
  DisplaySetup(FALSE)
  
PRI DemoMonitorFromSD

  'Displays the screen "MONITOR" that was copied to the uSD earlier
  
  Oled.TextDrawStrFixed(0, 3, Oled#TextFontSet8x12, 255, 255, 255, string("Display Copy of"))
  Oled.TextDrawStrFixed(0, 5, Oled#TextFontSet8x12, 255, 255, 255, string("  'MONITOR'    "))
  Oled.TextDrawStrFixed(0, 7, Oled#TextFontSet8x12, 255, 255, 255, string(" from uSD card "))
  Delay.PauseSec(3)
  Oled.MemCardLoadImage(0, 0, Oled#GraphicsPixelWidth, Oled#GraphicsPixelHeight, Oled#GraphicsImageColorMode65K, 160)
  Delay.PauseSec(3)
  DisplaySetup(FALSE)

PRI DemoStripChartFromSD

  'Displays the screen "STRIPCHART" that was copied to the uSD earlier
  
  Oled.TextDrawStrFixed(0, 3, Oled#TextFontSet8x12, 255, 255, 255, string("Display Copy of"))
  Oled.TextDrawStrFixed(0, 5, Oled#TextFontSet8x12, 255, 255, 255, string(" 'STRIPCHART'  "))
  Oled.TextDrawStrFixed(0, 7, Oled#TextFontSet8x12, 255, 255, 255, string(" from uSD card "))
  Delay.PauseSec(3)
  Oled.MemCardLoadImage(0, 0, Oled#GraphicsPixelWidth, Oled#GraphicsPixelHeight, Oled#GraphicsImageColorMode65K, 80)
  Delay.PauseSec(3)
  DisplaySetup(FALSE)

PRI DemoWitchFromSD

  'Displays the screen "WITCH" that was copied to the uSD earlier
  
  Oled.TextDrawStrFixed(0, 3, Oled#TextFontSet8x12, 255, 255, 255, string("Display Copy of"))
  Oled.TextDrawStrFixed(0, 5, Oled#TextFontSet8x12, 255, 255, 255, string("    'WITCH'    "))
  Oled.TextDrawStrFixed(0, 7, Oled#TextFontSet8x12, 255, 255, 255, string(" from uSD card "))
  Delay.PauseSec(3)
  Oled.MemCardLoadImage(0, 0, Oled#GraphicsPixelWidth, Oled#GraphicsPixelHeight, Oled#GraphicsImageColorMode65K, 0)
  Delay.PauseSec(3) 
  DisplaySetup(FALSE)

PRI DemoPartScreensFromSD

  'Displays partial screens of the three "screen shots" saved to the uSD card
  
  Oled.TextDrawStrFixed(1, 3, Oled#TextFontSet8x12, 255, 255, 255, string("Display parts"))
  Oled.TextDrawStrFixed(1, 5, Oled#TextFontSet8x12, 255, 255, 255, string("of all three "))
  Oled.TextDrawStrFixed(1, 7, Oled#TextFontSet8x12, 255, 255, 255, string("saved screens"))
  Delay.PauseSec(3)
  Oled.MemCardLoadImage(0, 0, Oled#GraphicsPixelWidth, 40, Oled#GraphicsImageColorMode65K, 0)
  Oled.MemCardLoadImage(0, 43, Oled#GraphicsPixelWidth, 40, Oled#GraphicsImageColorMode65K, 80)
  Oled.MemCardLoadImage(0, 86, Oled#GraphicsPixelWidth, 40, Oled#GraphicsImageColorMode65K, 160)
  Delay.PauseSec(3)
  DisplaySetup(FALSE)

PRI DemoFastImagesFromSD

  'Displays three images stored on the uSD at maximum speed
  
  Oled.TextDrawStrFixed(1, 3, Oled#TextFontSet8x12, 255, 255, 255, string("'Flip' images"))
  Oled.TextDrawStrFixed(1, 5, Oled#TextFontSet8x12, 255, 255, 255, string("of all three "))
  Oled.TextDrawStrFixed(1, 7, Oled#TextFontSet8x12, 255, 255, 255, string("saved screens"))
  Oled.TextDrawStrFixed(1, 9, Oled#TextFontSet8x12, 255, 255, 255, string("at max speed "))
  Delay.PauseSec(3)

  repeat 15
    Oled.DisplayClearScreen
    Oled.MemCardLoadImage(0, 0, Oled#GraphicsPixelWidth, Oled#GraphicsPixelHeight, Oled#GraphicsImageColorMode65K, 0)   ' Witch
    Oled.DisplayClearScreen
    Oled.MemCardLoadImage(0, 0, Oled#GraphicsPixelWidth, Oled#GraphicsPixelHeight, Oled#GraphicsImageColorMode65K, 80)   ' Stripchard
    Oled.DisplayClearScreen
    Oled.MemCardLoadImage(0, 0, Oled#GraphicsPixelWidth, Oled#GraphicsPixelHeight, Oled#GraphicsImageColorMode65K, 160)   ' Monitor
 
  Delay.PauseSec(2) 
  DisplaySetup(FALSE)
  
PRI DemoContrast

  Oled.TextDrawStrFixed(2, 2, Oled#TextFontSet8x12, 255, 255, 255, string("Contrast Down"))
  Oled.DisplayFadeoutContrast(200)
  Delay.PauseSec(1)
  DisplaySetup(FALSE)
  Delay.PauseSec(1)

PRI DemoShutdown

  Oled.TextDrawStrFixed(8, 1, Oled#TextFontSet5x7, 255, 255, 255, string("Shutdown in:"))
  Oled.TextDrawCharScaled("5", 80, 30, Oled#TextFontSet8x12, 0, 255, 0, 2, 2)
  Oled.TextDrawStrFixed(3, 8, Oled#TextFontSet5x7, 255, 255, 0, string("Restart in 10 seconds"))
  Delay.pauseSec(1)
  
  Oled.TextDrawCharScaled("4", 80, 30, Oled#TextFontSet8x12, 0, 255, 0, 2, 2) 
  Delay.pauseSec(1)
  Oled.TextDrawCharScaled("3", 80, 30, Oled#TextFontSet8x12, 255, 255, 0, 2, 2) 
  Delay.pauseSec(1)
  Oled.TextDrawCharScaled("2", 80, 30, Oled#TextFontSet8x12, 255, 255, 0, 2, 2) 
  Delay.pauseSec(1)
  Oled.TextDrawCharScaled("1", 80, 30, Oled#TextFontSet8x12, 255, 0, 0, 2, 2) 
  Delay.PauseSec(1)
  Oled.TextDrawCharScaled("0", 80, 30, Oled#TextFontSet8x12, 255, 0, 0, 2, 2)
  
  Oled.TextDrawStrFixed(2, 11, Oled#TextFontSet5x7, 0, 255, 0, string("Safe to turn power off"))
  Oled.TextDrawStrFixed(2, 12, Oled#TextFontSet5x7, 0, 255, 0, string(" after screen clears!")) 
  Delay.PauseSec(4)
  Oled.DisplayClearScreen
  Delay.PauseMSec(20)    
  Oled.DisplaySetPowerOff
  Delay.PauseSec(10)
  Oled.DisplaySetPowerOn
  DisplaySetup(TRUE)

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