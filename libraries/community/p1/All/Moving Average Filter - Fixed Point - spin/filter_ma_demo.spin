{{ filter_ma_demo.spin
┌─────────────────────────────────────┬────────────────┬─────────────────────┬───────────────┐
│ Moving Average Filter demo v1.0     │ BR             │ (C)2010             │  6 Nov 2010   │
├─────────────────────────────────────┴────────────────┴─────────────────────┴───────────────┤
│                                                                                            │
│ Demo of moving average integer math filter                                                 │
│       •4-point moving average filter                                                       │
│       •16-point moving average filter                                                      │
│                                                                                            │
│ pst setup to use PLX-DAQ (enables easy plot of raw data vs filtered output).    To         │
│ download PLX-DAQ, go to Parallax basic stamp software downloads page.  PLX-DAQ rocks.      │
│ Demo calculates filter frequency response via direct simulation with the help of the       │
│ prop's built-in math tables and a handy sin function courtesy of Ariba.  It also simulates │
│ filter impulse response and step response.                                                 │
│                                                                                            │
│ See end of file for terms of use.                                                          │
└────────────────────────────────────────────────────────────────────────────────────────────┘
}}


CON
  _clkmode        = xtal1 + pll16x    ' System clock → 80 MHz
  _xinfreq        = 5_000_000

  
OBJ   
    pst   : "Parallax Serial Terminal"
    filter: "filter_ma"   

  
PUB Init

  waitcnt(clkfreq * 5 + cnt)
  pst.Start(57600)
  pst.Str(String("MSG,Initializing...",13))
  pst.Str(String("LABEL,x_meas,x_filt,ticks,bwidth",13))
  pst.Str(String("CLEARDATA",13))
  main


Pub Main| iter, mark, value, xmeas, xfilt, ticks, random
'======================================================
'Filter response to sinusoidal inputs (poor man's Bode)
'======================================================
mark := random := cnt
repeat  iter from 1 to 40 step 2                 'simulate 20 frequencies, highest frequency is nearly Nyquist freq
  repeat value from 0 to 359 step 4              'take 90 samples per frequency
    mark += clkfreq/50                           'output data at 32 samples/sec
    pst.Str(String("DATA, "))                    'data header for PLX-DAQ
    xmeas := sin(value*iter,200)                 'thanks Ariba
'   xmeas += iter * random? >> 28                'add some noise to the measurements
    ticks := cnt

    xfilt := filter.ma4(xmeas)                   'choose your poison
'   xfilt := filter.ma16(xmeas)

    ticks := cnt - ticks
    pst.Dec(xmeas)
    pst.Str(String(", "))
    pst.Dec(xfilt)
    pst.Str(String(", "))
    pst.Dec(ticks)
    pst.Str(String(", "))
    pst.Dec(clkfreq/ticks)
    pst.Str(String(13))
    waitcnt(mark)                                'wait for it...

'=================================
'Filter impulse and step responses
'=================================
mark := random := cnt
repeat  iter from 1 to 150                      
    mark += clkfreq/50                           
    pst.Str(String("DATA, "))                    
    if iter < 50
      xmeas := 0                                      'let the filter chill for a moment....
    elseif iter < 100
      xmeas := impulse_fun(iter, 51, 200)             'input impulse function
    else
      xmeas := step_fun(iter,101,200)                 'input step function

    xfilt := filter.ma4(xmeas)                   
'   xfilt := filter.ma16(xmeas)

    pst.Dec(xmeas)
    pst.Str(String(", "))
    pst.Dec(xfilt)
    pst.Str(String(", "))
    pst.Dec(ticks)
    pst.Str(String(", "))
    pst.Dec(clkfreq/ticks)
    pst.Str(String(13))
    waitcnt(mark)                                


PUB sin(degree, mag) : s | c,z,angle
''Returns scaled sine of an angle: rtn = mag * sin(degree)
'Function courtesy of forum member Ariba
'http://forums.parallax.com/forums/default.aspx?f=25&m=268690

  angle //= 360
  angle := (degree*91)~>2 ' *22.75
  c := angle & $800
  z := angle & $1000
  if c
    angle := -angle
  angle |= $E000>>1
  angle <<= 1
  s := word[angle]
  if z
    s := -s
  return (s*mag)~>16       ' return sin = -range..+range


pub impulse_fun(i,trigger,mag):x_rtn
''Returns impulse function. i = current sample index
''                          trigger = sample index on which impulse is triggered
''                          mag = magnitude of impulse
    if i==trigger
      return mag
    else
      return 0


pub step_fun(i,trigger,mag):x_rtn
''Returns step function. i = current sample index
''                       trigger = sample index on which step is triggered
''                       mag = magnitude of impulse
    if i < trigger
      return 0
    else
      return mag

      