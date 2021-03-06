{{
─────────────────────────────────────────────────
File: Wifly Serial Terminal V01.spin
Version: 01.0
Copyright (c) 2012 Ben.Thacker.Enterprises
See end of file for terms of use.

Author: Ben Thacker  
─────────────────────────────────────────────────
}}

{    
  Theory of operation:
  The Propeller chip interfaces with a RN-XV Wifly via the serial
  port. The RN-XV Wifly provides Wi-Fi connectivity using 802.11 b/g
  standards. In this simple configuration that I am using, the RN-XV
  hardware only requires four connections (Pwr, Tx, Rx and Gnd)
  to create a wireless data connection.

  Type $$$ in your terminal emulator to enter comand mode of RN-XV Wifly
  and the Wifly should return CMD.
  See the RN-XV Wifly user manual for valid commands to test and program
  your RN-XV Wifly.
  
 ======================================================================
  Hardware:  
  
  RN-XV
  Wifly                 Propeller                Terminal/PC                 

  +3.3V
  Gnd
              10Ω
   rx   <──────────<  rn_xv_tx
   tx   >──────────>  rn_xv_rx
                        term_rx   <────────────<  prop_plug_tx
                        term_tx   >────────────>  prop_plug_rx
}

'----------------------------------------------------------------------
CON

  _clkmode         = xtal1 + pll16x              'Use crystal * 16
  _xinfreq         = 5_000_000                   '5MHz * 16 = 80 MHz

  term_rx           = 27                         'Serial Rx line
  term_tx           = 26                         'Serial tx line
  rn_xv_rx          =  9                         'RN-XV serial Rx line
  rn_xv_tx          =  8                         'RN-XV serial tx line

  LF                = 10                         'Line Feed
  CR                = 13                         'Carrage Return

'----------------------------------------------------------------------
OBJ

  RN_XV: "Parallax Serial Terminal Extended"
  Term:  "Parallax Serial Terminal Extended"

'----------------------------------------------------------------------
VAR

  long XBStack[50]                               '200 bytes stack space for new cog                                        
  long PCStack[50]                               '200 bytes stack space for new cog                                        
  
'----------------------------------------------------------------------
PUB Main

  RN_XV.StartRxTx( rn_xv_rx, rn_xv_tx, 0, 9600 ) 'initialize RN-XV serial io
  Term.StartRxTx( term_rx, term_tx, 0, 9600 )    'initialize term serial io

  Term.Str(@AppHeader)                           'Print info header from string in DAT section.
  Term.Str(String("*** Starting ***",LF,CR))

  cognew(Wifly_to_Term,@PCStack)                 'Send Wifly Tx to Term Rx
  cognew(Term_to_Wifly,@XBStack)                 'Send Term Tx to Wifly Rx

  repeat                                         'Do nothing forever

'----------------------------------------------------------------------
PUB Wifly_to_Term                                'Continually send Wifly Tx to Term Rx

    RN_XV.rxFlush
    repeat
        Term.Char(RN_XV.CharIn)

'----------------------------------------------------------------------
PUB Term_to_Wifly                                'Continually send Term Tx to Wifly Rx 

    Term.rxFlush
    repeat
        RN_XV.Char(Term.CharIn)

'----------------------------------------------------------------------
DAT

  AppHeader byte  CR,LF,"Wifly Serial Terminal V01.spin is Alive",CR,LF,0

{{

┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │                                            │
│                                                                                      │                                               │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │                                                │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}