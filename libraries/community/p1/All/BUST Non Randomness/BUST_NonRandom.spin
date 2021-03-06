{{
┌───────────────────────────────┬───────────────────┬────────────────────┐
│    BUST_NonRandom.spin v2.0   │ Author: I.Kövesdi │  Rel.: 17.10.2011  │
├───────────────────────────────┴───────────────────┴────────────────────┤
│                    Copyright (c) 2011 CompElit Inc.                    │               
│                   See end of file for terms of use.                    │               
├────────────────────────────────────────────────────────────────────────┤
│  Battery of Useful Statistical Tests (BUST) to check Random Number     │
│ Generators. Here the True Random Number Generator of the SPIN_TrigPack │                                                                     │ │
│ object is verified. This TRNG is written in SPIN only. This application│
│ uses the SPIN_TrigPack for its fixed-point calculations, as well.      │
│                                                                        │
├────────────────────────────────────────────────────────────────────────┤
│ Background and Detail:                                                 │
│  The behaviour of the tested RNG is compared with the mathematically   │
│ ideal one. A perfect generator fails in 5% of the trials in the applied│
│ tests. 5 such independent tests are groupped, so the probability, that │
│ a perfect generator passes all those 5 test is 0.95^5 = 0.774. Hundred │
│ salvos of those 5 tests are fired. When the tested generator fails     │
│ about 23 +-6 from 100 repetition of those test groups, it can be taken │
│ as a good random number generator. In other words, it performs like a  │
│ perfect RNG with the given set of tests. Better is to measure the      │
│ confidence interval of the fails by running this program at least 10   │
│ times and by calulating the average and standard deviation of the      │
│ fails. When the                                                        │
│                                                                        │
│            average +/- 0.4 * standard deviation includes 22.6          │
│                                                                        │
│ then the tested generator can be regarded as a good one with 95% of    │
│ confidence.                                                            │
│                                                                        │
├────────────────────────────────────────────────────────────────────────┤
│ Note:                                                                  │
│  With randomness you can be never sure.                                │
│                                                                        │ 
└────────────────────────────────────────────────────────────────────────┘
}}


CON

_CLKMODE         = XTAL1 + PLL16x
_XINFREQ         = 5_000_000


'Note that following constants are in Qs15.16 Fixed-point Qvalue format
_QH              = 1 << 15
_Q1              = 1 << 16
_Q2              = 2 << 16
_Q3              = 3 << 16
_Q4              = 4 << 16
_Q5              = 5 << 16
_Q6              = 6 << 16
_Q7              = 7 << 16
_Q8              = 8 << 16
_Q9              = 9 << 16
_Q10             = 10 << 16
_Q100            = 100 << 16

'Chi-squared constants for homogenity test
_C1              = 101 << 16
_C2              = 201 << 16
_C3              = 301 << 16
_C4              = 401 << 16
_C5              = 501 << 16
_C6              = 601 << 16
_C7              = 701 << 16
_C8              = 801 << 16
_C9              = 901 << 16

'Benford's law constants
'They come from Benford's Law for Ratios of Random Numbers
'
'              p(d)=(5/90)*(1+(10/(d*(d+1)))
'
'where d is the value of the leading digit
_B1              = 333 << 16
_B2              = 148 << 16
_B3              = 102 << 16
_B4              = 83 << 16
_B5              = 74 << 16
_B6              = 69 << 16
_B7              = 65 << 16
_B8              = 63 << 16
_B9              = 62 << 16

 
VAR

LONG  rnds[1000]       'To store sequence of 1000 random numbers
LONG  flag[1000]       'Work memory area of tests 

LONG  testStat         'To hold test statistics
LONG  mvF
LONG  raF
LONG  rtF
LONG  chF
LONG  bfF  


OBJ

'PST----------------------------------------------------------------------
PST        : "Parallax Serial Terminal"  'From Parallax Inc. v1.0

'SPIN TrigPack -----------------------------------------------------------
Q          : "SPIN_TrigPack"             'From CompElit Ltd. v2.0


