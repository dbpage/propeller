{{

┌──────────────────────────────────────────┐
│ RealTimeClock.spin       Version 1.01    │
│ Author: Mathew Brown                     │               
│ Copyright (c) 2008 Mathew Brown          │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

Real time clock object/methods.

Starts a real time clock in a new cog.
This clock tracks both time, and date, and includes days in month/leap year day corrections.

Time/date can be set using the following...

1) Via direct writes to timekeeping registers
2) Via time & date setting methods
3) Via loading with a 32 bit packed Microsoft format time

Time/date can be read using the following...

1) Via direct reads from timekeeping registers
2) Via return as strings representing time / date
3) Via return of a 32 bit packed Microsoft format time

------------------------------------------------------
Revision 1.01 changes:-
Added day of week funtionality.
------------------------------------------------------  
}}
                                         
VAR
             
  ''Global vars...
  long Cog                                              'Cog issued tracking
  long RtcStack[32]                                     'Stack for RTC object in new cog

  'The following must be contigious...
  '[
  Byte LclRtc[7]                                        'Local real time clock counters
  Byte TimeDate[7]                                      'Time/date return registers
  ']

  
PUB Start:Success 'Start the RTC object in a new cog...

  If not cog                                            'RTC not already started
    Success := Cog := Cognew(RtcMain(@LclRtc),@RtcStack)  'Start in new cog
 
PUB Stop 'Stops the Real Time Clock object, frees a cog.

  If Cog
    Cogstop(Cog)
  
PUB ReadTimeReg(Index):Value 'Allows calling object to query timekeeping registers, individually

{ Index = 0, indexes seconds       .. 'value' in range 0 to 59
  Index = 1, indexes minutes       .. 'value' in range 0 to 59
  Index = 2, indexes hours         .. 'value' in range 0 to 23
  Index = 3, indexes days          .. 'value' in range 1 up-to 31 (month dependant)
  Index = 4, indexes months        .. 'value' in range 1 to 12
  Index = 5, indexes years         .. 'value' in range 0 to 99    (00 = 2000.... 99 = 2099)
  Index = 6, indexes day of week   .. 'value' in range 1 to 7     (1 = Sunday.... 7 = Saturday)       
}

  Value := byte[@TimeDate][Index]                       'Read data from double buffered read registers

  If Lookdown(Index:3,4,6)                              'Adjust 0 indexed days/months/day of week, to 1 indexed
    Value++
   
PUB WriteTimeReg(Index,Value) 'Allows calling object to write to timekeeping registers, individually

{ Index = 0, indexes seconds       .. 'value' in range 0 to 59
  Index = 1, indexes minutes       .. 'value' in range 0 to 59
  Index = 2, indexes hours         .. 'value' in range 0 to 23
  Index = 3, indexes days          .. 'value' in range 1 up-to 31 (month dependant)
  Index = 4, indexes months        .. 'value' in range 1 to 12
  Index = 5, indexes years         .. 'value' in range 0 to 99    (00 = 2000.... 99 = 2099)
  NOTE:- WEEKDAY IS CALCULATED AUTOMATICALLY, BASED UPON TODAYS DATE    
}

  If Lookdown(Index:3,4)                                'Adjust 1 indexed days/months, to zero indexed
    Value--
    
  byte[@LclRtc][Index] := Value                         'Write data to master time keeping registers

PUB SetTime(Hours,Minutes,Seconds) 'Set time
'Has method dependency 'WriteTimeReg'

  WriteTimeReg(2,Hours)                                 'Write hours data
  WriteTimeReg(1,Minutes)                               'Write minutes data
  WriteTimeReg(0,Seconds)                               'Write seconds data
  
PUB SetDate(Day,Month,Year) 'Set Date
'Has method dependency 'WriteTimeReg'

  WriteTimeReg(3,Day)                                   'Write day data
  WriteTimeReg(4,Month)                                 'Write month data
  WriteTimeReg(5,Year)                                  'Write year data

PUB ReadStrDate(UsaDateFormat):StrPtr 'Returns pointer, to string date,either as UK/USA format
'Has method dependency 'ReadTimeReg' & 'IntAscii'   

  StrPtr := String("??/??/20??")                        'Return string

  If UsaDateFormat
  
    'TRUE .... USA format date string
    IntAscii(StrPtr,ReadTimeReg(4))                     'Overwrite first two chars in string with month number 01-12
    IntAscii(StrPtr+3,ReadTimeReg(3))                   'Overwrite next two chars, after "/" with day number 01-31
    IntAscii(StrPtr+8,ReadTimeReg(5))                   'Overwrite next two chars, after "20" with year number 00-99

  else
    
    'FALSE .... UK format date string
    IntAscii(StrPtr,ReadTimeReg(3))                     'Overwrite first two chars in string with day number 01-31
    IntAscii(StrPtr+3,ReadTimeReg(4))                   'Overwrite next two chars, after "/" with month number 01-12
    IntAscii(StrPtr+8,ReadTimeReg(5))                   'Overwrite next two chars, after "20" with year number 00-99
  
PUB ReadStrTime:StrPtr 'Returns pointer, to string time
'Has method dependency 'ReadTimeReg' & 'IntAscii'
 
  StrPtr := String("??:??:??")                          'Return string  

  IntAscii(StrPtr,ReadTimeReg(2))                       'Overwrite first two chars in string with hour number 00-23
  IntAscii(StrPtr+3,ReadTimeReg(1))                     'Overwrite next two chars, after "/" with minutes number 00-59
  IntAscii(StrPtr+6,ReadTimeReg(0))                     'Overwrite next two chars, after "/" with seconds number 00-59

