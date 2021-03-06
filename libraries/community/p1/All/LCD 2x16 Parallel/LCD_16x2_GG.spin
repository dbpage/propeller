{{
┌──────────────────────┐
│ Parallel LCD Driver  │
├──────────────────────┴───────────────────────┐
│  Width      : 16 Characters                  │
│  Height     :  2 Lines                       │
│  Interface  :  8 Bit                         │
│  Controller :  HD44780-based                 │
├──────────────────────────────────────────────┤
│  By      : Simon Ampleman                    │
│            sa@infodev.ca                     │
│  Date    : 2006-11-18                        │
|  Version : 1.0                               |
|                                              |
│  Modified by:  Rich Harman                   |
│  Date    : 2009-10-30                        │
|                                              |
|  For use with 16x2 LCD from Gadget Gangster  │
│  See end of file for terms of use.           │
└──────────────────────────────────────────────┘

Removed "Timing" object dependency.
Rich H 2009-5-26

Added Debug method
Rich H 2009-7-15

Changed CHAR method to PUB
Added debugf
Added CR
Added Home
Rich H 2009-7-20

Pin assignments are for use with the ServoBoss available
from GadgetGangster.com

Hardware used : SSC2F16DLNW-E                    

Schematics
                         P8X32A
                       ┌────┬────┐ 
                       ┤0      31├              0V    5V    0V   P16   P17   P18   P15   P14
                       ┤1      30├              │     │     │     │     │     │     │     │
                       ┤2      29├              │VSS  │VDD  │VO   │R/S  │R/W  │E    │DB0  │DB1                              
                       ┤3      28├              ┴1    ┴2    ┴3    ┴4    ┴5    ┴6    ┴7    ┴8
                       ┤4      27├            ┌────────────────────────────────────────────────┐
                       ┤5      26├            │ 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16│  LCD 16X2
                       ┤6      25├            │ 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16│  HD44780-BASED
                       ┤7      24├            └────────────────────────────────────────────────┘  SSC2F16DLNW-E
                       ┤VSS   VDD├              ┬9    ┬10   ┬11   ┬12   ┬13   ┬14   ┬15   ┬16
                       ┤BOEn   XO├              │DB2  │DB3  │DB4  │DB5  │DB6  │DB7  │A(+) │K(-)             
                       ┤RESn   XI├              │     │     │     │     │     │     │     │
                       ┤VDD   VSS├             P13   P12   P11   P10   P9    P8     5V    0V
                   DB7 ┤8      23├ 
                   DB6 ┤9      22├ 
                   DB5 ┤10     21├ 
                   DB4 ┤11     20├
                   DB3 ┤12     19├ 
                   DB2 ┤13     18├ E
                   DB1 ┤14     17├ RW
                   DB0 ┤15     16├ R/S
                       └─────────┘ 


PIN ASSIGNMENT
   VSS  - POWER SUPPLY (GND)
   VCC  - POWER SUPPLY (+5V)
   VO   - CONTRAST ADJUST (0-5V)
   R/S  - FLAG TO RECEIVE INSTRUCTION OR DATA
            0 - INSTRUCTION
            1 - DATA
   R/W  - INPUT OR OUTPUT MODE
            0 - WRITE TO LCD MODULE
            1 - READ FROM LCD MODULE
   E    - ENABLE SIGNAL 
   DB0  - DATA BUS LINE 0 (LSB)
   DB1  - DATA BUS LINE 1 
   DB2  - DATA BUS LINE 2 
   DB3  - DATA BUS LINE 3 
   DB4  - DATA BUS LINE 4 
   DB5  - DATA BUS LINE 5 
   DB6  - DATA BUS LINE 6 
   DB7  - DATA BUS LINE 7 (MSB)
   A(+) - BACKLIGHT 5V
   K(-) - BACKLIGHT GND

INSTRUCTION SET
   ┌──────────────────────┬───┬───┬─────┬───┬───┬───┬───┬───┬───┬───┬───┬─────┬─────────────────────────────────────────────────────────────────────┐
   │  INSTRUCTION         │R/S│R/W│     │DB7│DB6│DB5│DB4│DB3│DB2│DB1│DB0│     │ Description                                                         │
   ├──────────────────────┼───┼───┼─────┼───┼───┼───┼───┼───┼───┼───┼───┼─────┼─────────────────────────────────────────────────────────────────────┤
   │ CLEAR DISPLAY        │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 0 │ 0 │ 0 │ 1 │     │ Clears display and returns cursor to the home position (address 0). │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ CURSOR HOME          │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 0 │ 0 │ 1 │ * │     │ Returns cursor to home position (address 0). Also returns display   │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ being shifted to the original position.                             │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ ENTRY MODE SET       │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 0 │ 1 │I/D│ S │     │ Sets cursor move direction (I/D), specifies to shift the display(S) │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ These operations are performed during data read/write.              │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ DISPLAY ON/OFF       │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 1 │ D │ C │ B │     │ Sets On/Off of all display (D), cursor On/Off (C) and blink of      │
   │ CONTROL              │   │   │     │   │   │   │   │   │   │   │   │     │ cursor position character (B).                                      │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ CURSOR/DISPLAY       │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 1 │S/C│R/L│ * │ * │     │ Sets cursor-move or display-shift (S/C), shift direction (R/L).     │
   │ SHIFT                │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ FUNCTION SET         │ 0 │ 0 │     │ 0 │ 0 │ 1 │ DL│ N │ F │ * │ * │     │ Sets interface data length (DL), number of display line (N) and     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ character font(F).                                                  │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ SET CGRAM ADDRESS    │ 0 │ 0 │     │ 0 │ 1 │      CGRAM ADDRESS    │     │ Sets the CGRAM address. CGRAM data is sent and received after       │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ this setting.                                                       │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ SET DDRAM ADDRESS    │ 0 │ 0 │     │ 1 │       DDRAM ADDRESS       │     │ Sets the DDRAM address. DDRAM data is sent and received after       │                                                             
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ this setting.                                                       │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ READ BUSY FLAG AND   │ 0 │ 1 │     │ BF│    CGRAM/DDRAM ADDRESS    │     │ Reads Busy-flag (BF) indicating internal operation is being         │
   │ ADDRESS COUNTER      │   │   │     │   │   │   │   │   │   │   │   │     │ performed and reads CGRAM or DDRAM address counter contents.        │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ WRITE TO CGRAM OR    │ 1 │ 0 │     │         WRITE DATA            │     │ Writes data to CGRAM or DDRAM.                                      │
   │ DDRAM                │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ READ FROM CGRAM OR   │ 1 │ 1 │     │          READ DATA            │     │ Reads data from CGRAM or DDRAM.                                     │
   │ DDRAM                │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   └──────────────────────┴───┴───┴─────┴───┴───┴───┴───┴───┴───┴───┴───┴─────┴─────────────────────────────────────────────────────────────────────┘
   Remarks :
            * = 0 OR 1
        DDRAM = Display Data Ram
                Corresponds to cursor position                  
        CGRAM = Character Generator Ram        

   ┌──────────┬──────────────────────────────────────────────────────────────────────┐
   │ BIT NAME │                          SETTING STATUS                              │                                                              
   ├──────────┼─────────────────────────────────┬────────────────────────────────────┤
   │  I/D     │ 0 = Decrement cursor position   │ 1 = Increment cursor position      │
   │  S       │ 0 = No display shift            │ 1 = Display shift                  │
   │  D       │ 0 = Display off                 │ 1 = Display on                     │
   │  C       │ 0 = Cursor off                  │ 1 = Cursor on                      │
   │  B       │ 0 = Cursor blink off            │ 1 = Cursor blink on                │
   │  S/C     │ 0 = Move cursor                 │ 1 = Shift display                  │
   │  R/L     │ 0 = Shift left                  │ 1 = Shift right                    │
   │  DL      │ 0 = 4-bit interface             │ 1 = 8-bit interface                │
   │  N       │ 0 = 1/8 or 1/11 Duty (1 line)   │ 1 = 1/16 Duty (2 lines)            │
   │  F       │ 0 = 5x7 dots                    │ 1 = 5x10 dots                      │
   │  BF      │ 0 = Can accept instruction      │ 1 = Internal operation in progress │
   └──────────┴─────────────────────────────────┴────────────────────────────────────┘


   DDRAM ADDRESS USAGE FOR A 2-LINE DISPLAY

    00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39   <- CHARACTER POSITION
   ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
   │00│01│02│03│04│05│06│07│08│09│0A│0B│0C│0D│0E│0F│10│11│12│13│14│15│16│17│18│19│1A│1B│1C│1D│1E│1F│20│21│22│23│24│25│26│27│  <- ROW0 DDRAM ADDRESS
   │40│41│42│43│44│45│46│47│48│49│4A│4B│4C│4D│4E│4F│50│51│52│53│54│55│56│57│58│59│5A│5B│5C│5D│5E│5F│60│61│62│63│64│65│66│67│  <- ROW1 DDRAM ADDRESS
   └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
}}      
        
        
        
