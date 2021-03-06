{{

***************************************
*  Maidenhead Calculation Functions   *
*  Author: Thomas P. Sullivan/W1AUV   *
*  Copyright (c) 2008                 *
*  See end of file for terms of use.  *
***************************************

 -----------------REVISION HISTORY-----------------
 v1.00 - Original Version
 v1.05 - Integrated Maidenhead and NMEA functions
 v1.06 - Checksum for validating NMEA strings
 v1.07 - Tweaks
 v1.08 - Fixed NMEA to Maidenhead problem

Maidenhead, a shorthand for latitude and longitude, is used by Amateur Radio operators (hams) for
use in identifying a location. For some contests, VHF, UHF+, Maidenhead is used as a required part
of the exchange. For microwave contests, Maidenhead is used as a required part of the exchange and
also to compute your heading to another station. Aiming is important at these frequencies and must
be within a couple degrees or better depending on the frequency and the antenna used.

Maidenhead is calculated using latitude and longitude which is usually obtained from a map or from
a GPS system output (usually NMEA serial data). Some GPS systems don't provide a direct display of
Maidenhead and many hams are building their own GPS systems (used when locking local oscillators to
GPS atomic clocks) using surplus GPS receivers. The functions contained here are intended to help
the ham to convert NMEA serial data strings containing lat/lon (like $GPRMC) to Maidenhead. The
computed Maidenhead can then be used as inputs to other included functions to compute distance
and bearing to a target location.
  
}}

CON
  _CLKMODE = XTAL1  + PLL16X
  _XINFREQ = 5_000_000

  LATITUDE = 1
  LONGITUDE = 0

OBJ
  FS      : "FloatString"
  FP      : "Float32Full"
  CH      : "CharHelp"
  NM      : "Numbers"

VAR
  byte  mhstr[12]

PUB ValidGrid(stringptr): IsValid | gsz, err
{{
' Convert Maidenhead letters to upper case then checks for validity.
' Returns 1 if valid ZERO otherwise. 

' Maidenhead is in this format (in groups of multiples of two):
'
'                             FN32KP02
'                             ^^^^^^^^
'                             ||||||||
'  1st Longitude Character ---+|||||||
'  1st Latitude Character  ----+||||||
'  2nd Longitude Character -----+|||||
'  2nd Latitude Character  ------+||||
'  3rd Longitude Character -------+|||
'  3rd Latitude Character  --------+||
'  4th Longitude Character ---------+|
'  4th Latitude Character  ----------+ 

}}

  IsValid := 0
  Err := 0

  'Size is either 2, 4, 6 or 8 digits. Anything else is an error.
  gsz := StrSize(stringptr)

  CASE gsz
    2,4:
      byte[stringptr][0] := CH.ToUpper(byte[stringptr][0])
      byte[stringptr][1] := CH.ToUpper(byte[stringptr][1])
    6,8:
      byte[stringptr][0] := CH.ToUpper(byte[stringptr][0])
      byte[stringptr][1] := CH.ToUpper(byte[stringptr][1])
      byte[stringptr][4] := CH.ToUpper(byte[stringptr][4])
      byte[stringptr][5] := CH.ToUpper(byte[stringptr][5])
    Other:
      Err := 1

  if(Err == 0)  
      if(gsz => 2)
        if((CH.IsAlpha(byte[stringptr][0])==1)AND(CH.IsAlpha(byte[stringptr][1])==1))
          IsValid := 1
        else
          IsValid := 0
      if(gsz => 4)
        if((CH.IsDigit(byte[stringptr][2])==1)AND(CH.IsDigit(byte[stringptr][3])==1))     
          IsValid := 1      
        else
          IsValid := 0
      if(gsz => 6)
        if((CH.IsAlpha(byte[stringptr][4])==1)AND(CH.IsAlpha(byte[stringptr][5])==1))     
          IsValid := 1      
        else
          IsValid := 0
      if(gsz == 8)     
        If((CH.IsDigit(byte[stringptr][6])==1)AND(CH.IsDigit(byte[stringptr][7])==1))
          IsValid := 1      
        else
          IsValid := 0
  else
    IsValid := 0    

