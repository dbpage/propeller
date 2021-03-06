{{────────────────────────────────────────────────────────────────────────────
   File: "Square Wave Cog.spin" (Under Construction.)  

   Numerically controlled oscillator transmits a square wave frequency
   for a specified number of cycles.  

   "Test Square Wave Cog.spin" demonstrates the interface steps below.

   Interface - Parent object must do the following:

     1) Declare three longs in this order: pin, frequency, duration
     2) Declare the object, example: sw : "Square Wave Cog"
     3) Start the object and pass the address of the pin variable
        Example: sw.start(@pin) 
     4) Set the pin and frequency values.
     5) When you want to start transmitting, set the duration variable.
        NOTES:
          duration is in cycles.
          -1 duration does not terminate, but you can still update frequency.
        EXAMPLES: 
          If you want to broadcast for 1/4 s, use duration := frequency / 4.
          If you want to transmit 38 kHz for 1 ms, use frequency := 38000
          and duration := frequency / 1000
     6) Optional, poll duration variable.  When it becomes zero, the
        object is finished transmitting.  
   
   Version: 0.12

   Updated to optional infinite broadcast mode by setting dur to -1.
     
────────────────────────────────────────────────────────────────────────────}}

VAR

  long stack[30], cog                        ' Stack and cog ID
  long addr                                  ' Pin/frequency array address
  long pin, freq, dur                        ' Previous values
  
PUB start(swPinAddr) : okay

  '' Starts the cog.
  addr := swPinAddr                          ' Object coppy of array address
  longmove(@pin, addr, 3)                    ' Copy pin/frequency info
  okay := cog := cognew(updater, @stack) + 1 ' Start cog return 0 if fail

PUB stop

  '' Frees the cog 

  if cog                                      ' Check if running
    cogstop(cog~ - 1)                         ' If running, stop

PRI updater
  repeat                                      ' Main loop for cog
    longmove(@pin, addr, 3)                   ' Copy parent's pin/freq/dur
    if dur <> 0                               ' New freqeuncy request?
      dur--                                   ' Duration starts at 0
      ctra[30..26] := %00100                  ' CTRA -> NCO
      ctrb[30..26] := %01110                  ' CTRB -> Negative edge
      ctra[8..0] := ctrb[8..0] := pin         ' Both modules, same pin
      frqa := calcFrq(freq)                   ' Get FRQA for frequency
      frqb := 1                               ' Neg edge -> PHSB + 1
      if dur <> -2
        phsb := phsa := 0                     ' Clear phases
      dira[pin]~~                             ' Pin to output
      if dur <> -2
        repeat until phsb => dur              ' Cycle counting loop
        waitpeq(0, |< pin, 0)                 ' Make sure pin is zero
        ctra := 0                             ' Stop CTRA module
        dira[pin]~                            ' Make pin an input
        ctrb := frqa := frqb := 0             ' Clear counter modules
        dur := 0                              ' Clear duration
        long[addr][2] := 0                    ' Clear parent's duration var
                                                         
PRI CalcFrq(f)

  {Solve FRQA/B = frequency * (2^32) / clkfreq with binary long
  division (Thanks Chip!).
  
  Note: My version of this method relied on the FloatMath object.
  Not surprisingly, Chip's solution takes a fraction program space,
  memory, and time.  It's the binary long-division approach, which
  implements with the binary
  long division approach.}

  repeat 33                                   ' Binary long-division 
    result <<= 1
    if f => clkfreq
      f -= clkfreq
      result++        
    f <<= 1
  