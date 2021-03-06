{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   One Pin TV Text Driver (C) 2009-07-09 Eric Ball                                            │                                                            
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

VAR
  BYTE cog

PUB start( parmptr )

  stop
  RESULT := COGNEW( @cogstart, parmptr)
  cog := RESULT + 1
  RETURN

PUB stop
   COGSTOP( cog~ - 1 )

DAT
{{
This driver was inspired by the Parallax Forum topic "Minimal TV or VGA pins"
http://forums.parallax.com/forums/default.aspx?f=25&m=340731&g=342216
Where Phil Pilgrim provided the following circuit and description of use:
─┳┳
    
    
"White is logic high; sync, logic low; blank level, CTRB programmed for DUTY
 mode with FRQB set to $4924_0000. The advantage of this over tri-stating for
 the blanking level is that the Propeller's video generator can be used to
 generate the visible stuff while CTRB is active. When the video output is high,
 it's ORed with the DUTY output to yield a high; when low, the DUTY-mode value
 takes over. CTRB is simply turned off during the syncs, which has to be handled
 in software.

 The resistor values (124Ω series, 191Ω to ground) have an output impedance of
 75 ohms and will drive a 75-ohm load at 1V P-P. The cap is there to filter the
 DUTY doody."

However, in my experience, the RC network is not required. I have tested
successfully using any of the Demoboard TV DAC resistors (although the higher
resistance yields darker text) and with no resistors at all (although this
is not recommended).

Driver limitation details:
CLKFREQ => 12MHz
op_cols =< CLKFRQ / 1.2MHz (LSB) | CLKFREQ / 1.3MHz (MSB)
op_cols * pixels/char => 45
op_pixelclk => 1MHz

Q: Why specify op_pixelclk?
A1: To reduce shimmer caused by the number of significant bits in FRQA.
A2: To allow for WAITVID timing experimentation.
A3: To reduce horizontal overscan & display more characters per line.

Q: Why specify op_blankfrq?
A1: To tune the brightness of the text for a particular display.
A2: To allow for light/dark pulsing text. (Red Alert!!)

Q: Why specify pixels/char <> 8?
A1: To allow for fonts thinner than 8 pixels to be displayed.
A2: To allow for blank pixels between characters (i.e. hexfont.spin)

Q: Why not fonts with vertical sizes <> 8?
A: It probably can be done, but would require a chunk of time-sensitive
   code to be re-written.

Q: Why fewer characters per line for MSB first fonts?
A: MSB first fonts require one more instruction in a timing sensitive loop.    

Q: Why is pixels/char embedded in op_mode rather than a separate long?
A1: It's an optional parameter.  op_mode := 1 | 2 will be the norm.
A2: It started as a 1 bit parameter for 9 pixel wide characters, but then
    grew into a nibble.
    
}}
                        ORG     0
cogstart
                        RDLONG  i_mode, PAR            WZ
           IF_Z         JMP     @cogstart
                        
                        MOV     taskptr, #taskone
                        MOV     rownum, #8
:dotasks                JMPRET  taskptr, taskptr
                        DJNZ    rownum, #:dotasks

frame                   MOV     taskptr, #taskone
                        MOV     rownum, oequal1
                        CALL    #equalizing
                        MOV     rownum, oserr          ' serration pulses
:loop                   MOV     VSCL, osynch           ' serration pulse (long)
                        WAITVID FFOO, #0               
                        MOVI    CTRB, #0               ' turn off blank
                        MOV     VSCL, osync            ' serration pulse (short)
                        WAITVID FFOO, #0
                        MOVI    CTRB, #%0_00110_000    ' turn on blank
                        DJNZ    rownum, #:loop
                        MOV     rownum, oequal2
                        CALL    #equalizing

                        MOV     rownum, oblank1
                        CALL    #doblank

                        MOV     rownum, oactive
                        MOV     charptr, i_charptr      ' initialize character pointer
doactive                MOVS    VSCL, osync             ' 4.7uSec @ -40 IRE
                        WAITVID FFOO, #0
                        MOVI    CTRB, #0                ' turn off blank
                        TEST    i_mode, #1<<2   WC      ' line double mode
        IF_C            TEST    rownum, #15     WZ      ' 16 lines per row
        IF_NC           TEST    rownum, #7      WZ      ' 8 lines per row
        IF_Z            MOV     fontptr, i_fontptr      ' reset fontptr if required
        IF_NZ           SUB     charptr, i_cols         ' reset charptr if required
        IF_C            TEST    rownum, #1      WC      ' double line
        IF_NZ_AND_NC    ADD     fontptr, #1             ' advance to next line
                        MOV     count, i_cols           ' characters per line
                        MOVS    VSCL, obackp            ' back porch
                        TEST    i_mode, #1<<3   WC      ' LSB or MSB first font
        IF_C            JMP     #:doactive              ' MSB first font

                        WAITVID FFOO, #0
                        MOVI    CTRB, #%0_00110_000     ' turn on blank
                        MOV     VSCL, ovsclch           ' 1 PLLA per pixel, 8 PLLA per frame
:evitca                 RDBYTE  char, charptr           ' read character from HUB RAM
                        SHL     char, #3                ' 8 bytes per character bitmap               
                        ADD     char, fontptr           ' add base address + line offset
                        RDBYTE  char, char              ' read character bitmap from HUB RAM
                        ADD     charptr, #1             ' next character
                        WAITVID FFOO, char              ' output to screen
                        DJNZ    count, #:evitca         ' do entire line
                        MOV     VSCL, ofrontp           ' front porch
                        WAITVID FFOO, #0                ' output blank
                        DJNZ    rownum, #doactive       ' next row
                        MOV     VSCL, osync             ' 4.7uSec @ -40 IRE
                        WAITVID FFOO, #0
                        MOVI    CTRB, #0                ' turn off blank
                        JMP     #:blank

:doactive               WAITVID FFOO, #0
                        MOVI    CTRB, #%0_00110_000     ' turn on blank
                        MOV     VSCL, ochrev            ' 1 PLLA per pixel, 8 PLLA per frame
:active                 RDBYTE  char, charptr           ' read character from HUB RAM
                        SHL     char, #3                ' 8 bytes per character bitmap
                        ADD     char, fontptr           ' add base address + line offset
                        RDBYTE  char, char              ' read character bitmap from HUB RAM
                        ADD     charptr, #1             ' next character
                        REV     char, ochrev            ' msb of byte first
                        WAITVID FFOO, char              ' output to screen
                        DJNZ    count, #:active         ' do entire line
                        MOV     VSCL, ofrontp           ' front porch
                        WAITVID FFOO, #0                ' output blank
                        DJNZ    rownum, #doactive       ' next row
                        MOV     VSCL, osync             ' 4.7uSec @ -40 IRE
                        WAITVID FFOO, #0
                        MOVI    CTRB, #0                ' turn off blank
:blank                  MOV     rownum, oblank2
                        JMPRET  doblank_ret, #doblank2
                        JMP     #frame

equalizing              MOV     VSCL, oequal            ' equalizing pulse (short)
                        WAITVID FFOO, #0
                        MOVI    CTRB, #0                ' turn off blank
                        MOV     VSCL, oequalh           ' equalizing pulse (long)
                        WAITVID FFOO, #0
                        MOVI    CTRB, #%0_00110_000     ' turn on blank
                        JMPRET  taskptr, taskptr
                        DJNZ    rownum, #equalizing
equalizing_ret          RET

doblank                 MOV     VSCL, osync             ' 4.7uSec @ -40 IRE
                        WAITVID FFOO, #0
                        MOVI    CTRB, #0                ' turn off blank
doblank2                MOV     VSCL, osynch            ' blank line
                        WAITVID FFOO, #0
                        MOVI    CTRB, #%0_00110_000     ' turn on blank
                        MOV     VSCL, ohalf
                        WAITVID FFOO, #0
                        DJNZ    rownum, #doblank
doblank_ret             RET

' Each task is max 300 CLK in oequalh for min CLKFREQ of 12MHz 

taskone                 MOV     charptr, PAR           ' load input parameters 280 CLK
                        MOVD    :i_loop, #i_mode
                        MOV     count, #8
:i_loop                 RDLONG  i_mode, charptr
                        ADD     charptr, #4
                        ADD     :i_loop, d1
                        DJNZ    count, #:i_loop

                        MOV     i_mode, i_mode         WZ
        IF_Z            JMP     #standby

                        JMPRET  taskptr, taskptr       

                        TEST    i_mode, #2             WC ' load NTSC/PAL parms 156 CLK
        IF_C            MOVS    :np_loop, #pcolsfrq
        IF_NC           MOVS    :np_loop, #ncolsfrq
                        MOVD    :np_loop, #ocolsfrq
                        MOV     count, #11
:np_loop                MOV     ocolsfrq, ncolsfrq
                        ADD     :np_loop, d1s1
                        DJNZ    count, #:np_loop

                        MOV     ovsclch, i_mode        ' pixels per character 118 CLK
                        SHR     ovsclch, #8
                        AND     ovsclch, #15           WZ
        IF_Z            MOV     ovsclch, #8            ' default value
                        MOV     ochrev, #32
                        SUB     ochrev, ovsclch
                        MOV     mulin1, ovsclch
                        MOV     mulin2, i_cols
                        JMPRET  pelmult_ret, #pelmult2
                        MOV     overscan, mulout       ' save # active pixels

                        JMPRET  taskptr, taskptr

                        TEST    i_mode, #1<<6          WC ' calculate i_pixelclk 156 CLK
                        MOV     ofrqa, i_pixelclk      WZ
        IF_C_AND_NZ     JMP     #:calcfrqa             ' use provided i_pixelclk
                        MOV     mulin1, mulout
                        MOV     mulin2, ocolsfrq
                        JMPRET  pelmult_ret, #pelmult2
                        MOV     i_pixelclk, mulout
                        MOV     ofrqa, i_pixelclk
        
:calcfrqa               MOV     ifrqa, #0              ' calculate PLL divisor 64 CLK
                        MOV     ictra, #%0_00001_011   ' PLL internal mode, 1x PLLA
:shrfreq                CMP     ofrqa, maxfreq         WC
        IF_C            JMP     #:shlfreq
                        SHR     ofrqa, #1              WC
                        RCR     ifrqa, #1
                        ADD     ictra, #1
                        JMP     #:shrfreq
:shlfreq                CMP     ofrqa, minfreq         WC
        IF_C            SHL     ofrqa, #1
        IF_C            SUB     ictra, #1
        IF_C            JMP     #:shlfreq

                        RDLONG  mulout, #0             ' CLKFREQ 20 CLK

                        JMPRET  taskptr, taskptr

:shmax                  SHL     ifrqa, #1              WC ' maximize the two values 132 CLK
                        RCL     ofrqa, #1
                        SHL     mulout, #1             WC
        IF_NC           JMP     #:shmax
                        RCR     mulout, #1             ' undo overshoot

                        MOV     count, #10             ' 10 bits of division 168 CLK
:div1                   CMPSUB  ofrqa, mulout          WC
                        RCL     ifrqa, #1
                        SHR     mulout, #1
                        DJNZ    count, #:div1

                        JMPRET  taskptr, taskptr

                        MOV     count, #18             ' 18 bits of division 300 CLK
:div2                   CMPSUB  ofrqa, mulout          WC
                        RCL     ifrqa, #1
                        SHR     mulout, #1
                        DJNZ    count, #:div2
                        SHL     ifrqa, #4              ' skip the last 4 bits

                        JMPRET  taskptr, taskptr

                        MOV     mulin1, ohalf          ' calc number of PLLA 280 CLK
                        CALL    #pelmult
                        SHR     mulout, #23
                        MOV     ohalf, mulout
                        MOV     mulin1, ofrontp
                        CALL    #pelmult
                        SHR     mulout, #24
                        MOV     ofrontp, mulout

                        JMPRET  taskptr, taskptr
                        
                        MOV     mulin1, obackp         ' calc number of PLLA 276 CLK
                        CALL    #pelmult
                        SHR     mulout, #24
                        MOV     obackp, mulout
                        MOV     mulin1, otsync
                        CALL    #pelmult
                        SHR     mulout, #23            ' don't save, do all at once

                        JMPRET  taskptr, taskptr

                        MOV     osync, mulout          ' final calculations 284 CLK

                        MOV     oequal, osync
                        SHR     oequal, #1

                        MOV     osynch, ohalf
                        SUB     osynch, osync
                        MOV     oequalh, ohalf
                        SUB     oequalh, oequal

                        MOV     mulout, overscan       ' number of active pixels
                        MOV     overscan, ohalf
                        SHL     overscan, #1
                        SUB     overscan, obackp
                        SUB     overscan, ofrontp
                        SUB     overscan, osync
                        SUB     overscan, mulout       WC, WZ
        IF_C            MOV     overscan, #0           WZ
                        SHR     overscan, #1           WC
        IF_NZ           ADD     obackp, overscan
        IF_NZ           ADDX    ofrontp, overscan

                        MOVD    :addbase, #ohalf        ' add 1<<12 to vscl values
                        MOV     count, #8
:addbase                ADD     ohalf, vsclbase
                        ADD     :addbase, d1
                        DJNZ    count, #:addbase

                        MOV     overscan, oactive
                        MOV     oactive, i_rows
                        TEST    i_mode, #1<<2          WC
        IF_C            SHL     oactive, #4                        
        IF_NC           SHL     oactive, #3
                        SUB     overscan, oactive      WC
                        SHR     overscan, #1
        IF_NC           ADD     oblank1, overscan
        IF_NC           ADD     oblank2, overscan

                        MOVI    CTRA, ictra
                        MOV     FRQA, ifrqa

                        MOVS    CTRB, i_pin             ' set pin
                        MOV     count, #1
                        SHL     count, i_pin
                        MOV     DIRA, count             ' set pin mask
                        MOV     count, i_pin
                        SHR     count, #3
                        MOVD    VCFG, count             ' set VGroup
                        MOV     count, #1
                        AND     i_pin, #7
                        SHL     count, i_pin
                        MOVS    VCFG, count             ' set VPins
                        MOVI    VCFG, #%0_01_0_0_0_000  ' VGA mode, 1 bit per pixel

                        TEST    i_mode, #1<<7    WC
                        MOV     FRQB, i_blankfrq WZ
        IF_NC_OR_Z      MOV     FRQB, ifrqb             ' default = 40/140

lasttask                JMPRET  taskptr, taskptr
                        JMP     #lasttask

standby                 MOV     DIRA, #0
                        MOV     VCFG, #0
                        MOV     CTRA, #0
                        MOV     CTRB, #0
                        JMP     #cogstart

pelmult                 MOV     mulin2, i_pixelclk
pelmult2                MOV     mulout, #0
:mulloop                SHR     mulin1, #1      WC,WZ
        IF_C            ADD     mulout, mulin2
                        SHL     mulin2, #1
        IF_NZ           JMP     #:mulloop
pelmult_ret             RET

d1                      LONG    1<<9                   ' destination = 1
d1s1                    LONG    1<<9+1                 ' destination = 1 source = 1
FFOO                    LONG    $FF00                  ' white / black
vsclbase                LONG    1<<12                  ' 1 PLLA per pixel
minfreq                 LONG    4_000_000              ' minimum PLL frequency
maxfreq                 LONG    8_000_001              ' maximum PLL frequency
ifrqb                   LONG    $4924_0000             ' 40/140 << 32

ncolsfrq                LONG    22_478                 ' NTSC parameters
nequal1                 LONG    6
nserr                   LONG    6
nequal2                 LONG    6
nblank1                 LONG    12
nactive                 LONG    240
nblank2                 LONG    1
nsync                   LONG    39                     ' 4.7usec << 23
nhalf                   LONG    267                    ' 31.777usec << 23
nbackp                  LONG    75                     ' 4.5usec << 24
nfrontp                 LONG    25                     ' 1.5usec << 24

pcolsfrq                LONG    22_321                 ' PAL parameters
pequal1                 LONG    4
pserr                   LONG    5
pequal2                 LONG    5
pblank1                 LONG    15
pactive                 LONG    288
pblank2                 LONG    1
psync                   LONG    39                     ' 4.7usec << 23
phalf                   LONG    268                    ' 32usec << 23
pbackp                  LONG    97                     ' 5.8usec << 24
pfrontp                 LONG    25                     ' 1.5usec << 24

ocolsfrq                RES     1                      ' Hz per active pixel
oequal1                 RES     1                      ' number of equalization pulses
oserr                   RES     1                      ' number of serration pulses
oequal2                 RES     1                      ' number of equalization pulses
oblank1                 RES     1                      ' number of blank lines
oactive                 RES     1                      ' number of active lines
oblank2                 RES     1                      ' number of blank lines
otsync                  RES     1                      ' temp sync pulse
ohalf                   RES     1                      ' VSCL half line
obackp                  RES     1                      ' VSCL back porch (sync to active)
ofrontp                 RES     1                      ' VSCL front porch (active to sync)
oequal                  RES     1                      ' VSCL equalization pulse (sync/2)
osync                   RES     1                      ' VSCL sync pulse
osynch                  RES     1                      ' VSCL half-sync
oequalh                 RES     1                      ' VSCL half-equal
ovsclch                 RES     1                      ' VSCL character
ochrev                  RES     1                      ' bits to reverse
                                                       
overscan                RES     1

ofrqa                   RES     1                      ' desired CTRA frequency
ifrqa                   RES     1                      ' required FRQA value
ictra                   RES     1                      ' CTRA with PLLdiv

mulin1                  RES     1                      ' small value
mulin2                  RES     1                      ' large value / i_pixelclk
mulout                  RES     1                      ' mulin1 * mulin2

char                    RES     1                      ' current character / character bitmap
charptr                 RES     1                      ' pointer to current character
fontptr                 RES     1                      ' base address + line offset
count                   RES     1                      ' all purpose counter
rownum                  RES     1                      ' row counter

taskptr                 RES     1

'' one pin input parameters - 8 contiguous longs       
i_mode                  RES     1                       '' mode 0 = inactive
                                                        ''   [1..0] 1 = NTSC(262@60), 2 = PAL (312@50)
                                                        ''   [2] 0 = single line res, 1 = double line res
                                                        ''   [3] 0 = lsb first font, 1 = msb first font (slower)
                                                        ''   [6] 0 = default pixel clock, 1 = use op_pixelclk
                                                        ''   [7] 0 = default blank duty, 1 = use op_blankfrq
                                                        ''   [11..8] pixels per character 0 = default (8)
i_pin                   RES     1                       '' pin number
i_charptr               RES     1                       '' pointer to screen (bytes)
i_fontptr               RES     1                       '' pointer to font (8 bytes/char)
i_cols                  RES     1                       '' number of columns
i_rows                  RES     1                       '' number of rows
i_pixelclk              RES     1                       '' pixel clock frequency (Hz) 0=auto
i_blankfrq              RES     1                       '' blank duty counter 0=default

{
Technote on video drivers

Video drivers are constrained by WAITVID to WAITVID timing.  In the inner
active display loop (e.g. :active / :evitca), this determines the maximum
resolution at a given clock frequency.  Other WAITVID to WAITVID intervals
(e.g. front porch) determine the minimum clock frequency.
}