PUB Distance(src,tar): dist | lt1, ln1, lt2, ln2, F, G, L, sinG2, cosG2, sinF2, cosF2, sinL2, cosL2, S, C, w, R, a, ff, D, H1, H2
{{
' Compute distance between two valid Maidenhead coordinates

' From Astronomical Algorithms by Jean Meeus
' Second Edition
' Willmann-Bell, Inc.
' ISBN 0-943396-61-1
}}

  if((ValidGrid(src)==1) AND (ValidGrid(tar)==1)) 

    'Start the floating point Cog 
    FP.start
     
    lt1 := M2LatLon(src,LATITUDE)
    ln1 := M2LatLon(src,LONGITUDE)
    lt2 := M2LatLon(tar,LATITUDE)
    ln2 := M2LatLon(tar,LONGITUDE)
         
    F := FP.FDiv(FP.FAdd(lt1,lt2),FP.FFloat(2))
    G := FP.FDiv(FP.FSub(lt1,lt2),FP.FFloat(2))
    L := FP.FDiv(FP.FSub(ln1,ln2),FP.FFloat(2))
     
    sinG2 := FP.FMul(FP.sin(G),FP.sin(G))
    cosG2 := FP.FMul(FP.cos(G),FP.cos(G))
    sinF2 := FP.FMul(FP.sin(F),FP.sin(F))
    cosF2 := FP.FMul(FP.cos(F),FP.cos(F))
    sinL2 := FP.FMul(FP.sin(L),FP.sin(L))
    cosL2 := FP.FMul(FP.cos(L),FP.cos(L))
     
    S := FP.FAdd(FP.FMul(sinG2,cosL2),FP.FMul(cosF2,sinL2))
    C := FP.FAdd(FP.FMul(cosG2,cosL2),FP.FMul(sinF2,sinL2))
     
    w := FP.ATan(FP.FSqr(FP.FDiv(S,C)))
    R := FP.FDiv(FP.FSqr(FP.FMul(S,C)),w)
     
    ff := FP.FDiv(1.0,298.257223563)       ' WGS-84 ellipsoid flattening factor
    D := FP.FMul(FP.FMul(2.0,w),6378.137) ' WGS-84 equatorial radius (6378.137)
    H1 := FP.FDiv(FP.FSub(FP.FMul(3.0,R),1.0),FP.FMul(2.0,C))
    H2 := FP.FDiv(FP.FAdd(FP.FMul(3.0,R),2.0),FP.FMul(2.0,S))
     
    dist := FP.FMul(D,FP.FAdd(1.0,FP.FSub(FP.FMul(ff,FP.FMul(H1,FP.FMul(sinF2,cosG2))),FP.FMul(ff,FP.FMul(H2,FP.FMul(cosF2,sinG2))))))
     
    'Stop the floating point Cog 
    FP.stop
  else
    dist := -1.0

     
PUB Bearing(src,tar): bear | lt1, ln1, lt2, ln2, tmp, LL, DD, cosD, CC, cosC
{{
' Compute bearing between two valid Maidenhead coordinates

' From Astronomical Algorithms by Jean Meeus
' Second Edition
' Willmann-Bell, Inc.
' ISBN 0-943396-61-1
}}     

  if((ValidGrid(src)==1) AND (ValidGrid(tar)==1)) 
    'Start the floating point Cog 
    FP.start
     
    lt1 := M2LatLon(src,1)
    ln1 := M2LatLon(src,0)
    lt2 := M2LatLon(tar,1)
    ln2 := M2LatLon(tar,0)
         
    LL := FP.FSub(ln2,ln1)
     
    cosD := FP.FAdd(FP.FMul(FP.sin(lt1),FP.sin(lt2)),FP.FMul(FP.cos(lt1),FP.FMul(FP.cos(lt2),FP.cos(LL))))
     
    DD := FP.acos(cosD)
     
    cosC := FP.FDiv(FP.FSub(FP.sin(lt2),FP.FMul(cosD,FP.sin(lt1))),FP.FMul(FP.sin(DD),FP.cos(lt1)))
     
    if(FP.FCmp(cosC,1.0)> 0)
      cosC := 1.0      
     
    if(FP.FCmp(-1.0,cosC)> 0)
      cosC := -1.0      
     
    CC := FP.FMul(FP.FDiv(180.0,pi),FP.ACos(cosC))
     
    if(FP.sin(LL) < 0.0)
      tmp := FP.FSub(360.0,CC)
    else
      tmp := CC  
     
    bear := tmp
     
    'Stop the floating point Cog 
    FP.stop
  else
    bear := -1.0