PUB ReadStrWeekday:StrPtr 'Returns pointer, to a 3 letter string, representing the day of the week

  StrPtr := @DayOfWeek + (4* Byte[@TimeDate][6]) 
   
PUB ReadMsTime:MsTime  'Returns current time & date, as compressed 32 BIT Microsoft Time format
'Has method dependency 'ReadTimeReg'
 
  ''Create 32 bit packed Microsoft format date/time
  MsTime := ((ReadTimeReg(5)+20)<<25)                   'Bits 31 - 25 are years since 1980
  MsTime += (ReadTimeReg(4)<<21)                        'Bits 24 - 21 are month (1 to 12)
  MsTime += (ReadTimeReg(3)<<16)                        'Bits 20 - 16 are day (1 to 31)
  MsTime += (ReadTimeReg(2)<<11)                        'Bits 15 - 11 are hour (0 to 23)
  MsTime += (ReadTimeReg(1)<<5)                         'Bits 10 - 5 are minute (0 to 59) 
  MsTime += (ReadTimeReg(0)>>1)                         'Bits 4 - 0 are seconds/2 (0 to 30)
  
PUB WriteMsTime(MsTime) 'Sets time/date registers using compressed 32 BIT Microsoft Time format
'Has method dependency 'WriteTimeReg'

  WriteTimeReg(0,(2*MsTime) & %11111 )                  'Extract seconds from MsTime & write to time register
  WriteTimeReg(1,(MsTime>>5) & %111111)                 'Minutes
  WriteTimeReg(2,(MsTime>>11) & %11111)                 'Hours
  WriteTimeReg(3,(MsTime>>16) & %11111)                 'Days
  WriteTimeReg(4,(MsTime>>21) & %1111)                  'Months
  WriteTimeReg(5,(MsTime>>25)-20)                       'Years

   
PRI IntAscii(Pointer,Number) 'Low level conversion of integer 00-99, to two ASCII chars...

  byte[Pointer][0] := (Number/10) +"0"                  'First character is tens (division by 10, + ASCII offset)
  byte[Pointer][1] := (Number//10) +"0"                 'Second character is units (modulus 10 + ASCII offset)
   
PRI RtcMain(Pointer)|SysCnt,Counter,LapsedDays 'Timekeeping method.. runs in a new cog
'All timekeeping registers are zero indexed!!!

  SysCnt := Cnt                                         'Set timer reference

  repeat                                                'Do forever
'-------------------------------------------------------------------------------------------------------
'Wait until 1 second has passed

    SysCnt += ClkFreq                                   'Increment timer reference count + 1 second
    waitcnt(SysCnt)                                     'Wait for 1 second to expire

'-------------------------------------------------------------------------------------------------------
'Make leap year correction to month length lookup table

    If (Byte[Pointer][5]&3)
          
      byte[@MonthLen][1] := 28 'Modify table data for February, for not Leap year
                      
    else
          
      byte[@MonthLen][1] := 29 'Modify table data for February, for Leap year
      
'-------------------------------------------------------------------------------------------------------
'Modify rollover table, so that days rollover entry is correct for days in this month...

    byte[@RollOvers][3] := byte[@MonthLen][ Byte[Pointer][4] ] 'Modify table data for month rollover data

'-------------------------------------------------------------------------------------------------------
'Increment time

    repeat Counter from 0 to 5                          '6 time/date fields to possibly increment/rollover

      ++Byte[Pointer][Counter]                          'Increment time
      Byte[Pointer][Counter] //= byte[@RollOvers][Counter] 'Perform modulus (rollover)

      If Byte[Pointer][Counter]                         'Test for rolled-over to zero...   If not rolled-over...
        quit                                            'Exit repeat loop
        
'-------------------------------------------------------------------------------------------------------
'Calculate the day of the week, based upon todays date

   LapsedDays := 6                                      '1st January 2000, was a Saturday
   
   LapsedDays +=  Byte[Pointer][5] * 365                'Add 365 days, for each full year passed
   LapsedDays += (Byte[Pointer][5] +3 )/4               'Peform leap year corrections...

   Repeat Counter from 0 to Byte[Pointer][4]            'Add days for full months passed this year
     LapsedDays += (Byte[@MonthIdx][Counter])           '... Using month length lookup table (previously leap year corrected!!)  

   LapsedDays +=  Byte[Pointer][3]                      'Add current day of this month
   
   Byte[Pointer][6] := LapsedDays // 7                  'Write data, modulus 7 ... 7 days in a week
           
'-------------------------------------------------------------------------------------------------------
'Write double buffered time/date data, for use by main object

    'Copy double buffered data
    Bytemove((Pointer+7),Pointer,7)                     'Copy data




DAT

  '[ The following must be contigous
  MonthIdx  byte 0                                      'January .. 0 days to add to lapsed days, for day of week calculation
  MonthLen  byte 31,28,31,30,31,30,31,31,30,31,30,31    'Month lengths lookup table
  ']
  
  RollOvers byte 60,60,24,31,12,100                     'Time/date rollover limits sec,min,hrs,days,month,year
  DayOfWeek byte "Sun",0,"Mon",0,"Tue",0,"Wed",0,"Thu",0,"Fri",0,"Sat",0

DAT
     {<end of object code>}
     
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