CON

  ' Pin assignment
  RS = 0
  RW = 30
  E  = 27

  DB0 = 26
  DB7 = 19
  Delay = 200_000
   
PUB START  

  DIRA[DB7..DB0] := %11111111                              ' Set everything to output              
  DIRA[RS] := 1
  DIRA[RW] := 1
  DIRA[E] := 1

  INIT 

PRI INIT

  waitcnt (clkfreq/100 + cnt)

  OUTA[DB7..DB0] := %00000000                              ' Output low on all pins
  OUTA[RS] := 0
  OUTA[RW] := 0
  OUTA[E]  := 0
  
  INST8 (%0011_1000)                                 ' Set to DL=8 bits, N=2 lines, F=5x7 fonts
  CLEAR
  INST8 (%0000_1100)                                 ' Display on, Cursor off, Blink off                                             
  INST8 (%0000_0110)                                 ' Increment Cursor + No-Display Shift

  waitcnt(clkfreq/4 + cnt)

PUB CR
  move(1,2)

PUB Home
  move(1,1)

PUB debug(value, X, Y, digits)  |number, spaces      ' example: debug(99, 6, 1, 3)

{{

    This prints whole numbers.

    The ones digit is always anchored - that is the "X" paramater that you pass to the method
    "Y" is either 1 or 2 depending which line you want to print to.

    Specify number of "digits" that you want printed.

    It will always print to fill up how many digits you specified. for example if you
    specify 4 digits and the actual value is 11 it will print 2 blank spaces first, then the 11.

    If your actual value is -11, it will print 1 blank space, then -11.

}}

    number := 10
    spaces := 1

      repeat digits - 1                              ' the loop will repeat twice (digits -1 is 2)
        IF || value > number -1                         ' value(99) is greater than (10 -1) spaces now equals 2
          spaces ++                                  ' 2nd time through -value is not greater than 100 so spaces still equals 2
        number *= 10                                 ' number is mulptiplied by 10 each time through the loop
      X := X - digits + 1
      move(X , Y)                        ' move left by number of digits X - digits(3) +1 equals 4

      if value < 0
        move(X-1, Y)                                 ' If negative value, move left one space to make room for negative sign
      repeat digits - spaces                         ' digits - spaces equals 1
        CHAR(" ")                                    ' prints one leading space at X4
      dec(value)                                     ' prints value at X5 and X6