PUB NMEACS(nmeastr): ckret | index, sz, cksum, cksum2
{{
' Pass a NMEA string (e.g. $GPRMC) and the function computes the checksum
' and compares it to the checksum on the end of the NMEA sentence. If the
' computed checksum agrees the function returns the checksum otherwise it
' returns ZERO.
' Use this to validate whole NMEA strings.

}}
  index := 1
  cksum := 0
  sz := STRSIZE(nmeastr) 

  repeat
    cksum ^= byte[nmeastr][index]
    index := index + 1
  while ((byte[nmeastr][index] <> "*") AND (index < (sz-2)))  

  'Check the computed checksum against the last two digits of the string after the asterisk
  'If they match return the computed checksum otherwise zero

  if(NM.FromStr(@byte[nmeastr][sz-2],16)==cksum)
    ckret := cksum
  else
    ckret := 0

PUB NMEA2MH(nmeastr, mstr) : str | _lat, _lon, _latm, _lonm, _latm8, _lonm8
{{
' Convert NMEA GPRMC sentence Latitude/Longitude to Maidenhead

'   0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6
'   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7
'  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
'  |$|G|P|R|M|C|,|2|2|3|1|5|9|,|A|,|4|2|2|1|.|5|8|3|5|,|N|,|0|7|3|1|7|.|0|3|4|2|,|W|,|2|.|2|7|3|,|1|9|9|.|0|,|1|0|0|3|0|7|,|1|5|.|0|,|W|4|5|
'  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
}}
  _lat := ((byte[nmeastr][16] - "0") * 10) + (byte[nmeastr][17]-"0")
  _latm := ((byte[nmeastr][18] - "0") * 100) +((byte[nmeastr][19] - "0") * 10)+ (byte[nmeastr][21]-"0") 
  _latm8 := ((byte[nmeastr][19] - "0") * 100) +((byte[nmeastr][21] - "0") * 10)+ (byte[nmeastr][22]-"0") 
  _lon := ((byte[nmeastr][28] - "0") * 100) +((byte[nmeastr][29] - "0") * 10)+ (byte[nmeastr][30]-"0") 
  _lonm := ((byte[nmeastr][31] - "0") * 10)+ (byte[nmeastr][32]-"0") 
  _lonm8 := ((byte[nmeastr][32] - "0") * 100) +((byte[nmeastr][34] - "0") * 10)+ (byte[nmeastr][35]-"0")  

  if(byte[nmeastr][26]=="S")
    _lat := -_lat
  _lat := _lat + 90

  if(byte[nmeastr][39]=="W")
    _lon := -_lon
  _lon := _lon + 180

