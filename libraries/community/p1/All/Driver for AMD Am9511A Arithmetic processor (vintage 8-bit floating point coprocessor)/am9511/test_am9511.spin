{ test_am9511.spin - demo / sample / test code for am9511.spin   }
{ (c) zpekic@hotmail.com 2018 - 2019 - https://github.com/zpekic }

CON
        _clkmode = xtal1 + pll16x  'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
          
OBJ
  fString  : "FloatString"
  am9511   : "Am9511"
  f32Full  : "Float32Full" 

VAR
  long am9511Freq, am9511pi, am9511e
  byte fpuCog
  byte status

' defined here (in main RAM) to be used for POPI* which updates them via global memory pointer
  long dummy, rad, deg2rad, sum, one, sin2, cos2
  long prod
  
PUB Main

  fpuCog := am9511.Start(2_200_000, @CmdAndParams) 'even the slowest 2MHz FPU can be overclocked 10%
  if (fpuCog)
    am9511.AwaitEvalStatus
    am9511.waitForKey(String("FPU initialized, Propeller clkfreq= "), clkfreq)
    am9511.displayValue(String("FPU frequency= "), long[@CmdAndParams][1], fString.FloatToString(am9511.ToIEEE(long[@CmdAndParams][1], @dummy)))
    am9511.displayValue(String("           pi= "), long[@CmdAndParams][2], fString.FloatToString(am9511.ToIEEE(long[@CmdAndParams][2], @dummy)))
    am9511.displayValue(String("            e= "), long[@CmdAndParams][3], fString.FloatToString(am9511.ToIEEE(long[@CmdAndParams][3], @dummy)))
    am9511.displayValue(String(" ln(exp(1.0))= "), long[@CmdAndParams][4], fString.FloatToString(am9511.ToIEEE(long[@CmdAndParams][4], @dummy)))

    f32Full.Start   

    am9511.waitForKey(String("---BENCHMARK---"), 1)
    benchmark1(true)
    benchmark1(false)

    am9511.waitForKey(String("---BENCHMARK---"), 2)
    benchmark2(true, 20)  '21 will cause overflow error, which will be handled properly
    benchmark2(false, 20)

    am9511.Stop
  else
    am9511.waitForKey(String("FPU not initialized, Propeller clkfreq= "), clkfreq)
  
  cogstop(cogid)



PRI benchmark1(useAm9511) :elapsedCycles |degree
  sum := 0
  if (useAm9511)
    am9511.TraceOff
    am9511.StartEval(am9511#PUPI, am9511#PUSHD1, am9511#FDIV, am9511#POPI2, am9511.FromIEEE(180.0, @dummy), @deg2rad, 0, 0)
    am9511.AwaitEvalStatus
    elapsedCycles := cnt
    repeat degree from 0 to 359
      am9511.StartEval(am9511#PUSHD1, am9511#FLTD, am9511#PUSHD2, am9511#FMUL, degree, deg2rad, 0, 0)
      am9511.StartEval(am9511#PTOF, am9511#PTOF, am9511#PTOF, am9511#POPI1, @rad, 0, 0, 0)
      am9511.StartEval(am9511#SIN, am9511#PTOF, am9511#FMUL, am9511#POPI1, @sin2, 0, 0, 0)
      am9511.StartEval(am9511#COS, am9511#PTOF, am9511#FMUL, am9511#POPI1, @cos2, 0, 0, 0)
      am9511.StartEval(am9511#PUSHD1, am9511#PUSHD2, am9511#FADD, am9511#POPI3, sin2, cos2, @one, 0)
      am9511.StartEval(am9511#PUSHD1, am9511#PUSHD2, am9511#FADD, am9511#POPI3, sum, one, @sum, 0)
      'am9511.displayValue(String("rad= "), rad, fString.FloatToString(am9511.ToIEEE(rad, @dummy)))
      'am9511.displayValue(String("sin^2= "), sin2, fString.FloatToString(am9511.ToIEEE(sin2, @dummy)))
      'am9511.displayValue(String("cos^2= "), cos2, fString.FloatToString(am9511.ToIEEE(cos2, @dummy)))
      'am9511.displayValue(String("one= "), one, fString.FloatToString(am9511.ToIEEE(one, @dummy)))
      'am9511.displayValue(String("sum= "), sum, fString.FloatToString(am9511.ToIEEE(sum, @dummy)))
    am9511.AwaitEvalStatus 'wait for all to finish before grabbing final sum!
    elapsedCycles := (cnt - elapsedCycles) / (degree + 1)
    am9511.displayValue(String("Am9511 sum= "), sum, fString.FloatToString(am9511.ToIEEE(sum, @dummy)))
    am9511.waitForKey(String("Cycles per iteration= "), elapsedCycles)
  else
    deg2rad := f32Full.FDiv(pi, f32Full.FFloat(180))
    elapsedCycles := cnt
    repeat degree from 0 to 359
      rad := f32Full.FMul(f32Full.FFloat(degree), deg2rad)
      sin2 := f32Full.FMul(f32Full.Sin(rad), f32Full.Sin(rad))
      cos2 := f32Full.FMul(f32Full.Cos(rad), f32Full.Cos(rad))
      one := f32Full.FAdd(sin2, cos2)
      sum := f32Full.FAdd(sum, one)
    elapsedCycles := (cnt - elapsedCycles) / (degree + 1)
    am9511.displayValue(String("f32Full sum= "), sum, fString.FloatToString(sum))
    am9511.waitForKey(String("Cycles per iteration= "), elapsedCycles)

PRI benchmark2(useAm9511, n) :elapsedCycles| i, st, foi
  if (useAm9511)
    am9511.TraceOff
    am9511.StartEval(am9511#NOOP, am9511#NOOP, am9511#NOOP, am9511#PUSHONE, 0, 0, 0, 0)
    elapsedCycles := cnt
    repeat i from 2 to n
      am9511.StartEval(am9511#PUSHD1, am9511#FLTD, am9511#FMUL, am9511#NOOP, i, 0, 0, 0)
      foi := am9511.GetFailedOperationIndex(st := am9511.AwaitEvalStatus, am9511#ST_ERROR_ANY)
      if (foi => 0)
        am9511.GetStatusMessage(@statusMsg, st.byte[foi])
        am9511.waitForKey(@statusMsg, foi)
        return        
    am9511.StartEval(am9511#PTOF, am9511#POPI1, am9511#POPD2, am9511#NOOP, @prod, 0, 0, 0)
    am9511.AwaitEvalStatus
    elapsedCycles := (cnt - elapsedCycles) / (n - 1)
    am9511.displayValue(String("Am9511 factorial= "), prod, fString.FloatToString(am9511.ToIEEE(prod, @dummy)))
    am9511.waitForKey(String("Cycles per iteration= "), elapsedCycles)
  else
    prod := 1.0
    elapsedCycles := cnt
    repeat i from 2 to n
      prod := f32Full.FMul(prod, f32Full.FFloat(i)) 
    elapsedCycles := (cnt - elapsedCycles) / (n - 1)
    am9511.displayValue(String("f32Full factorial= "), prod, fString.FloatToString(prod))
    am9511.waitForKey(String("Cycles per iteration= "), elapsedCycles)

DAT

' 6 longs in main memory are needed to communicate between main process and cog executing the FPU code
CmdAndParams  long 0[6] '1 command, 4 params, 1 status
' reserve buffer to use for status message
statusMsg     byte 0[64]

{{
'Test numbers from https://archive.org/details/bitsavers_amddataShecessorManual_4528121
'Gives a sample comparison of Am9512 (IEEE754) and Am9511 formats for some values
  am9511.ToIeee(am9511.FromIeee(5.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(5.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(5.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(5.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(5.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(5.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(5.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(5.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(123.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(0.123, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(123.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(12345.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(1.3579, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(0.000012, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(234.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(-1.234, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(0.0006, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(0.006, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(0.06, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(0.6, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(6.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(60.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(600.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(6000.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(456.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(456.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(0.456, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(67890.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(24680.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(340000.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(-678.0, @dummy), @dummy)
  am9511.ToIeee(am9511.FromIeee(12345.0, @dummy), @dummy)
}}  
        