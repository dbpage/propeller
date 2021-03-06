'' ===========================================================================
''  VGA High-Res Text UI Elements Base UI Support Functions  v1.2
''
''  File: RadioCheck.spin
''  Author: Allen Marincak
''  Copyright (c) 2009 Allen MArincak
''  See end of file for terms of use
'' ===========================================================================
''
''============================================================================
'' Button Control
''============================================================================
''
'' Creates Radio Buttons or Check Boxes
''

VAR
  word varGdx         'GUI control variable
  long varScreenPtr   'screen buffer pointer
  long varVgaPos      'start location of the button
  byte varTextN[16]   'normal text, 15 chars MAX, with room for terminating Null
  byte varTextI[16]   'inverted text, 15 chars MAX, with room for terminating Null
  byte varRow         'top row location
  byte varCol         'left col location
  byte varCol2        'right col location
  byte varWidth       'width of text
  byte varStatus      'status byte 0 = none    1 = active
  byte varSelChar     'selected character
  byte varUnselChar   'unselected character
  byte varVgaCols     'width of screen in columns


PUB Init( pRow, pCol, pTextWidth, pStyle, pTextPtr, pVgaPtr, pVgaWidth ) | strIdx, vgaIdx

  varVgaCols    := pVgaWidth
  varStatus     := 0
  varRow        := pRow
  varCol        := pCol
  varWidth      := pTextWidth
  varScreenPtr  := pVgaPtr       
  varVgaPos     := varRow * varVgaCols + varCol  
  varCol2       := varCol + varWidth + 1
  
  if pStyle == 0
    varSelChar      := 7                        'CheckBox Style
    varUnselChar    := 6
  else
    varSelChar      := 5                        'Radio Button Style
    varUnselChar    := 4
  
  strIdx := strsize( pTextPtr )
  bytemove( @varTextN, pTextPtr, strIdx )       'copy checkbox text string
  bytefill(@varTextN[strIdx],32,pTextWidth-strIdx) 'pad out with spaces
  varTextN[pTextWidth] := 0
  strIdx := 0
  repeat pTextWidth
    varTextI[strIdx] := varTextN[strIdx]+128    'create inverted string
    strIdx++    
  varTextI[strIdx] := 0
 
  vgaIdx := varVgaPos                           'now draw the checkbox
 
  byte[varScreenPtr][vgaIdx++] := varUnselChar  'empty bullet
  byte[varScreenPtr][vgaIdx++] := 32

  strIdx := strsize( @varTextN )                               
  bytemove( @byte[varScreenPtr][vgaIdx], @varTextN, strIdx )
  
  
PUB DrawText( pMode ) | strIdx, vgaIdx

  strIdx := strsize( @varTextN )
  vgaIdx := varVgaPos                           'bullet location

  if varStatus == 1
    byte[varScreenPtr][vgaIdx] := varSelChar    'selected bullet
  else
    byte[varScreenPtr][vgaIdx] := varUnselChar  'non-selected bullet

  vgaIdx += 2                                   'checkbox text location
 
  if pMode & 1
    bytemove( @byte[varScreenPtr][vgaIdx], @varTextI, strIdx )
  else  
    bytemove( @byte[varScreenPtr][vgaIdx], @varTextN, strIdx )
 


PUB IsIn( pCx, pCy ) | retVal

  retVal := false

    if ( pCx => varCol ) AND ( pCx =< varCol2 )
      if pCy == varRow 
        retVal := true

  return retVal


PUB Select( pSel )

  if pSel <> -1
    varStatus := pSel
  else
    if varStatus == 0
      varStatus := 1
    else
      varStatus := 0

  if varStatus == 1
    byte[varScreenPtr][varVgaPos] := varSelChar   'selected bullet
  else
    byte[varScreenPtr][varVgaPos] := varUnselChar 'non-selected


PUB IsSet
  if varStatus == 1
    return true
  else
    return false


PUB set_gzidx( gzidx )
  varGdx := gzidx


PUB get_gzidx
  return varGdx

  
{{
┌────────────────────────────────────────────────────────────────────────────┐
│                     TERMS OF USE: MIT License                              │                                                            
├────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy│
│of this software and associated documentation files (the "Software"), to    │
│deal in the Software without restriction, including without limitation the  │
│rights to use, copy, modify, merge, publish, distribute, sublicense, and/or │
│sell copies of the Software, and to permit persons to whom the Software is  │
│furnished to do so, subject to the following conditions:                    │
│                                                                            │
│The above copyright notice and this permission notice shall be included in  │
│all copies or substantial portions of the Software.                         │
│                                                                            │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  │
│IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    │
│FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE │
│AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     │
│FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS│
│IN THE SOFTWARE.                                                            │
└────────────────────────────────────────────────────────────────────────────┘
}}   