PUB debugf(value, X, Y, digits, places)  | divisor, number, spaces

{{

    This prints pseudo floating point numbers.

    The ones digit is always anchored - that is the "X" parameter that you pass to the method

    Specify number of "digits" that you want printed
    on the left side of the decimal point.

    It will always print to fill those spaces. for example if you
    specify 10 digits and the actual value is 3 it will print
    9 blank spaces first, then the 3.

    If your actual value is -3, it will print 8 blank spaces, then -3.

    "places" is how many decimal places.

    using the above example, if your value is 3 and the places is 2,
    it will print .02

    Another example;

    value := 156_876
    debugf(value, 1,1, 3,3)

    This will print no blank spaces, then 156, (value/1_000) then a period
    and finally 876 which is the remainder of 156_876/1_000  (156_876//1_000)

}}

    divisor := 1
    number := 10
    spaces := 0


      repeat places
         divisor *= 10                           ' calculate divisor based upon decimal places

      repeat digits - 1
        IF || value/divisor > number -1             ' figure outhow many digits are in number
          x--
          spaces++                               ' move x left to accomodate number if needed - keeping decimal in the same place
        number *= 10                             ' digits must be high enough to handle largest possible number or else number will get
                                                 ' shifted when printed
      X:= X - spaces
      move(X, Y)                      ' Position Cursor

      if value < 0                    ' If negative value, move left one space to make room for negative sign
        move(X-1, Y)
      repeat spaces
        CHAR(" ")                     ' print leading spaces
      dec(value / divisor)            ' Print Whole Part
      CHAR(".")                       ' Print Decimal Point

      number := 10
      repeat places - 1
        IF || value//divisor < divisor/number
          dec (0)
        number *= 10

      dec(|| value//divisor)

PRI BUSY | IS_BUSY
  DIRA[DB7..DB0] := %00000000
  OUTA[RW] := 1                              
  OUTA[RS] := 0                              
  REPEAT
    OUTA[E]  := 1
    IS_BUSY := INA[DB7]     
    OUTA[E]  := 0
  WHILE (IS_BUSY == 1)
  DIRA[DB7..DB0] := %11111111

PRI INST8 (LCD_DATA)            

  BUSY

  OUTA[RW] := 0                              
  OUTA[RS] := 0                              
  OUTA[E]  := 1
  OUTA[DB7..DB0] := LCD_DATA
  OUTA[E]  := 0                              

PUB CHAR (LCD_DATA)                            ' changed to PUB so that can be accessed from outside object
    
  BUSY

  OUTA[RW] := 0                              
  OUTA[RS] := 1                              
  OUTA[E]  := 1
  OUTA[DB7..DB0] := LCD_DATA
  OUTA[E]  := 0  

PUB CLEAR
  ' Clear display, Return Cursor Home
  INST8 (%0000_0001)
  waitcnt(clkfreq/(delay/500) + cnt)

PUB MOVE (X,Y) | ADR
  ' X : Horizontal Position : 1 to 16
  ' Y : Line Number         : 1 or 2
  ADR := (Y-1) * 64
  ADR += (X-1) + 128
  INST8 (ADR)
  waitcnt(clkfreq/delay + cnt)

PUB STR (STRINGPTR)
  REPEAT STRSIZE(STRINGPTR)
    CHAR(BYTE[STRINGPTR++])
  waitcnt(clkfreq/delay +cnt)

PUB DEC (VALUE) | TEMP
  IF (VALUE < 0)
    -VALUE
    CHAR("-")

  TEMP := 1_000_000_000

  REPEAT 10
    IF (VALUE => TEMP)
      CHAR(VALUE / TEMP + "0")
      VALUE //= TEMP
      RESULT~~
    ELSEIF (RESULT OR TEMP == 1)
      CHAR("0")
    TEMP /= 10
  waitcnt(clkfreq/delay +cnt)

PUB HEX (VALUE, DIGITS)

  VALUE <<= (8 - DIGITS) << 2
  REPEAT DIGITS
    CHAR(LOOKUPZ((VALUE <-= 4) & $F : "0".."9", "A".."F"))

PUB BIN (VALUE, DIGITS)

  VALUE <<= 32 - DIGITS
  REPEAT DIGITS
    CHAR((VALUE <-= 1) & 1 + "0")

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
│ARISING FROM,     OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