' ****************
' First character
' ****************
  byte[mstr][0] := "A" + _lon/20
  if(byte[nmeastr][39]=="W")
    if((_lon//20)==0)
      byte[mstr][0] := byte[mstr][0] - 1      

' ****************
' Second character
' ****************
  byte[mstr][1] := "A" + _lat/10
  if(byte[nmeastr][26]=="S")
    if((_lat//10)==0)
      byte[mstr][1] := byte[mstr][1] -1

  _lon := _lon - 180
  _lat := _lat - 90

' ****************
' Third character
' ****************
  if(byte[nmeastr][39]=="W")
    byte[mstr][2] := "9" + ((_lon//20)/2)   '+ OK. Lon is negative when West
  else
    byte[mstr][2] := "0" + ((_lon//20)/2)

' ****************
' Fourth character
' ****************
  if(byte[nmeastr][26]=="N")
    byte[mstr][3] := "0" + (_lat//10)
  else
    byte[mstr][3] := "9" + (_lat//10)       '+ OK. Lat is negative when South

' ****************
' Fifth character
' ****************
  if((_lon//2)==0) 'even
    if(byte[nmeastr][39]=="W")
      byte[mstr][4] := "x" - (_lonm/5)
    else
      byte[mstr][4] := "a" + (_lonm/5)
  else
    if(byte[nmeastr][39]=="W")
      byte[mstr][4] := "l" - (_lonm/5)
    else
      byte[mstr][4] := "m" + (_lonm/5)

' ****************
' Sixth character
' ****************
  if(byte[nmeastr][26]=="N")
    byte[mstr][5] := "a" + (_latm/25)
  else
    byte[mstr][5] := "x" - (_latm/25)

' ****************
' Seventh character
' ****************
  if(byte[nmeastr][39]=="W")
    byte[mstr][6] := "9" - ((_lonm8//500)/50)
  else
    byte[mstr][6] := "0" + ((_lonm8//500)/50)

' ****************
' Eighth character
' ****************
  if(byte[nmeastr][26]=="N")
    byte[mstr][7] := "0" + ((_latm8//250)/25)
  else
    byte[mstr][7] := "9" - ((_latm8//250)/25)

  byte[mstr][8] := 0


PRI M2LatLon(str,mode): rtn | tmp, len
{{  
  Convert Maidenhead (2, 4, 6 or 8 digits) to latitude or longitude
  for use in distance and bearing calculations.

}}

  'Copy input string to a temp string + null at the end
  '(because we're going to screw around with it).
  len := StrSize(str)
  bytefill(@mhstr,0,12)
  bytemove(@mhstr,str,len)

  'Make string into Maidenhead 8  
  Case len 
    2:
      byte[@mhstr][2] := "0"
      byte[@mhstr][3] := "0"
      byte[@mhstr][4] := "A"
      byte[@mhstr][5] := "A"
      byte[@mhstr][6] := "0"
      byte[@mhstr][7] := "0"
    4:
      byte[@mhstr][4] := "A"
      byte[@mhstr][5] := "A"
      byte[@mhstr][6] := "0"
      byte[@mhstr][7] := "0"
    6:
      byte[@mhstr][6] := "0"
      byte[@mhstr][7] := "0"
    8:
    Other:

  tmp := 0.0

  Case mode '0=Lon, 1=Lat
    0:
      tmp := FP.FAdd(tmp,FP.FMul(FP.FFloat(byte[@mhstr][0] - "A"), FP.FFloat(20)))
      tmp := FP.FAdd(tmp,FP.FFloat(-180))
      tmp := FP.FAdd(tmp,FP.FMul(FP.FFloat(byte[@mhstr][2] - "0"),FP.FFloat(2)))
      tmp := FP.FAdd(tmp, FP.FDiv(FP.FMul(FP.FFloat(byte[@mhstr][4] - "A"),FP.FFloat(5)),FP.FFloat(60)))
      tmp := FP.FAdd(tmp,FP.FDiv(FP.FMul(FP.FFloat(byte[@mhstr][6] - "0"),FP.FFloat(30)),FP.FFloat(3600)))
      tmp := FP.FAdd(tmp,FP.FDiv(FP.FFloat(30),FP.FFloat(7200)))      
      Case len 
        2:
          tmp := FP.FAdd(tmp,10.0)
        4:
          tmp := FP.FAdd(tmp,1.0)
        6:
          tmp := FP.FAdd(tmp,FP.FDiv(2.5,60.0))
        8:
          tmp := FP.FAdd(tmp,FP.FDiv(30.0,7200.0))
        Other:
          tmp := FP.FAdd(tmp,0.0)
      tmp := FP.FMul(pi,FP.FDiv(tmp,FP.FFloat(180)))

    1:
      tmp := FP.FAdd(tmp,FP.FMul(FP.FFloat(byte[@mhstr][1] - "A"), FP.FFloat(10)))
      tmp := FP.FAdd(tmp,FP.FFloat(-90))
      tmp := FP.FAdd(tmp,FP.FFloat(byte[@mhstr][3] - "0"))
      tmp := FP.FAdd(tmp, FP.FDiv(FP.FMul(FP.FFloat(byte[@mhstr][5] - "A"),FP.FDiv(FP.FFloat(5),FP.FFloat(2))),FP.FFloat(60)))
      tmp := FP.FAdd(tmp,FP.FDiv(FP.FMul(FP.FFloat(byte[@mhstr][7] - "0"),FP.FFloat(15)),FP.FFloat(3600)))
      tmp := FP.FAdd(tmp,FP.FDiv(FP.FFloat(15),FP.FFloat(7200)))      

      Case len 
        2:
          tmp := FP.FAdd(tmp,5.0)
        4:
          tmp := FP.FAdd(tmp,0.5)
        6:
          tmp := FP.FAdd(tmp,FP.FDiv(1.25,60.0))
        8:
          tmp := FP.FAdd(tmp,FP.FDiv(15.0,7200.0))
        Other:
          tmp := FP.FAdd(tmp,0.0)

      tmp := FP.FMul(pi,FP.FDiv(tmp,FP.FFloat(180)))

  rtn := tmp

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
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
 