PUB Start_Application | cntr, fail, failed, f
'-------------------------------------------------------------------------
'--------------------------┌───────────────────┐--------------------------
'--------------------------│ Start_Application │--------------------------
'--------------------------└───────────────────┘--------------------------
'-------------------------------------------------------------------------
''     Action: - Loads PST driver
''             - Initialises SPIN_TrigPack driver 
''             - Runs group of 5 tests 100 times
''             - Evaluates results  
'' Parameters: None                                 
''     Result: None                    
''+Reads/Uses: - PST CONs                         (OBJ/CON/LONGs)
''             - mvf, raF, rtF, chF, bfF          (VAR/LONG)
''    +Writes: - mvf, raF, rtF, chF, bfF          (VAR/LONG) 
''      Calls: Parallax Serial Terminal---------->PST.Star
''                                                PST.Char
''                                                PST.Str
''                                                PST.Dec
''             SPIN_TrigPack--------------------->Many of the procedures
''       Note: The tested generator is the TRNG of SPIN_TrigPack. You can
''             test other generators via the Collect_Random_Values routine
''             where the tested generator's output first should be
''             converted into an integer in  the range [1...1000], then it 
''             should be converted into qValue format. To convert an
''             integer number I to qValue format do I<<16  
'-------------------------------------------------------------------------
'Start Parallax Serial Terminal. It will launch 1 COG 
PST.Start(57600)
WAITCNT(3 * CLKFREQ + CNT)

PST.Char(PST#CS)
PST.Str(STRING("Battery of Useful Stat Tests started..."))
WAITCNT((6 * CLKFREQ) + CNT)

PST.Char(PST#CS)
PST.Str(STRING("The behaviour of the tested Random Number Generator is compared "))
PST.Char(PST#NL)
PST.Str(STRING("with a mathematically ideal one. A perfect generator would fail"))
PST.Char(PST#NL)
PST.Str(STRING("in 5% of the trials in the applied tests. 5 independent tests are"))
PST.Char(PST#NL)
PST.Str(STRING("groupped, so the probability, that the perfect generator passes"))
PST.Char(PST#NL)
PST.Str(STRING("all those 5 test is 0.95^5 = 0.774. In other words, it fails 22.6%"))
PST.Char(PST#NL)
PST.Str(STRING("of the groupped tests. When the tested generator fails between"))
PST.Char(PST#NL)
PST.Str(STRING("23 +-6 times from the 100 repetition of the test groups, then it"))
PST.Char(PST#NL)
PST.Str(STRING("can be taken as a good random number generator with >95% confidence."))
PST.Char(PST#NL)

WAITCNT((12 * CLKFREQ) + CNT) 

Q.Start_Driver 

failed~
cntr~                                                        
mvF~
raF~
rtF~
chF~
bfF~
REPEAT 100
  cntr++ 
  PST.Char(PST#CS)
  PST.Dec(cntr)
  PST.Str(STRING(". salvo of a 5 tests battery ("))
  PST.Dec(failed)
  PST.Str(STRING(" failed up till now.)"))
  PST.Chars(PST#NL, 2)
  fail~

  f~
  Collect_Random_Values(1000)
  PST.Str(STRING("      Missing Values Test ... "))  
  IF Missing_Values
    PST.Str(STRING("Passed ("))
  ELSE
    PST.Str(STRING("Failed ("))
    IF fail == 0
      fail := 1
      failed++
      mvF++
      f++
  PST.Dec(testStat)
  PST.Str(STRING(")"))
  IF f
    PST.Str(STRING("!"))
    WAITCNT((CLKFREQ / 2)+ CNT)        
  PST.Char(PST#NL)
  
  f~
  Collect_Random_Values(100)
  PST.Str(STRING("Reverse Arrangements Test ... "))  
  IF Rev_Arrange
    PST.Str(STRING("Passed ("))
  ELSE
    PST.Str(STRING("Failed ("))
    IF fail == 0
      fail := 1
      failed++
      raF++
      f++    
  PST.Dec(testStat)
  PST.Str(STRING(")"))
  IF f
    PST.Str(STRING("!"))
    WAITCNT((CLKFREQ / 2)+ CNT)         
  PST.Char(PST#NL)

  f~
  Collect_Random_Values(1000)
  PST.Str(STRING("                Runs Test ... "))    
  IF Runs_Test
    PST.Str(STRING("Passed ("))
  ELSE
    PST.Str(STRING("Failed ("))
    IF fail == 0
      fail := 1
      failed++
      rtF++
      f++
  PST.Str(Q.QvalToStr(testStat))
  PST.Str(STRING(")"))
  IF f
    PST.Str(STRING("!"))
    WAITCNT((CLKFREQ / 2)+ CNT)          
  PST.Char(PST#NL)

  f~
  Collect_Random_Values(1000)
  PST.Str(STRING("         Chi-squared Test ... "))  
  IF Chi_Squared
    PST.Str(STRING("Passed ("))
  ELSE
    PST.Str(STRING("Failed ("))
    IF fail == 0
      fail := 1
      failed++
      chF++
      f++    
  PST.Str(Q.QvalToStr(testStat))
  PST.Str(STRING(")"))
  IF f
    PST.Str(STRING("!"))
    WAITCNT((CLKFREQ / 2)+ CNT)         
  PST.Char(PST#NL)

  f~
  Collect_Random_Values(1000)
  PST.Str(STRING("       Benford's law Test ... "))  
  IF Benford_Law
    PST.Str(STRING("Passed ("))
  ELSE
    PST.Str(STRING("Failed ("))
    IF fail == 0
      fail := 1
      failed++
      bfF++
      f++    
  PST.Str(Q.QvalToStr(testStat))
  PST.Str(STRING(")"))
  IF f
    PST.Str(STRING("!"))
    WAITCNT((CLKFREQ / 2)+ CNT)         
  PST.Char(PST#NL)

  WAITCNT((CLKFREQ / 4) + CNT)

PST.Char(PST#CS)  
PST.Str(STRING("Number of failed test salvos is "))
PST.Dec(failed)
PST.Str(STRING(" from 100 rounds."))
PST.Chars(PST#NL, 2)

PST.Str(STRING("An ideal and perfect generator has 22.62% chance to fail"))
PST.Char(PST#NL)
PST.Str(STRING("this salvo of tests, and the 95% confidence interval of"))
PST.Char(PST#NL)
PST.Str(STRING("the actual fails is usually in between 17 and 29."))
PST.Chars(PST#NL, 2)

IF (failed < 30)AND(failed > 16)
  PST.Str(STRING("So, the tested generator can be regarded as a GOOD random"))
  PST.Char(PST#NL)
  PST.Str(STRING("number generator, as "))
  PST.Dec(failed)
  PST.Str(STRING(" is within the interval [17..29]."))
  PST.Char(PST#NL) 
ELSE
  PST.Str(STRING("So, the tested generator can NOT be taken as a GOOD random"))
  PST.Char(PST#NL)
  PST.Str(STRING("number generator, as "))
  PST.Dec(failed)
  PST.Str(STRING(" is outside the interval [17..29]."))
  PST.Chars(PST#NL, 2)
  PST.Str(STRING("Identified areas of weak generator performance:"))
  PST.Chars(PST#NL, 2)  
  IF (mvF>6)
    PST.Str(STRING("Problems with Missing Values detected!"))
    PST.Char(PST#NL)
  IF (raF>6)
    PST.Str(STRING("Problems with Reverse Arrangements detected!"))
    PST.Char(PST#NL)
  IF (rtF>6)
    PST.Str(STRING("Problems with Runs Above & Below Median detected!"))
    PST.Char(PST#NL)         
  IF (chF>6)
    PST.Str(STRING("Problems with Uniformity of distribution detected!"))
    PST.Char(PST#NL)
  IF (bfF>6)
    PST.Str(STRING("Problems with Benford-Law of Ratios detected!"))
    PST.Char(PST#NL)
  PST.Char(PST#NL)
          
PST.Char(PST#NL)      
PST.Str(STRING("You can easily measure the actual confidence interval by"))
PST.Char(PST#NL)
PST.Str(STRING("running this program at least 10 times and calculating"))
PST.Char(PST#NL)
PST.Str(STRING("the Average and Standard Deviation of the # of fails."))
PST.Char(PST#NL)
PST.Str(STRING("When 22.62 is between the calculated"))
PST.Chars(PST#NL, 2)
PST.Str(STRING("       Average +/- (0.4 * Standard Deviation),"))
PST.Chars(PST#NL, 2)
PST.Str(STRING("then the tested generator is very similar to an ideal one."))
PST.Char(PST#NL)
PST.Str(STRING("Otherwise, it deviates from an ideal generator too much and"))
PST.Char(PST#NL)
PST.Str(STRING("needs your attention!"))

PST.Chars(PST#NL, 2)
  
QueryReboot     

PST.Chars(PST#NL, 2)
PST.Str(STRING("Battery of Useful Stat Tests terminated normaly..."))
WAITCNT(CLKFREQ + CNT)
PST.Stop
'------------------------End of Start_Application-------------------------


PRI Collect_Random_Values(n) | mn, mx, i
'-------------------------------------------------------------------------
'------------------------┌───────────────────────┐------------------------
'------------------------│ Collect_Random_Values │------------------------
'------------------------└───────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: Collects random values (1...1000) fom the checked generator
' Parameters: Number of random values to collect  
'    Returns: None
'    Results: 1000 random values in rnds[1000]          
'+Reads/Uses: rnds[1000]                         (VAR/LONG[1000])
'    +Writes: rnds[1000]                         (VAR/LONG[1000])                                    
'      Calls: "SPIN_TrigPack"-------------------->Q.StrToQval
'             "SPIN_TrigPack"-------------------->Q.int
'             "SPIN_TrigPack"-------------------->Q.TRNG (RNG under test)         
'       Note: Here you can substitute the tested RNG of yours      
'-------------------------------------------------------------------------
mn := Q.StrToQval(STRING("1.0"))
mx := Q.StrToQval(STRING("1000.9999"))
REPEAT i FROM 0 TO (n-1)
  rnds[i] := Q.Qint(Q.Q_TRNG(mn, mx))
'----------------------End of Collect_Random_Values-----------------------


PRI Missing_Values | i, cntr
'-------------------------------------------------------------------------
'-----------------------------┌────────────────┐--------------------------
'-----------------------------│ Missing_Values │--------------------------
'-----------------------------└────────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Tests missing values from 1000 random numbers from the
'             [1...1000] interval
' Parameters: None
'    Returns: TRUE if passed at 0.05 alpha else FALSE                
'+Reads/Uses: rnds, flag arrays                       (VAR/LONG[1000])
'             Constants                               (CON/LONGs)
'    +Writes: flag array                              (VAR/LONG[1000])           
'      Calls: None             
'       Note: For an ideal generator the # of missing values are betwenn
'             350 and 386 in 95% of the cases
'-------------------------------------------------------------------------
'Clear work area
REPEAT i FROM 0 TO 999
  flag[i] := 0
  
'Fill work area
REPEAT i FROM 0 TO 999
  flag[rnds[i]>>16] := 1

'Count number of zeroes (missing values) in flag array
cntr := 0
REPEAT i FROM 0 TO 999
  IF NOT flag[i]
    cntr++

testStat := cntr
    
IF (cntr<350) OR (cntr>386)
  RETURN FALSE
ELSE
  RETURN TRUE  
'--------------------------End of Missing_Values--------------------------


PRI Rev_Arrange | i, j, cntr
'-------------------------------------------------------------------------
'-----------------------------┌─────────────┐-----------------------------
'-----------------------------│ Rev_Arrange │-----------------------------
'-----------------------------└─────────────┘-----------------------------
'-------------------------------------------------------------------------
'     Action: Count number of reverse arrangements in 100 random numbers 
'             selected from (1...1000) 
' Parameters: None
'    Returns: TRUE if passed at 0.05 alpha else FALSE                
'+Reads/Uses: rnds                                      (VAR/LONG[1000])
'    +Writes: None                                    
'      Calls: None
'       Note: For an ideal generator the # of reverse arrangements are
'             between 2146 and 2804 in 95% of the cases
'-------------------------------------------------------------------------
'Count number of reverse arrangements in 100 random numbers
cntr~
REPEAT i FROM 0 TO 98
  REPEAT j FROM i TO 99
    IF rnds[i] > rnds[j]
      cntr++

testStat := cntr

IF (cntr < 2146) OR (cntr > 2804)
  RETURN FALSE
ELSE
  RETURN TRUE  
'----------------------------End of Rev_Arrange---------------------------


PRI Runs_Test|i,cntr,med,na,nb,nruns,mean,sdev,qu,x1,x2,x3,x4,x5,z
'-------------------------------------------------------------------------
'-------------------------------┌───────────┐-----------------------------
'-------------------------------│ Runs_Test │-----------------------------
'-------------------------------└───────────┘-----------------------------
'-------------------------------------------------------------------------
'     Action: Tests runs above and below of the median for 1000 uniform
'             (1...1000) numbers
' Parameters: None
'    Returns: TRUE if passed at 0.05 alpha else FALSE                
'+Reads/Uses: rnds, flag arrays                  (VAR/LONG[1000])
'             Constants                          (CON)
'    +Writes: flag array                                    
'      Calls: SPIN_TrigPack--------------------->Q.Qval
'                                                Q.Qmuldiv
'                                                Q.Qsqr
'                                                Q.Qdiv
'       Note: For an ideal generator the Runs test statistics is less than
'             2 in 95% of the cases
'-------------------------------------------------------------------------
'Clear work area for 1000 marks
REPEAT i FROM 0 TO 999
  flag[i] := 0

'Fill work area
REPEAT i FROM 0 TO 999
  flag[rnds[i]>>16]++

'Find the median
cntr := 0
REPEAT i FROM 0 TO 999
  cntr := cntr + flag[i]
  IF cntr > 499
    med := i
    QUIT

'Count and mark runs above and below the median
na~
nb~
nruns~
REPEAT i FROM 0 TO 998
  flag[i]~
  IF ((rnds[i]>>16)>med)AND((rnds[i+1]>>16)>med)     'Above
    flag[i] := 2     'Mark
    flag[i+1] := 2
    nb~
    IF na==0         'New run above started
      nruns++
      na := 1
  ELSEIF ((rnds[i]>>16)<med)AND((rnds[i+1]>>16)<med) 'Below
    flag[i] := 1     'Mark   
    flag[i+1] := 1
    na~
    IF nb==0         'New run below started
      nruns++
      nb := 1    
  ELSE
    na~
    nb~

'Count number of '1's (run below) and '2's (run above)
na~
nb~
REPEAT i FROM 0 TO 999
  IF flag[i] == 1
    nb++
  ELSEIF flag[i] == 2
    na++

'Calculate mean
qu := Q.Qval(nruns)
x1 := Q.Qval(na)
x2 := Q.Qval(nb)
x3 := x1 + x2
x4 := Q.Qmuldiv(x1, x2, x3)
x4 := Q.Qmul(_Q2, x4)
mean := x4 + _Q1

'Calculate standard deviation
i := ((2 * na * nb) - na - nb) / (na + nb - 1)
x5 := Q.Qval(i)
x1 := Q.Qmuldiv(x4, x5, x3)
sdev := Q.Qsqr(x1)

'Calculate test statistics    
IF (qu > mean)
  z := qu - mean + _QH
  z := Q.Qdiv(z, sdev)
ELSE
  z := qu - mean - _QH
  z := Q.Qdiv(z, sdev)
  z := || z 

testStat := z
  
IF (z > _Q2)
  RETURN FALSE
ELSE
  RETURN TRUE 
'-----------------------------End of Runs_Test----------------------------


PRI Chi_Squared | i, chi2, qe, qi, ch2
'-------------------------------------------------------------------------
'------------------------------┌─────────────┐----------------------------
'------------------------------│ Chi_Squared │----------------------------
'------------------------------└─────────────┘----------------------------
'-------------------------------------------------------------------------
'     Action: Tests uniformity with Chi-Squared statistics for 1000 random
'             numbers drawn from 1...1000 and placed in 10 uniform bins
' Parameters: rnds  1000 random numbers            (VAL/LONG[1000])
'    Returns: TRUE if passed at 0.05 alpha else FALSE                
'+Reads/Uses: - rnds, flag arrays                  (VAR/LONG[1000])
'             - _C1..9                             (CON/LONGs)
'    +Writes: flag array                           (VAR/LONG[1000])           
'      Calls: SPIN_TrigPack------------------------>Q.Qval
'                                                   Q.Qmuldiv
'                                                   Q.StrToQval        
'       Note: Test statistics is from Chi-squared Table
'-------------------------------------------------------------------------
'Clear work area for 10 bins
REPEAT i FROM 0 TO 9
  flag[i]~

'Fill bins
REPEAT i FROM 0 TO 999
  IF rnds[i] < _C1
    flag[0]++
  ELSEIF rnds[i] < _C2
    flag[1]++
  ELSEIF rnds[i] < _C3
    flag[2]++
  ELSEIF rnds[i] < _C4
    flag[3]++
  ELSEIF rnds[i] < _C5
    flag[4]++
  ELSEIF rnds[i] < _C6
    flag[5]++
  ELSEIF rnds[i] < _C7
    flag[6]++
  ELSEIF rnds[i] < _C8
    flag[7]++
  ELSEIF rnds[i] < _C9
    flag[8]++
  ELSE
    flag[9]++

'Calculate test statistics
chi2 := 0
REPEAT i FROM 0 TO 9
  qi := Q.Qval(flag[i]) - _Q100
  chi2 := chi2 + Q.Qmuldiv(qi, qi, _Q100)

testStat := chi2

'From Chi-squared Table
ch2 := Q.StrToQval(STRING("16.92"))  '0.05, df=9  
 
IF (chi2 > ch2)
  RETURN FALSE
ELSE
  RETURN TRUE  
'----------------------------End of Chi-Squared---------------------------


PRI Benford_Law | i, r, chi2, qe, qi, ch2
'-------------------------------------------------------------------------
'------------------------------┌─────────────┐----------------------------
'------------------------------│ Benford_Law │----------------------------
'------------------------------└─────────────┘----------------------------
'-------------------------------------------------------------------------
'     Action: Tests Benford's law for ratios of 1000 uniform (1...1000)
'             random numbers where the ratios are the number/(next number)
' Parameters: rnds  1000 random numbers            (VAL/LONG[1000])
'    Returns: TRUE if passed at alpha=0.05 else FALSE                
'+Reads/Uses: - rnds, flag arrays                   (VAL/LONG[1000])
'             - _C1..10                             (CON/LONGs)
'             - _B1..9                              (CON/LONGs)
'    +Writes: flag[1000] array                      (VAL/LONG[1000])                                    
'      Calls: SPIN_TrigPack------------------------>Q.Qdiv
'                                                   Q.Qmul
'                                                   Q.Qval
'                                                   Q.StrToQval        
'       Note: Test statistics is from Chi-squared Table
'-------------------------------------------------------------------------
'Clear work area for 9 bins (digits)
REPEAT i FROM 1 TO 9
  flag[i]~
  
'Fill bins
REPEAT i FROM 0 TO 998
  r := Q.Qdiv(rnds[i], rnds[i + 1])   'Calculate ratio
  'Normalize 1<r<10
  REPEAT
    IF r => _Q10
      r := Q.Qdiv(r, _Q10)
    ELSEIF r < _Q1
      r := Q.Qmul(r, _Q10)
    ELSE
      QUIT

  'Select bin
  IF (r < _Q2)
    flag[1]++
  ELSEIF (r < _Q3) 
    flag[2]++
  ELSEIF (r < _Q4) 
    flag[3]++    
  ELSEIF (r < _Q5) 
    flag[4]++    
  ELSEIF (r < _Q6) 
    flag[5]++
  ELSEIF (r < _Q7) 
    flag[6]++
  ELSEIF (r < _Q8) 
    flag[7]++
  ELSEIF (r < _Q9) 
    flag[8]++    
  ELSEIF (r < _Q10) 
    flag[9]++

'Calculate test statistics
qi := Q.Qval(flag[1]) - _B1
chi2 := Q.Qmuldiv(qi, qi,  _B1)
qi := Q.Qval(flag[2]) - _B2
chi2 := chi2 + Q.Qmuldiv(qi, qi, _B2)
qi := Q.Qval(flag[3]) - _B3
chi2 := chi2 + Q.Qmuldiv(qi, qi, _B3)
qi := Q.Qval(flag[4]) - _B4
chi2 := chi2 + Q.Qmuldiv(qi, qi, _B4)
qi := Q.Qval(flag[5]) - _B5
chi2 := chi2 + Q.Qmuldiv(qi, qi, _B5)
qi := Q.Qval(flag[6]) - _B6
chi2 := chi2 + Q.Qmuldiv(qi, qi, _B6)
qi := Q.Qval(flag[7]) - _B7
chi2 := chi2 + Q.Qmuldiv(qi, qi, _B7)
qi := Q.Qval(flag[8]) - _B8
chi2 := chi2 + Q.Qmuldiv(qi, qi, _B8)
qi := Q.Qval(flag[9]) - _B9
chi2 := chi2 + Q.Qmuldiv(qi, qi, _B9)

testStat := chi2

'From Chi-squared Table 
ch2 := Q.StrToQval(STRING("15.51"))  '0.05, df=8
  
IF (chi2 > ch2)
  RETURN FALSE
ELSE
  RETURN TRUE  
'----------------------------End of Benford_Law---------------------------


PRI QueryReboot | done, r
'-------------------------------------------------------------------------
'------------------------------┌─────────────┐----------------------------
'------------------------------│ QueryReboot │----------------------------
'------------------------------└─────────────┘----------------------------
'-------------------------------------------------------------------------
'     Action: Queries to reboot or to finish
' Parameters: None                                
'    Returns: None                
'+Reads/Uses: PST#NL, PST#PX                      (OBJ/CON/LONG)
'    +Writes: None                                    
'      Calls: "Parallax Serial Terminal"--------->PST.Str
'                                                 PST.Char 
'                                                 PST.RxFlush
'                                                 PST.CharIn
'-------------------------------------------------------------------------
PST.Str(STRING("[R]eboot to test again  or press any other key to "))
PST.Str(STRING("finish..."))
PST.Char(PST#NL)
done := FALSE
REPEAT UNTIL done
  PST.RxFlush
  r := PST.CharIn
  IF ((r == "R") OR (r == "r"))
    PST.Char(PST#PX)
    PST.Char(0)
    PST.Char(32)
    PST.Char(PST#NL) 
    PST.Str(STRING("Rebooting..."))
    WAITCNT((CLKFREQ / 10) + CNT) 
    REBOOT
  ELSE
    done := TRUE
'----------------------------End of QueryReboot---------------------------


DAT '---------------------------MIT License-------------------------------


{{
┌────────────────────────────────────────────────────────────────────────┐
│                        TERMS OF USE: MIT License                       │                                                            
├────────────────────────────────────────────────────────────────────────┤
│  Permission is hereby granted, free of charge, to any person obtaining │
│ a copy of this software and associated documentation files (the        │ 
│ "Software"), to deal in the Software without restriction, including    │
│ without limitation the rights to use, copy, modify, merge, publish,    │
│ distribute, sublicense, and/or sell copies of the Software, and to     │
│ permit persons to whom the Software is furnished to do so, subject to  │
│ the following conditions:                                              │
│                                                                        │
│  The above copyright notice and this permission notice shall be        │
│ included in all copies or substantial portions of the Software.        │  
│                                                                        │
│  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND        │
│ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     │
│ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. │
│ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   │
│ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   │
│ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      │
│ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 │
└────────────────────────────────────────────────────────────────────────┘
}}                  