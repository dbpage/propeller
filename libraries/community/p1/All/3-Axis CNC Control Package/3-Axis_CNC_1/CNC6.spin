{{
1/2/2013: problem in the output buffer, when the buffer length is set to >2, it occasionally misses steps but works fine if buffer is 2
            need to fix the analog pot routine, is not completely linear, it seems to have higher resolution at lower feedrates


Don Starkey
Email: Don@StarkeyMail.com
Ver. 1.0,  12/24/2011

    I/O P10 - X-Axis Home / +Overtravel (Normally HIGH, Active LOW with Axis HOME, +Overtravel)
    I/O P11 - X-Axis -Overtravel        (Normally HIGH, Active LOW with            -Overtravel)
    I/O P12 - Y-Axis Home / +Overtravel (Normally HIGH, Active LOW with Axis HOME, +Overtravel)
    I/O P13 - Y-Axis -Overtravel        (Normally HIGH, Active LOW with            -Overtravel)
    I/O P14 - Z-Axis Home / +Overtravel (Normally HIGH, Active LOW with Axis HOME, +Overtravel)
    I/O P15 - Z-Axis -Overtravel        (Normally HIGH, Active LOW with            -Overtravel)

    ' Must be a contiguous block of 6 pins    
    I/O P16 - X-Axis Step Pin   ' Movement happens on the Falling edge of our step pulse which is then    
                                '  inverted through driver transistor = rising edge ( Low for 0.5 uS)
                                '  for Superior SD200 step driver.  
    I/O P17 - X-Axis Direction Pin (Bit set for Negative direction Move, Bit clear for Positive direction move)

    I/O P18 - Y-Axis Step Pin   ' Movement happens on the Falling edge of our step pulse which is then  
                                '  inverted through driver transistor = rising edge ( Low for 0.5 uS)
                                '  for Superior SD200 step driver.    

    I/O P19 - Y-Axis Direction Pin (Bit set for Negative direction Move, Bit clear for Positive direction move)

    I/O P20 - Z-Axis Step Pin   ' Movement happens on the Falling edge of our step pulse which is then 
                                '  inverted through driver transistor = rising edge ( Low for 0.5 uS)
                                '  for Superior SD200 step driver.    

    I/O P21 - Z-Axis Direction Pin (Bit set for Negative direction Move, Bit clear for Positive direction move)

    I/O P22 -

    I/O P23 - Drive Enable (stepper drives enabled when HIGH)

    I/O P24 - SD Card DO Pin   
    I/O P25 - SD Card CLK Pin    
    I/O P26 - SD Card DI Pin   
    I/O P27 - SD Card CS Pin   

    I/O P28 - SCL I2C
    I/O P39 - SDA I2C
    I/O P30 - Serial Communications
    I/O P31 - Serial Communications

Need to do:

    
    Add ^F to find within the editor
    add file I/O error checking
    
    Stop Decel/Acel between tangent moves.
    adjustable accel by tweaking table 

    Video
    Keyboard
    Block Delete
    "Push Button" Interface
    
    Hardware switches
        Hold
        Cycle Start
        Single Block
        E-Stop
        Reset
        Jog
        Handle

Done    Limit switches
Done    Homing routine
Done    Load settings from file    
Done    Save settings to file
Done    Configuration Page
Done    Fixture Offsets G54..G59
Done    Tool Lenght Offsets
Done    MDI editor
Done    Locks up when editing a zero-length file
Done    Ring buffer from LIN & CIR routines.
Done    Split OFFSET editor to sub-program

        

}}

CON                  
    _CLKMODE        = XTAL1 + PLL16X                     
    _XINFREQ        = 5_000_000
    _Stack          = 150
    

    ' Pin Usage Equates
    X_OT_Pos        = 10    ' X Overtravel Positive & Home     (Normally HIGH, Active LOW)
    X_OT_Neg        = 11    ' X Overtravel Negative Direction  (Normally HIGH, Active LOW)
    Y_OT_Pos        = 12    ' Y Overtravel Positive & Home     (Normally HIGH, Active LOW)
    Y_OT_Neg        = 13    ' Y Overtravel Negative Direction  (Normally HIGH, Active LOW)
    Z_OT_Pos        = 14    ' Z Overtravel Positive & Home     (Normally HIGH, Active LOW)
    Z_OT_Neg        = 15    ' Z Overtravel Negative Direction  (Normally HIGH, Active LOW) 
    
    StepXPin        = 16+0  ' Must be a contiguous block of 6 pins
'   DirXPin         = 16+1
'   StepYPin        = 16+2
'   DirYPin         = 16+3
'   StepZPin        = 16+4
'   DirZPin         = 16+5
    Spindle         = 22    ' Spindle On/Off  (Future use)

    EnablePin       = 23    ' Stepper Driver Enable when HIGH
    DOPin           = 24    ' SD Card Data OUT
    ClkPin          = 25    ' SD Card Clock
    DIPin           = 26    ' SD Card Data IN
    CSPin           = 27    ' SD Card Chip Select
    I2CBase         = 28    ' ADS1000 12-Bit A/D Chip Clock 
'   I2CBase+1       = 29    ' ADS1000 12-Bit A/D Chip Data 
'   Serial          = 30
'   Serial          = 31

    CCW             =  2    ' Counter-Clockwise rotation
    CW              = -2    ' Clockwise rotation
    OTCode          = -100  ' Overtravel Abort Code
    NoOTError       = 1     ' Don't throw an overtravel error
    YesOTError      = 0     ' Throw OT Error   
    MinPulse        = 10
    MaxPulse        = 650   ' Don't know why but too long causes errors in output driver

    ' Actions for Exists routine
    None            = 0     ' No action, return non-zero if file doesn't exist
    Delete          = 1     ' Return's 0 if file deleted, returns non-zero if error deleting it
    Boot            = 2     ' Boots the file
    Create          = 3     ' Create a 1-line empty file ready for editing
    
    ' Operating Modes
    StartHold       = -1
    Stop            = 0
    Auto            = 1     ' Runs automatically
    SingleBlock     = 2     ' requires a <CR> to step through program 
    MDI             = 3
    Edit            = 4
    ReStart         = 5
    
    BufferSize      = 64    ' Buffer for CNC line import from file
    ShortBufSize    = 30
    TerminalLines   = 25    ' How many lines on the terminal
    EditorLines     = 23    ' Number of Display lines in the editor
    ProgWinTop      = 7     ' Top Line Of Program Display Window
    
  ' i2c bus contants
    ADAddress       = 73    ' ADS1000 12-bit A/D for Feed-Rate override

    ' ADS1000BD1 12-Bit A/D converter   @ I2C address %1001001 @ 73
    ADS1000A0_Addr              = %100_1000             ' I2C Address of D/A converter BD0 @ 72                   '
    ADS1000A1_Addr              = %100_1001             ' I2C Address of D/A converter BD1 @ 73
    ADS1000_ContConv            = %00000                '  ADS1000 Continuous Conversion
    ADS1000_SingleConv          = %10000                ' ADS1000 Single Conversion
    ADS1000_PGA1                = %00                   ' ADS1000 PGA Gain of 1
    ADS1000_PGA2                = %01                   ' ADS1000 PGA Gain of 2
    ADS1000_PGA4                = %10                   ' ADS1000 PGA Gain of 4
    ADS1000_PGA8                = %11                   ' ADS1000 PGA Gain of 8

    AbsFloat                    = %0111_1111_1111_1111_1111_1111_1111_1111 ' bitmask to strip off the sign bit from floating point numbers
    
OBJ

        Ser         : "VT100 Serial Terminal"               ' Spin code interperter running in first COG
        FS          : "FloatString"                         ' Spin code          
        FM          : "FloatMath"                           ' Spin code
        Circular    : "Hybrid_Circle8"                      ' Requires 1 COG
        Linear      : "Int_Line8"                           ' Requires 1 COG
        F32         : "F32_pasm"                            ' Requires 1 COG  F32 V1.5a Floating Point Math Object by Jonathan "lonesock" Dummer
        fat0        : "SD-MMC_FATEngine.spin"               ' Requires 1 COG
        fat1        : "SD-MMC_FATEngine.spin"               ' Requires 1 COG
        OutBuffer   : "OutputBuffer"                        ' Requires 1 COG
        OutDriver   : "OutputDriver6"                       ' Requires 1 COG



VAR



' Dont rearrange the order of these variables as the PASM code needs to know them in order

        long OT_Mode    ' -16 Overtravel Mode. 0 = norm: OT will stop all motion & reset the move
                        '                      1 = Home mode, OT will stop just the offending axis but the move will complete
        long F32_Cmd    ' -12
        long F32Arg1    ' -8
        long F32Arg2    ' -4
        long s_State    ' +0 Commanded State of Movement Interpolation cogs
                        ' State of 0 = idle, awaiting a value from Spin program
                        ' State of 1 = move in linear mode G00 or G01. If overtravel all movement will stop.
                        ' State of +2 = move in  CW circular interpolation Direction = G02
                        ' State of -2 = move in CCW circular interpolation Direction = G03
                        ' Use this variable to pass the Interpolation cogs the address of the output
                        ' buffer located at the bottom of this cog.
                        ' When initializing the Circular Interpolation cog.
                        ' State = 92 to set the absolute position (G92)
                        ' State = OTCode if overtraveled
                        
        long s_FromX    ' +4  From X Coordinate (Float)
        long s_FromY    ' +8  From Y Coordinate (Float)
        long s_FromZ    ' +12 From Z Coordinate (Float) 
        long s_ToX      ' +16 To X Coordinate (Float)
        long s_ToY      ' +20 To Y Coordinate (Float)
        long s_ToZ      ' +24 To Z Coordinate (Float)
        long s_I        ' +28 Distance from Starting X to Center of Radius along X-Axis (Float)
        long s_J        ' +32 Distance from Starting Y to Center of Radius along Y-Axis (Float)        
        long s_K        ' +36 Distance from Starting Z to Center of Radius along Z-Axis (Float)        
        long s_SPM      ' +40 Speed of movement in Inches/Minutes (Float)

        long s_XAt      ' +44 Current location of X Axis (Machine position, Integer Step Counts)
        long s_YAt      ' +48 Current location of Y Axis (Machine position, Integer Step Counts)
        long s_ZAt      ' +52 Current location of Z Axis (Machine position, Integer Step Counts)

        long s_PotRaw   ' +56 Feed Rate Potentiometer Value (0-2048)
        long s_PotScale ' +60 Feed Rate Potentiometer Value (0-2.0 for 200% override)
    

        long DebugVar1  ' +64  Debugging variables, can be deleted
        long DebugVar2  ' +68  Debugging variables, can be deleted
        long DebugVar3  ' +72  Debugging variables, can be deleted
        long DebugVar4  ' +76  Debugging variables, can be deleted
        long DebugVar5  ' +80  Debugging variables, can be deleted
        long DebugVar6  ' +84  Debugging variables, can be deleted


        long InterpBuffer       ' +0 Pass-through variable between Interpolation COGs and Output Buffer
        long OutputBuffer       ' +4 Pass-through variable between Output Buffer & Output Driver         
        long BufferUsed         ' +8 Current number of used buffer slots in ring buffer
            
        long    X               ' X-Coordinate  (Long)
        long    Y               ' Y-Coordinate  (Long)
        long    Z               ' Z-Coordinate  (Long)
        long    I               ' I-Coordinate  (Long)
        long    J               ' J-Coordinate  (Long)
        long    K               ' K-Coordinate  (Long)
        long    U               ' Incremental X-Coordinate  (Long)
        long    V               ' Incremental Y-Coordinate  (Long)
        long    W               ' Incremental Z-Coordinate  (Long)
        long    R               ' R-Coordinate  (Long)
        long    F               ' Feed Rate     (Long)
        long    S               ' Spindle Speed
        
        long    GMode1          ' Group 1 Modal Commands G0, G1, G2, G3
        long    WorkOffset      ' 54 - 59 or 0 if none (when 92 is called)
        long    IncAbs          ' Either 90 for Absolute or 91 for incremental interpertation of X,Y & Z
        long    OffsetX         ' Total Workplane Offset X (Combination of G92 Offset + G54..59 Offset
        long    OffsetY         ' Total Workplane Offset Y (Combination of G92 Offset + G54..59 Offset
        long    OffsetZ         ' Total Workplane Offset Z (Combination of G92 Offset + G54..59 Offset
        long    G92X            ' X Offset
        long    G92Y            ' Y Offset
        long    G92Z            ' Z Offset
'        byte    OffsetActive    ' bitmask for active offsets b0=X, B1=Y, B2=Z    
        long    SourceBlockPtr
        word    TokenStringPointer

        byte    InComment
        byte    BufferedChar
        byte    LastChar
        long    lc
        word    i2cSDA, i2cSCL
        long    lHex
        long    qValue
        long    FileReadPos
        long    SerLine
        long    ProcessPtr    
        byte    EOF, NoScroll
        long    OpMode
        long    Interrupt
        long    JogInc
        byte    Changed ' Editor variable
 
        
PUB Start | tmp 

{ Cog Usage:
    0   This Spin Program
    1   Serial Driver
    2   F32 Math Routines (This routine is used by the Circular & Linear Interpolator Cogs.)
    3   Circular Interpolation
    4   Linear Interpolation
    5   Output Buffer
    6   FAT32 SD memory card
    7   Output Diver
}

    ser.start(115200)                   ' Start the serial port driver @ 115200 to display status of SD read

    Exists(@ScratchFile,Delete) ' Delete Editor Temp File if it exists
    
    ' If "REBOOT.ING" file exists, then we are reloading from the config editor,
    ' skip the splash screen & return to the main menu.
    
    Result:=Exists(@RebootFile,Delete) ' returns 0 if successful 
    ifnot result ' file was there and now is gone
        ReadConfig(0)
    else
        ' Wait while user pressed key on terminal
        repeat while ser.RXCheck==-1
            ser.clear
            ser.home        
            ser.str(string(27,"[0m")) ' Reset Attributes
            MsgBox(25,4, @Splash, 0)
            MsgBox(31,15, @MsgPressKey, 0)
            waitcnt(clkfreq+cnt)
                                                    
        GreenOnBlack
        FillZone(31,15,18,21)
        ReadConfig(1)


    if Var_Baud                         ' Only re-start serial if baudrate <> 0                        
        ser.stop                        ' If we got this far, the SD card was read so                                                   
        ser.start(fm.FTrunc(Var_Baud))  ' re-start the serial port driver at the right baud rate.
    else
        ser.str(string("Config file possibly corrupt.",7))
        waitcnt(clkfreq*5+cnt)     

    I2CInit                             ' Start SPIN I2C driver for A/D converter 

    ' Start 32-bit floating point math COG
    F32_Cmd := 0 ' make sure we don't do a calculation yet
    F32.start(@F32_Cmd) ' start F32 cog, pass it address of command variable
    F32Arg1:=F32.call_ptr

    ' Initialize Circular & Linear Interpolation Cogs
    s_state:=@AccTable          ' Pass address of Step Acceleration Table to Circle Cog    
    Circular.Start(@s_State, @InterpBuffer, Var_SPI)
    waitcnt(clkfreq/10+cnt)
    
    s_state:=@AccTable          ' Pass address of Step Acceleration Table to Linear Cog
    Linear.Start(@s_State, @InterpBuffer, Var_SPI) 
    waitcnt(clkfreq/10+cnt)

    s_State:= @InterpBuffer
    OutBuffer.Start(@s_State)' Start Stepper Motor Output driver.
'    repeat until s_State==-1
    waitcnt(clkfreq/10+cnt) ' Give it time to load

    s_State:= @InterpBuffer
    OutDriver.Start(@s_State, StepXPin, X_OT_Pos, PulseLength, Var_Polarity)' Start Stepper Motor Output driver.
'    repeat while s_State
    waitcnt(clkfreq/10+cnt) ' Give it time to load


    WorkOffset:=54
    g92(0,0,0)             ' This must be here to initialize variables properly
    JogInc:=1       ' Initial Jog Amount = 0.001

'    ApplyWorkOffset                                                                          
    IncAbs:=90      ' Absolute Position


        
    repeat
        ser.clear
        ser.home
        DrawHeader
        DispPos
        MainMenu                                            ' Launch main menu


PRI MainMenu | tmp, tmp2

    s_State:=0                  ' clear overtravel status
    InterpBuffer:=-1            ' clear overtravel status

    OpMessage(@OpMsgIdle)
    MsgBox(58,6, @Menu1, 0)
    PosString(@MenuPrompt)                    

    GreenOnBlack
    Interrupt:=-1                       ' Disable Interrupt
    ApplyWorkOffset                                                                  
    IncAbs:=90 ' Absolute Position

    ser.position(72,16)        ' Position cursor for input
    ByteFill(@Block,32,2)
    result:=GetString(@Block,2,1) ' Update the feed rate override fields

    FillZone(55,6,16,21)
    
     
    case byte[@Block]
    
        "1":  ' Load File
            result:=GetFileName ' get filename into @block, returns 0 if file exists
'            ser.position (1,10)
'            ser.str(@block)
'            ser.char(32)
'            ser.dec(result)
'            ser.str(result)
'            waitcnt(clkfreq+cnt)

            GreenOnBlack
            ' Verify that file exists
            ifnot result ' Result== zero if file exists
                bytemove(@Var0,@block,12)
                ser.clear
                OpMessage(@OpMsgAuto)        
                OpMode := StartHold
                \ProcessFile(@Var0)
'                DisableDrives
             
            else ' an error occured
                if result<>-1                    
                    MsgBox(35,10, @MsgBadName, 0)
                    ser.position(36,13)
                    WhiteOnRed
                    ser.str(result)
                    MsgBox(35,14, @MsgPressKey, 1)


        "2":                    ' Edit File
            EditFile(@Var0)
            

        "3":                    ' New File
            result:=GetFileName ' get filename into @block, returns 0 if file exists
            if byte[@block]<> 32
                ' Verify that file exists
                bytemove(@Var0,@block,12)
                if result ' Result== zero if file exists
                    Exists(@Var0,create) ' returns 0 if file created or non-zero if file already exists                        
                    EditFile(@Var0)

                else ' the file already exists prompt for overwrite                    
                    MsgBox(25,15, @MsgOverwrite, 1)

                    if byte[@Block]=="Y"                        
                        ifnot Exists(@Var0,Delete)
                            Exists(@Var0,create) ' returns 0 if file created or non-zero if file already exists                        
                            EditFile(@Var0)
                                        

        "4":                    ' MDI
            ' Open or create MDI.txt file, edit it, run it
            Exists(@MDIFile,create) ' returns 0 if file created or non-zero if file already exists
            EditFile(@MDIFile)
            ser.clear
            ser.home
            OpMessage(@OpMsgMDI)
            OpMode := StartHold            
            \ProcessFile(@MDIFile)                    
'            DisableDrives
            
                         
        "5":                    ' Manual / Jog Mode
            JogMenu
            byte[@Block]:="5"

        "6":                    ' Restart File
            if byte[@Var0]<>32
                ser.clear
                ser.home
                OpMessage(@OpMsgAuto)
                OpMode := StartHold
                \ProcessFile(@Var0)
'                DisableDrives                
                
            else
                ser.beep
            
        "7":                    ' Single Block

            
        "8":                    ' Offsets
            Var_Chain:=1        ' What should the chained overlay program do, 1=Offsets
            writeconfig(0)      ' Silently write settings
            exists(@OverlayFile,Boot)
            MsgBox(25,15, @MsgOverlay, 1)

            ApplyWorkOffset                                                                          

        "9":                    ' Settings
            Var_Chain:=0        ' What should the chained overlay program do, 0=Settings
            writeconfig(0)      ' Silently write settings
            exists(@OverlayFile,Boot)
            MsgBox(25,15, @MsgOverlay, 1)

        "Q":                    ' Quit
            DisableDrives
            writeconfig(1)
            MsgBox(35,10, @MsgGoodby, 1)
            repeat

PRI JogMenu | tmp, pos, Delta, input, Timer, tmp2, bias

    Interrupt:=-1                                           ' Disable Interrupt
    EnableDrives
    repeat
        MsgBox(58,6, @Menu2, 0)
        PosString(@MenuPrompt)         
        ser.position(72,16)         ' Position cursor for input
        ByteFill(@Block,32,2)
        result:=GetString(@Block,2,1) ' Update the feed rate override fields
            
        if result==27
            byte[@Block]:="9"

        GreenOnBlack
        FillZone(58,6,16,21)

        f:=Var_Jog
        
        case byte[@Block]
         
            "1":                    ' Keyboard Jog
                MsgBox(58,6, @JogText_1, 0)
                WhiteOnRed
                PosString(@JogText_21)
                PosString(@JogText_22)
                result:=-1
                FinishMove ' Get current position
                                
                repeat
                
                    if result<>JogInc                                 ' skip unless JogInc changes
                    
                        result:=JogInc            
                        case JogInc
                            1:  pos:=1
                                delta:=0.001
                            2:  pos:=7
                                delta:=0.01
                            3:  pos:=12
                                delta:=0.1
                            4:   pos:=16
                                delta:=1.0
                            5:  pos:=18
                                delta:=10.0
                        
                        WhiteOnRed
                        PosString(@JogText_21)
                        GreenOnBlack
                        ser.position(36+pos,6)
                        ser.str(fs.FloatToString(delta))                
                    
                    repeat
                        DispPos        
                        tmp:=GetKey        
                    while tmp == -1
                    
                    s_ToX := s_FromX
                    s_ToY := s_FromY
                    s_ToZ := s_FromZ
                    
                    case tmp
                        43..44,61:                          ' "+", Keypad + or "="                    
                            JogInc++
                            if JogInc==6
                                JogInc:=1
        
                        383,95,45:                          ' "-" or keypad - or "_"                              
                            JogInc--
                            if JogInc==0
                                JogInc:=5
        
                        56:                                 ' Y+
                            s_ToY := fm.FAdd(s_FromY,Delta)
                            \lin(f,NoOTError,|<Y_OT_Pos)
        
                        50:                                 ' Y-
                            s_ToY := fm.FSub(s_FromY,Delta)
                            \lin(f,NoOTError,|<Y_OT_Neg)
        
                        54:                                 ' X+
                            s_ToX := fm.FAdd(s_FromX,Delta)
                            \lin(f,NoOTError,|<X_OT_Pos)
        
                        52:                                 ' X-
                            s_ToX := fm.FSub(s_FromX,Delta)
                            \lin(f,NoOTError,|<X_OT_Neg)
                        
                        57:                                 ' Z+
                            s_ToZ := fm.FAdd(s_FromZ,Delta)
                            \lin(f,NoOTError,|<Z_OT_Pos)
                        
                        51:                                 ' Z-
                            s_ToZ := fm.FSub(s_FromZ,Delta)
                            \lin(f,NoOTError,|<Z_OT_Neg)
                        
                        27:                                           ' Escape out of Keyboard Jog
                            GreenOnBlack
                            FillZone(36,6,7,23)
                            quit                                
                            
        
                    
            "2":                    ' Handle Jog
         
            "3":                    ' Return to WORK 0,0,0

                s_ToX := s_FromX                    
                s_ToY := s_FromY                    
                s_ToZ := OffsetZ
                lin(f,YesOTError,0)

                s_ToX := OffsetX
                s_ToY := OffsetY
                s_ToZ := OffsetZ                    

                lin(f,YesOTError,0)
                
            "4":                    ' Set 0,0,0
                SetG92(0,0,0)       ' Calulate the G92 offsets for the current positon
                         
         
            "5":                    ' Set current position as work offset
                tmp2:=1             ' force redraw of G54 coordinates
                tmp:=0              ' Default to G54
                GreenOnBlack
                PosString(@JogText_61)
                PosString(@JogText_62)
                PosString(@JogText_63)
                PosString(@JogText_64)
                WhiteOnRed
                PosString(@JogText_65)
                ser.str(string(27,"=")) ' Application Keypad mode
                repeat
                
                    if tmp<>tmp2                                            
                        WhiteOnRed
                        PosString(@JogText_66)
                        GreenOnBlack                        
                        tmp2:=tmp                

                        ShowWorkOffset(tmp)
                        
                        ser.position(31+(tmp*4),7)
                        ser.str(string("G5"))
                        ser.char("4"+tmp)

                    tmp:=tmp2             
                        
                    repeat
                        DispPos        
                        result:=GetKey        
                    while result == -1

                    case result
                        61,420,418,408,367: ' "+"=61, Keypad +=408 or "=" or Up=420 or Right=418, Cursor-Rt=367   
                            tmp++
                            if tmp==6
                                tmp:=0
                    
                        383,95,45,414,416,368: ' "-"=45 or keypad -=383 or "_"=95 or down=416 or left=416, Cursor-Lft=368           
                            tmp--
                            if tmp==-1
                                tmp:=5                                             
                            
                        27:
                            quit
                                
                        13, 377:
                            repeat result from 0 to 2
                                bias:=result*4
                                long[Bias+@Var4+(tmp*12)]:=fm.FDiv(FM.FFloat(long[Bias+@s_XAt]),Var_SPI)
                            G92X:=G92Y:=G92Z:=0
                            ShowWorkOffset(tmp)                            
                            quit

                        other:
                            ser.position(1,1)
                            ser.dec(result)
                            ser.str(string("   "))
                            waitcnt(clkfreq+cnt)
                    
                GreenOnBlack
                FillZone(30,6,11,60)                
                ser.str(string(27,">")) ' Cancel Application Keypad mode

            "6":
                             
            "7":                    ' Home Machine
                HomeMachine         ' Home machine & Zero the low level driver to 0's

            "8":
         
            "9",27:                                         ' Quit        
                GreenOnBlack
                FillZone(60,6,16,20)                
'               Interrupt:=0                                ' Enable Interrupt
                DisableDrives
                quit

PRI GetFileName | tmp,tmp2
' Display file directory for filenames that have the default file extension
' Prompt for a file name
' Check to see if the file exists, if so, return 0
' If file doesn't exist, return error code
' return -1 if user ESCapes out of entering a file name

    ser.clear
    ser.home

    tmp:=0
    GreenOnBlack
    PosString(@MainText_11)
    ser.chars(32,5)
    ser.char("(")
    ser.str(@ValidExt)
    ser.char(")")
                        
    fat0.fatEngineStart(DOPin, CLKPin, DIPin, CSPin, -1,-1,-1,-1,-1)
    \fat0.mountPartition(0)
    \fat0.listEntries("W")
     
    repeat while(result := fat0.listEntries("N"))
                
        ifnot \fat0.listIsDirectory
            ' Only display files with valid default CNC extensions
            repeat tmp2 from 0 to 11                ' Zero terminate
                if byte[result+tmp2]==32
                    byte[result+tmp2]:=0                            
            bytefill(@Block,0,5)                   
            bytemove(@Block,Result+strsize(Result)-4,4)
            UCase(@Block)
            if (strcomp(@Block,@ValidExt) and strsize(@ValidExt))
                ser.position(((tmp & 3)*15)+10, (tmp / 4)+3)             
                ser.str(result)
                tmp++
     
    \fat0.unmountPartition

    WhiteOnRed
    FillZone(1,1,1,33)
    PosString(@MainText_12)
    ser.ShowCursor             
     
    bytefill(@block,32,12)
    byte[@block][12]:=0        
     
    GetString(@block,12,0)  ' get the file name
    result:=-1
    
    if ((byte[@block]<> 32) and strsize(@Block))
     
        ' Add default extension if one doesn't exist
        tmp:=0
        repeat tmp2 from 0 to 11
            if byte[@block+tmp2]=="."
                tmp++
                
            if byte[@block+tmp2]==" "
                byte[@block+tmp2]:=0
                
        if tmp==0   ' Add default extension
            bytemove(@block+strsize(@block),@ValidExt,5)
        UCase(@block)    
         
        GreenOnBlack
         
        FillZone(21,1,1,13)
         
        ser.str(@block)
        result:=exists(@Block,none)
         
PRI Exists(FileNameAddress,Action) | ErrMsg
' Check to see if file with name pointed to by FileNameAddress exists.
' Delete it if it exists and Action == Delete
' Run it if it exists and Action = Boot
' Creates a single line empty file if Action = Create, returns error if file already exists.
' Return zero if action = successful / file exists.
' Return error string if failure

    \fat0.fatEngineStart(DOPin, CLKPin, DIPin, CSPin, -1,-1,-1,-1,-1)

    \fat0.mountPartition(0)        

    ErrMsg:=\fat0.OpenFile(FileNameAddress, "R")
    result:=fat0.PartitionError ' returns non-zero if error occured

    \fat0.closefile
    
    if result==0 ' File exists, what to do?
        case Action
            Boot:
            
               \fat0.bootPartition(FileNameAddress)
               
            Delete:
                \fat0.deleteEntry(FileNameAddress)

            Create:
                result:=14 ' File already exists            
                
    else
        if Action==Create            
            ErrMsg:=\fat0.newFile(FileNameAddress) ' Create and open
            ErrMsg+=\fat0.openFile(FileNameAddress,"W")
            fat0.WriteByte(" ")
            \fat0.closefile
             
        result:=ErrMsg

    \fat0.unmountPartition
        
PRI EditFile(FilePtr) | BlockLength, tmp, Line, Col, FileLines, InsertMode, LineWidth, LastLine, TopLine, UsedLines, NumLock, OIM
' Make a backup of the original file.
' Edit the file.
' Return to calling routine.
   
    ser.hidecursor
    GreenOnBlack
    ser.clear
    ser.home
    
    ser.str(string(27,"[1;"))'ser.str(string(27,"[5;")) ' ser.str(string(27,"[6;25r",27,"="))
    ser.dec(EditorLines+1)'ser.dec(5+EditorLines)
    ser.char("r")
'    ser.str(string("r",27,"="))' Define window, Application Keypad mode

    ser.position(1,25)
    ser.str(string("L      C        NUM  Lines       Width      Char=    (   )"))
    PosString(@NumOff_Msg)
  
    fat0.fatEngineStart(DOPin, CLKPin, DIPin, CSPin, -1,-1,-1,-1,-1)
    fat0.mountPartition(0)
    fat1.mountPartition(0)
    \fat1.deleteEntry(@ScratchFile)                       
    \fat0.openFile(FilePtr, "R")
    \fat1.newFile(@ScratchFile) ' Create and open
    \fat1.openFile(@ScratchFile,"W")

    line:=0
    col:=0
    FileLines:=0
    UsedLines:=0
    TopLine:=0
    NumLock:=0  ' Start with NumLock OFF = Application Keypad Mode Active
    Changed:=0  ' Flag that the line has been changed
    
    ' Copy file to our temp file, each line is 60 wide, no CR/LF in temp file    
    repeat
        bytefill(@Block,0,BufferSize+1) 
        result:=byte[fat0.readstring(@Block,BufferSize)]
        if result
            repeat tmp from 0 to BufferSize-1
                if byte[@Block+tmp]<32
                    byte[@Block+tmp]:=32                    
            FileLines++
            if UsedLines<EditorLines
                ser.position(1,1+line++)
                ser.str(@Block)
                UsedLines++
                
            fat1.writeData(@Block,BufferSize)
            ShowFileLines(FileLines)
            
        else
            if FileLines==0 ' Add one blank line to an empty file
                FileLines++
                bytefill(@Block,0,BufferSize+1)
                ser.position(1,1+line++)
                ser.str(@Block)
                UsedLines++
                fat1.writeData(@Block,BufferSize)
                ShowFileLines(FileLines)                
            quit

    \fat0.CloseFile                            ' Close file        
    \fat1.CloseFile                            ' Close file        
    \fat1.unmountPartition                            ' Close file        
  
    \fat0.openFile(@ScratchFile, "A")

    
'    ser.ShowCursor
    LastLine:= -1       ' flag to load first line
    Line:=0
    InsertMode:=1
    OIM:=-1             ' flag to display insert mode 
    FileLines--
    
    
    repeat
    
        LineWidth <#= BufferSize-1    ' Limit current line width to buffer size                    
        line #>= 0                  ' Limit line number to beginning of file
        line <#= FileLines          ' Limit line to end of file

        ifnot OIM==InsertMode
            OIM:=InsertMode
            ser.position(13,25)
            if InsertMode
                RedOnWhite
                ser.str(string("INS"))
            else
                WhiteOnRed                
                ser.str(string("OVR"))
            GreenOnBlack

        ifnot LastLine==line        

            ifnot LastLine==-1
                SaveLine(LastLine)

            GetLine(line)        
            LineWidth:=FindLineWidth(0) ' calculate line width with (0)
            LastLine:=line
            ser.position(1,line+1-TopLine)
            ser.str(@block)


        if Line==(TopLine+EditorLines)
            TopLine++
            ser.position(1,EditorLines+1)
            ser.str(string(13,10))
            ser.position(1,EditorLines)
            ser.str(@Block)

        if line<TopLine
            TopLine--
            result:=line
            repeat EditorLines    
                if result=<FileLines
                    GetLine(result)        
                    ser.position(1,result+1-topline)
                    ser.str(@block)
                    result++
            GetLine(line)        


        Col #>=0                    ' Limit Column to 1st
        Col <#= LineWidth           ' Limit Column to line width

        ser.position(2,25)
        ser.Dec(line+1)
        ser.chars(32,2)

        ser.position(9,25)
        ser.Dec(col+1)
        ser.chars(32,2)

        ShowFileLines(FileLines)                
        
{
L      C    INS NUM  Lines     Width      Char=    (   )"))
}
        ser.position(50,25)
        ser.chars(34,3) ' """
        ser.position(51,25)
        ser.char(byte[@Block+Col])
        ser.position(55,25)
        ser.Dec(byte[@Block+Col])
        ser.str(string(") "))

'       ser.position(62,25)
'       ser.str(string("c:"))
'       ser.Dec(col)
'       ser.str(string(" w:"))
'       ser.Dec(Linewidth)
'       ser.str(string(" l:"))
'       ser.Dec(Line)
'       ser.str(string(" tl:"))
'       ser.Dec(TopLine)
'       ser.str(string(" fl:"))
'       ser.Dec(FileLines)
'       ser.chars(32,5)

        ser.position(col+1,line+1-TopLine)
        ser.ShowCursor
        ser.RXflush        
        repeat  ' Wait for key press
            result:=GetKey
        while result == -1

        ser.hidecursor        

        case result

            26:     ' ctrl-Z = undo
                if changed
                    LastLine:=-1
                    Col:=0                

            412: ' Insert
                InsertMode^=1

            380: ' NumLock = Toggle Application Keypad Mode
                NumLock^=1
                if NumLock
                    PosString(@Num_Msg)
                else                
                    PosString(@NumOff_Msg)

            413: ' End
                col:=LineWidth                   

            415: ' 3, Page Down
                LastLine := -1
                SaveLine(line)            
                line += EditorLines-1

                if line > FileLines
                    line := FileLines

                result:=Topline                
                TopLine += EditorLines-1

                if TopLine > FileLines
                    Topline:=result                

                result:=Topline                

                repeat EditorLines
                    ser.position(1,result+1-topline)
                    if result =< FileLines
                        GetLine(result++)
                        ser.str(@block)
                    else
                        result++
                        ser.chars(32,BufferSize)                                                       
                GetLine(line)        
                
                
            368,416: ' 4, Left Arrow
                col--
                if ((col<0) and (line>0))
                    line--
                    col:=BufferSize+1                

            367,418: ' 6, Right Arrow
                col++
                if ((col>LineWidth) and (line<FileLines))
                    line++
                    Col:=0

            419: ' Home
                col:=0
            
            366,414: ' 2, Down Arrow    
                line++

            365,420: ' 8,Up Arrow
                line--

            421: ' 9, Page Up
                LastLine := -1
                SaveLine(line)            
                line -= EditorLines-1

                line #>=0                
                
                result:=Topline                
                TopLine -= EditorLines-1

                TopLine #>=0                

                result:=Topline                

                repeat EditorLines
                    if result =< FileLines
                        GetLine(result++)        
                        ser.position(1,result-topline)
                        ser.str(@block)
                GetLine(line)        
             
             
            13,377: ' Enter
                changed~~
                if InsertMode   ' Insert on
                    SaveLine(line)

                    ' Slide all lines below this line down 1 line
                    repeat result from FileLines to line
                        GetLine(result)
                        changed~~        
                        SaveLine(result+1)

                        if (((result-TopLine+1)=>0) and ((result-TopLine+1)<EditorLines))
                            ser.position(1,result+2-TopLine)
                            ser.str(@block)

                    ' Shift everyting right of cursor to the left
                    bytemove(@Block,@Block+Col,BufferSize-col)
                    bytefill(@Block+BufferSize-Col,32,col)
                    changed~~
                    SaveLine(line+1)
                    if (((line-TopLine+1)=>0) and ((line-TopLine+1)<EditorLines))
                        ser.position(1,line+2-TopLine)
                        ser.str(@block)

                    ' Fill everyting after cursor with spaces
                    GetLine(line)
                    changed~~        
                    bytefill(@block+col,32,BufferSize-col)
                    if (((line-TopLine)=>0) and ((line-TopLine)<EditorLines))
                        ser.position(1,line+1-TopLine)
                        ser.str(@block)
                    
                    LastLine:=Line                                                
                    FileLines++
                    
                       
                line++
                col:=0
            
            27: ' Escape
                SaveLine(line)
                quit

                                                     

            8,410:  ' Backspace & delete
                changed~~
                if result==410 ' treat delete like backspace but 1 column to the right
                    if ((col == LineWidth) and (line < FileLines)) ' Append lower line with this line, shift lower lines up
                        SaveLine(line)
                        col:=0 ' make it look like we are doing a BS in the 1st col of the next line
                        GetLine(++line) 'get next line                        
                    else
                        if col==LineWidth ' Can't delete, nothing to drag up
                            LineWidth++
                        col++            

                if col>0 ' backspace                
                    bytemove(@Block+col-1,@Block+Col,BufferSize-col)
                    byte[@Block+BufferSize-1]:=32

                    if (((line-TopLine)=>0) and ((line-TopLine)<EditorLines))
                        ser.position(1,line+1-TopLine)
                        ser.str(@block)
                    LineWidth--
                    col--

                else    ' Add this line to end of the previous line
                    if line
                        result:=FindLineWidth(0) ' find length of lower line with (0)
                        LastLine:=-1
                        GetLine(--line)          ' get upper line into buffer                                       
                        LineWidth:=FindLineWidth(0) ' find length of upper line with (0)
                    
                        ' read as much of lower line into end of buffer
                        fat0.fileseek((line+1)*BufferSize)
                        fat0.readData(@block+LineWidth,BufferSize-LineWidth)
                        changed~~                        
                        SaveLine(line)
                        if (((line-TopLine)=>0) and ((line-TopLine)<EditorLines))
                            ser.position(1,line+1-TopLine)
                            ser.str(@block)
                        col:=LineWidth

                        if (result+LineWidth)=<BufferSize
                            ' we moved the entire lower line up to the end of the upper line. 
                            ' Shift all lower lines up by 1
                            if (line+1) < FileLines
                                repeat tmp from Line+1 to FileLines-1
                                    GetLine(tmp+1)    
                                    changed~~
                                    SaveLine(tmp)
                                    if (((tmp-TopLine)=>0) and ((tmp-TopLine)<EditorLines))                                
                                        ser.position(1,tmp+1-TopLine)
                                        ser.str(@block)
                         
                            FileLines--
                            if (((FileLines-TopLine+1)=>0) and ((FileLines-TopLine+1)<EditorLines))                            
                                ser.position(1,Filelines+2-TopLine)
                                ser.chars(32,BufferSize)
                                                        
                        else
                                
                            GetLine(line+1)                        
                            ' Shift everything that didn't fit in the upper line LEFT
                            result:=BufferSize-LineWidth
                            bytemove(@Block,@Block+result,BufferSize-result)
                            bytefill(@Block+BufferSize-result,32,result)
                            if (((line-TopLine+1)=>0) and ((line-TopLine+1)<EditorLines))                        
                                ser.position(1,line+2-TopLine)
                                ser.str(@block)  ' display the remainder of the lower line 
                            changed~~
                            SaveLine(line+1)
                                   


                LineWidth:=FindLineWidth(LineWidth) ' Don't calculate, just display                                        
                                    
            other:
                if ((result=>32) and (result<127) and (linewidth<BufferSize-1))
                    changed~~ 
                    if InsertMode   ' Insert on
                        bytemove(@Block+col+1,@Block+Col,BufferSize-col-1)
                        byte[@Block+col]:=result
                        ser.position(col+1,Line+1-TopLine)
                        ser.str(@block+col)
                        FindLineWidth(++LineWidth)                        
                        
                    else
                        byte[@Block+Col]:=result
                        ser.char(result)
                         
                    col++
                    if col>LineWidth
                        LineWidth++

                else ' Display unhandled key code in lower right-hand corner.
                    ser.position(76,25)
                    ser.dec(result)
                    ser.chars(32,3)
'                    ser.beep        
    

    MsgBox(35,10, @MsgSaveFile, 0)


    ' Close temp file &  write back to original file
    \fat0.CloseFile                            ' Close file

    \fat1.mountPartition(0)

    ' Delete any backup file that exists
    FNParse(FilePtr) ' Copy padded filename to ShortBuf

    bytemove(@ShortBuf+9,@BackupExt,3)
    \fat1.deleteEntry(@ShortBuf)                    


    'rename original file as backup file
    \fat0.moveEntry(FilePtr,@ShortBuf)

    ' make sure that target file is deleted
    \fat1.deleteEntry(FilePtr)                       

    ' Copy contents from scratch file to target file
    \fat0.openFile(@ScratchFile,"R")
    \fat1.newFile(FilePtr) ' Create and open
    \fat1.openFile(FilePtr, "W")
    
    LastLine:=0
    repeat LastLine from 0 to FileLines
        \fat0.readData(@block,BufferSize)
        LineWidth:=FindLineWidth(0)


        if LastLine =< FileLines
            byte[@Block+LineWidth++]:=13
            byte[@Block+LineWidth++]:=10

        byte[@Block+LineWidth]:=0

        \fat1.writeString(@Block)
        ShowFileLines(LastLine+1)        
        
    fat1.WriteByte(0)    


    \fat0.CloseFile                            ' Close file        
    \fat1.CloseFile                            ' Close file        
    fat1.unmountPartition                            ' Close file

    ' Delete temp file
    \fat0.deleteEntry(@ScratchFile)                

    fat0.unmountPartition                            ' Close file

    ser.str(string(27,">")) ' Cancel Application Keypad mode        

PRI ShowFileLines(FileLines)
    ser.position(28,25)
    ser.Dec(FileLines+1)
    ser.char(32)

PRI FNParse(Source)
'Put padded filename into Shortbuf from Source memory address
' Splits up file.ext into "file____.ext"

    bytemove(@ShortBuf,Source,12)

    repeat result from 0 to 7
        if byte[Source+result]=="."
            bytemove(@ShortBuf+9,Source+result+1,3)
            bytefill(@ShortBuf+result,32,8-result)
            byte[@ShortBuf+8]:="."

    byte[@ShortBuf+12]:=0

PRI GetLine(line)

    fat0.fileseek(line*BufferSize)
    fat0.readData(@block,BufferSize)
    changed~


PRI SaveLine(line)
    
    if changed~
        if ((line*BufferSize)=>fat0.fileSize)
            fat0.writeString(@Block)
         
        else 
            fat0.fileseek(line*BufferSize)
            fat0.writeData(@Block,BufferSize)

PRI FindLineWidth(Width) | tmp
' find width of this line
' but only if Width = 0, otherwise
' just display the Width value

    ifnot Width    
        Result:=0
        repeat tmp from Buffersize-1 to 0
            ifnot byte[@Block+tmp] == 32
                Result:=tmp+1
                Result <#= BufferSize                
                quit
    else
        result:=Width

    ser.position(40,25)
    ser.Dec(Result+1)
    ser.char(32)
    
PRI ProcessFile(FilePtr) | TermLine

' This routine opens & runs a CNC file from the SD memory card.

    DispPos
    fat0.unmountPartition                            ' Close file        

    repeat

        GreenOnBlack
        ser.str(string(27,"["))
        ser.dec(ProgWinTop)
        ser.str(string(";25r"))' Define window Starting at line 6 through line 25
        SerLine:=ProgWinTop
        ser.position(1,SerLine)
        GMode1:=-1
        F:=0
         
        OpenFile(FilePtr)                ' Open file for reading.
        Interrupt:=0                                        ' Re-Enable interrupt
        TermLine:=0             ' add'l bias to terminal line when processing lines from screen
        NoScroll:=0
        DrawHeader
        ProcessPtr:=0
         
        repeat
            ifnot NoScroll
                NoScroll:= (OpenShow==0)                                 ' Initial screen fill
                            
            if NoScroll
                ser.position(1,ProgWinTop-1+TermLine)
                ser.ClearEnd ' erase previous line
                ser.position(1,ProgWinTop-1+TermLine+1)                  ' Highlight line to process
            else
                ser.position(1,ProgWinTop-1+TermLine)                    ' Highlight line to process

            ser.ClearEnd
            ser.str(string(27,"[37m")) ' White text
            
            ' Read next line, returns 0 if done with file
            ProcessPtr:=ReadFileLine(ProcessPtr)                ' read line and set pointer to next line to read
            if ProcessPtr==-1
                quit
            
            ser.str(@Block)

             if (OpMode==SingleBlock or OpMode == StartHold)
                PosString(@Holding)

                Interrupt:=-1                               ' Disable Interrupt
                repeat
                    DispPos            
                    result:=GetKey
                    if result==27
                        TriggerInterrupt
                        HandleInterrupt
                        result:=32

                while result == -1
                
                 Interrupt:=0                               ' Enable Interrupt
                
                if result == 27
                    if OpMode==StartHold
                        ProcessPtr:=0
                        quit

                if (result & %1101_1111) == "S"             ' While holding, user can type S to single block
                   OpMessage(@OpMsgSingleBk)
                   OpMode:=SingleBlock                

                FillZone(21,2,2,7)

                ser.RXFlush
                if OpMode == StartHold
                    OpMode := Auto

            GreenOnBlack
            ReadBlock                                           ' Read Bock, process if not 0
            ProcessBlock
            if NoScroll
                ser.str(string(27,"[32m")) ' Green text            
                ser.position(1,ProgWinTop+0+TermLine)                          ' Highlight line to process
                ser.ClearEnd
                TermLine++
            else
                fat0.FileSeek(FileReadPos)                             ' Read next line

            if ((OpMode==stop) or (OpMode==Restart))

                if OpMode==Restart
                    ser.clear
                    OpMode:=StartHold
                quit    

            ser.position(1,TerminalLines)                       ' Read in next line to display a bottom of screen
            SerLine--
            ser.str(string(27,"[32m")) ' Green text

        if OpMode==0
            quit

        if ProcessPtr < 1
            GreenOnBlack
            FillZone(21,2,2,8)
        
            if ProcessPtr < 0        
                OpMode:=Stop
            else
                OpMode:=StartHold
            DispPos            
            quit       

    fat0.unmountPartition                            ' Close file
    DisableDrives


PRI ProcessBlock | slen , cmd, disp, Char, FValue, IValue, Operation, bias, bit

    slen := strsize( @block )-1
    if slen > 0
        slen:=@block

        
        Operation:=0                            ' Operation to perform (like G92)
        disp:=0
                                                          
        U:=V:=W:=0
        I:=J:=K:=0

        if IncAbs==90   ' Absolute Values
            X:=s_FromX   
            Y:=s_FromY   
            Z:=s_FromZ

        else    ' G91 = Incremental values
            X:=Y:=Z:=0
            
        
        repeat
            cmd:=TokenizeString(slen)
            slen:=0
            FValue:=fs.StringToFloat(cmd+1)     ' Floating Point Value
            IValue:=fm.FTrunc(FValue)           ' Integer Value

            case byte[cmd]
                "X","Y","Z":
                    long[@X + ((byte[cmd]-"X")*4)]:=FValue    ' X,Y & Z Coordinates
                    disp += |< (byte[cmd]-"X")

                "I","J","K":
                    long[@I + ((byte[cmd]-"I")*4)]:=FValue    ' I,J & K Coordinates

                "R": R:=FValue                  ' R Coordinate
                "F": F:=FValue                  ' Feed Rate (IPM)

                "U","V","W":
                    long[@U + ((byte[cmd]-"U")*4)]:=FValue    ' U,V & W Coordinates
                    disp += |< (byte[cmd]-"U")
                
                "G":                            ' Preparatory Funcions
                    case IValue
                        0:  GMode1:=0           ' G00 Rapid Movement                        
                        1:  GMode1:=1           ' G01 Linear Interpolation
                        2:  GMode1:=2           ' G02 Circular Interpolation - CW
                        3:  GMode1:=3           ' G03 Circular Interpolation - CCW
                   '    4:  Dwell               ' Dwell xxx Milliseconds
                   '    17: XY_Plane            ' Circular Interpolation Plane Select (G18 ZX & G19 YZ not supported yet)
                   '    28: ReturnToRef         ' 
                   '    29: ReturnFromRef

                       54..59:                  ' Select Work Offset Coordinate System G54 to G59
                            WorkOffset:=IValue
                            ApplyWorkOffset                                                                          

                   '    80: CancelCanned
                   '    81: DrillCannedCycle

                       90,91:                   'Incremental / Absolute Mode
                            IncAbs:=IValue
                        
                       92:                     ' Set Absolute Position
                            Operation:=IValue    
                                                
                "M":                            ' Miscellaneous Functions            
                   ' case IValue
                   '    0: Stop
                   '    1: OptionalStop
                   '    2: End
                   '    3: SpindleForward
                   '    4: SpindleReverse
                   '    5: SpindleStop
                   '    6: ToolChange
                   '    8: CoolantOn
                   '    9: CoolantOff
                   '   30: Program End, Rewind
                    
                "S": S:=IValue                  ' Spindle Speed
        while strsize(cmd)                      ' Process all addresses within this block                


        Case Operation
            0:
                if GMode1 > -1                
                    ser.Position(42,2)
                    ser.char("G")
                    ser.Dec(GMode1)

                if ((GMode1>0) and (F==0))
                    ser.beep
                    OpMessage(@OpMsgNoFR)
                    MsgBox(45,15, @MsgPressKey, 1)
                    fat0.unmountPartition                            ' Close file                    
                    abort

                repeat result from 0 to 2
                
                    bias:=result*4
                    bit:= |< result
                                        
                    long[bias+@s_ToX]:=long[bias+@s_FromX]
                    
                    if IncAbs==91 ' Incremental values
                        long[bias+@X]:=fm.FAdd(long[bias+@X],long[bias+@s_FromX])
                        
                    if (Disp & bit)
                    
'                        ifnot (OffsetActive & bit) ' turning on the offset                         
'                            OffsetActive |= bit
'                            long[bias+@s_FromX]:=fm.FSub(long[bias+@s_FromX],long[bias+@OffsetX])
                                                                                 
                        long[Bias+@s_ToX]:= fm.FAdd(long[bias+@X],long[bias+@U])                        

                if disp  ' Only move if X,Y,Z,U,V or W have been updated
                
                    repeat result from 0 to 2
                        bias:=result*4
'                        if (OffsetActive & (|< result)) ' selectively apply work offsets
                            long[bias+@s_ToX] :=  fm.FAdd(long[bias+@s_ToX],long[bias+@OffsetX])
                            long[bias+@s_FromX]:= fm.FAdd(long[bias+@s_FromX],long[bias+@OffsetX])                                                     
                                                    
                    case GMode1
                        0:  Lin(Var_Rapid,YesOTError,0)
                        1:  Lin(F,YesOTError,0)
                        2:  Cir(CW) 
                        3:  Cir(CCW)

                    repeat result from 0 to 2
                        bias:=result*4
'                        if (OffsetActive & (|< result))
'                           long[bias+@s_ToX] :=  fm.FSub(long[bias+@s_ToX],long[bias+@OffsetX])
'                           long[bias+@s_FromX] := fm.FSub(long[bias+@s_FromX],long[bias+@OffsetX])                        
                            long[bias+@s_FromX]:= fm.FSub(fm.FDiv(fm.FFloat(long[Bias+@s_XAt]),Var_SPI),long[bias+@OffsetX])                           


                if s_State==-2 ' Overtravel
                    s_State:=0
                    OpMode:=ReStart
                                 
            92:
                SetG92(X,Y,Z)
'                repeat result from 0 to 2
'                    bias:=result*4                
'                    long[bias+@s_FromX] := long[bias+@s_ToX] :=  long[bias+@X]
                    
                               
PRI SetG92(SX,SY,SZ) | bias
' Set G92X,G92Y & G92Z to preset values
' Calculate the G92 X,Y & Z from commanded position & actual position
' G92 = (Machine Position - G5x value)-Specified position)
    repeat result from 0 to 2
        bias:=result*4
        long[bias+@G92X] := fm.FSub(fm.FSub(fm.FDiv(fm.FFloat(long[bias+@s_XAt]),Var_SPI),long[bias+@Var4+((WorkOffset-54)*12)]),long[bias+@SX])

'    OffsetActive :=%111     ' Signal that the offsets have been applied

    ApplyWorkOffset    
'debug
'    repeat result from 0 to 2
'        bias:=result*4                
'        long[bias+@X] := fm.FSub(fm.FDiv(fm.FFloat(long[bias+@s_XAt]),Var_SPI),long[bias+@OffsetX])

    repeat result from 0 to 2
        bias:=result*4                
        long[bias+@s_FromX] := long[bias+@s_ToX] :=  long[bias+@X]

    disppos        

PRI ApplyWorkOffset | tmp, bias

    repeat tmp from 0 to 2
        bias:=(4*tmp) 
        long[bias+@OffsetX]:=fm.FAdd(long[bias+@Var4+((WorkOffset-54)*12)],long[bias+@G92X])
'        ser.Position(44,2+tmp)
'        ser.str(fs.FloatToFormat(long[Bias+@OffsetX],9,4))
'        if (OffsetActive & (|< result)) ' selectively apply work offsets
            long[bias+@s_FromX]:= fm.FSub(fm.FDiv(fm.FFloat(long[Bias+@s_XAt]),Var_SPI),long[bias+@OffsetX])                                           

'    ser.Position(53,1)
'    ser.char("4"+WorkOffset-54)
    ShowWorkOffset(WorkOffset-54)
    DispPos

PRI ShowWorkOffset(offset) | tmp, bias
'Display the work offset number and the offset values on the main screen
' enter with 0 - 6

    ser.Position(51,1)
    ser.str(string("G5"))
    ser.char("4"+offset)

    repeat tmp from 0 to 2 ' Display current work offsets
        bias:=(4*tmp) 
        ser.Position(44,2+tmp)
        ser.str(fs.FloatToFormat(long[bias+@Var4+(offset*12)],9,4))

    
PRI lin(Feed,IgnoreOT_Error,OT_AxisMask)
' Set s_FromX, s_FromY & s_FromZ = starting point (Float)
' Set X, Y & Z ending point (Float)
' Enter with Feed = Inches Per Minute (Float)  -(IPM) for no feed rate override
' Enter with IgnoreOT_Error = 1 to not throw an overtravel message, 0 to throw an overtravel error message
'   If 1, all other axis will continue moving if an OT occurs on an axis.
' Enter with OT_AxisMask = pin numbers set to 1 for axis to watch. When port ANDed with OT_AxisMask == 0
'   then this routine will abort (Used in homing). 

    s_SPM   := ||Feed                   ' Absolute value, Negative feed bypasses feedrate override
    OT_Mode := IgnoreOT_Error           ' Do we ignore an Overtravel Error Message 0=no, 1=yes
    s_State := 1                        ' 1 is the code to trigger the Linear Interpolation COG to start moving
    
    repeat while s_State        ' will be cleared (Y the PASM COG) to 0 when the move is done.

' debugging 
'        ser.position (1,24)
'        ser.hex(debugvar1,8)
'        ser.char(",")
'        ser.dec(debugVar2)
'        ser.char(",")
'        ser.dec(debugVar3)
'        ser.char(",")
'        ser.dec(debugVar4)
'        ser.char(",")
'        ser.dec(debugVar5)
'        ser.position (51,24)
'        ser.charin
'        waitcnt(clkfreq*3+cnt)        
'        debugVar6:=0
'        ser.str(string(13,10))
' debugging 
    
        DispPos
        
        if s_State==OTCode          '    -100 = Overtravel Abort Code
            if IgnoreOT_Error==YesOTError
                overtravel
            quit

        ' Check to see if all axis are at Home
       if ((IgnoreOT_Error==NoOTError) and (((ina[Z_OT_Neg..0] ^ Var_Polarity) & OT_AxisMask)==0)) ' Yes all are home
            s_State := OTCode
            quit

    FinishMove


PRI Cir(_Dir)
' Enter with s_FromX & s_FromY = starting point (Float)
' Enter with X, Y & Z ending point (Float) (Circular Interpolation with Helical-Z)
' Enter with I & J = distance from starting point to center of arc (Float)
' Enter with _Dir = -2 for Clockwise or 2 for Counter-Clockwise, 0 for no move
' Enter with Feed = Inches Per Minute (Float)  -IPM for no feed rate override

'    repeat result from 0 to 2
'        if (OffsetActive & (|< result)) ' selectively apply work offsets
'            long[(result*4)+@s_ToX] :=  FM.FAdd(long[(result*4)+@s_ToX],long[(result*4)+@OffsetX])

    s_I     := I
    s_J     := J
    s_K     := 0
    s_SPM   := F 
    
'    CX:= (fm.FRound(Fm.FMul(CX,fm.FFloat(10000))) * fm.ftrunc(Var_SPI))/10000 ' StepsPerInch
'    CY:= (fm.FRound(Fm.FMul(CY,fm.FFloat(10000))) * fm.ftrunc(Var_SPI))/10000 ' StepsPerInch

    OT_Mode := YesOTError           ' Do we ignore an Overtravel Error Message 0=no, 1=yes
    s_State := _Dir                 ' Start moving Y setting the direction status to either -2 / +2 signalling the start of a move.


    repeat while s_State       ' will be cleared (Y the PASM COG) to 0 when the move is done.
        DispPos
        if s_State==OTCode          '    -100 = Overtravel Abort Code
            overtravel
            quit            

    FinishMove


PRI FinishMove | bias 

    repeat result from 0 to 2
        bias:=result*4        
        long[Bias+@s_FromX]:=fm.FDiv(FM.FFloat(long[Bias+@s_XAt]),Var_SPI) 

    DispPos

    if s_State==OTCode              '    -100 = Overtravel Abort Code
        s_State:=0                  ' Clear error
        OpMode:=ReStart
        fat0.unmountPartition                            ' Close file
        abort
           
    else
        if Interrupt > 0
            HandleInterrupt

PRI DispPos  | SerialCommand, tmp, bias, Position
' Display coordinates
' Read A/D converter & display feed rate override
' If Feed is negative, the feed rate override is ignored

    GreenOnBlack
    repeat tmp from 0 to 2
        bias:=4*tmp 

        ser.Position(56,2+tmp)  ' Machine
        ser.str(fs.FloatToFormat(Position:=FM.FDiv(FM.FFloat(long[Bias+@s_XAt]),Var_SPI),9,4))

        ser.Position(69,2+tmp)  ' Work

'        if (OffsetActive & (|< tmp)) ' selectively de-apply work offsets
            ser.str(fs.FloatToFormat(FM.FSub(Position,long[Bias+@OffsetX]),9,4))
'            ser.char("*")
'        else
'            ser.str(fs.FloatToFormat(Position,9,4))
'            ser.char(" ")

ser.position(1,1)   ' display ring buffer usage
'result:=BufferUsed
'if result<0
'    result:=OutBuffer#BUFFER_LENGTH+result
ser.decpad(BufferUsed,5)


    ser.Position(38,3)
    ser.str(fs.FloatToFormat(F & AbsFloat,6,1))    ' Feed Rate
    
    ' Read A/D converter
    lHex:=read(ADAddress & 255, 0, 0,16) ' NOTE: Must set R/W bit to 1 since we don't use an address register (*)
    qValue:=(lHex >> 15) & 1' Pad upper 19-bits with sign bit
    qValue:=qValue * %1111_1111_1111_1111_1111_0000_0000_0000
    qValue:=qValue + (lHex & %1111_1111_1111)
    qValue:= qValue+1024
    qValue #>= 0
    s_PotRaw:=qValue         
    s_PotScale:=fm.FMul(fm.FDiv(fm.FFloat(s_PotRaw),204800.0),Var_Override) ' A value between 0 and 2.0 for 200% override

    ser.Position(38,4)
    ser.str(fs.FloatToFormat(fm.FMul(s_PotScale,100.0),5,0))
    ser.char("%")

'ser.Position(18,5)
'ser.str(fs.FloatToFormat(DebugVar1,8,6))

'ser.Position(28,5)
'qValue:=DebugVar3 & %1111_1100_0000_0000_0000_0000_0000_0000
'qValue:=(DebugVar3 >> 26)
'ser.bin(qValue,6)

'ser.Position(38,5)
''ser.Position(1,25)
'qValue:=DebugVar3 & %0000_0011_1111_1111_1111_1111_1111_1111
''qValue:=qValue/15000
''ser.chars("*",qValue)
'ser.DecPad(qValue,9)
''ser.str(string(13,10))


'ser.Position(48,5)
'ser.DecPad(DebugVar4,8)
'ser.chars(32,8)

'ser.Position(58,5)
'ser.DecPad(DebugVar6-DebugVar5,8)
'ser.chars(32,8)

    

    if Interrupt==0
        if ser.RXCheck <> -1    ' key pressed on terminal
            TriggerInterrupt
    else
        if Interrupt == 11
            if ser.RXCheck == 27      ' Check for ESCape key pressed on terminal
                OpMessage(@OpMsgESTOP)
                s_State:=OTCode              '    -100 = Overtravel Abort Code
                GreenOnBlack
                FillZone(58,13,16,20)    
                
                MsgBox(35,15, @MsgPressKey, 1)
                FinishMove



PRI TriggerInterrupt

    WhiteOnRed
    MsgBox(58,13, @Menu3, 0)
    Interrupt:=11   ' line number to display message on
    OpMessage(@OpMsgFinish)

PRI HandleInterrupt | tmp
    
    OpMessage(@OpMsgErase)

    repeat

        PosString(@MenuPrompt)                    
        ser.position(72,16)        ' Position cursor for input
        GreenOnBlack
        ser.ShowCursor
        bytefill(@ShortBuf,32,4)
        GetString(@ShortBuf,4,0)   ' Yes/no response

        case byte[@ShortBuf]
         
            "1":                                                ' Continue Auto
                OpMessage(@OpMsgAuto)
                OpMode:=Auto
                quit
                                                                ' Single Block
            "2":
                OpMessage(@OpMsgSingleBk)
                OpMode:=SingleBlock
                quit
         
            "3":                                                ' Stop at EOB
                OpMessage(@OpMsgIdle)
                OpMode:=Stop
                EOF:=1
                DisableDrives
                quit
            
        
    GreenOnBlack
    FillZone(58,13,16,20)    

    Interrupt:=0

PRI ReadBlock  | Tmp, SkipToEOB, DestBlockPtr
' Read block from the string buffer
' Make sure there are spaces delimiting each address
' Return 0 if comment block or zero-length block

    DestBlockPtr:=0
    SourceBlockPtr:=0
    SkipToEOB:=0
    Result:=0
    LastChar:=" "

    repeat
        tmp:=GetChar
        if tmp==0
            quit


        if (tmp==13 or tmp==10)
            byte[@block][DestBlockPtr]:=13            
            byte[@block][++DestBlockPtr]:=0  ' Null Terminate end of block string            
            
            if ((SkipToEOB == 0) and (DestBlockPtr > 0))
                result:=1
            quit
        else

            if tmp == "("               ' Skip everything within this comment up to the EOL
                SkipToEOB := 1
                
            if SkipToEOB==0
                if tmp => 32
                    byte[@block][DestBlockPtr++]:=tmp
                    DestBlockPtr <#= (BufferSize-1)
                


PRI GetChar
'Get next character from buffer.
'Make sure there is a delimiting SPACE between addresses, insert if necessary.
   
    if BufferedChar
        result:= BufferedChar
        BufferedChar:=0

    else

        result:=byte[@block][SourceBlockPtr++]
        
        if result=="("
            InComment:=1
            
        if InComment==0
            case result
                "G","X","Y","Z","T","F","M","U","V","W","R","I","J","K","S","N":
                    if LastChar<> " "
                        BufferedChar:=result
                        result:=" "
                
        case result
            10..13:
                InComment:=0
            
    LastChar:=result
    



PRI OpenShow | tmp
' Read blocks from open file.
' If screen is full, only read next line, display it at bottom & scroll screen up
' returns 0 if EOF
 
    repeat until SerLine>TerminalLines      '6+ > 25
        result:=byte[fat0.readstring(@Block,BufferSize-1)]

        if result 
            ser.position(1,SerLine++)
                           
            ser.str(@Block)
            if SerLine > TerminalLines
                FileReadPos:=fat0.FileTell
                quit
        else
            quit

PRI ReadFileLine(FilePos)
' Read next line from open file
' return 0 if EOF

    fat0.FileSeek(FilePos)
    result:=long[fat0.readstring(@Block,BufferSize-1)]    
    if result
        result:=fat0.Filetell
        
    if fat0.Filetell == fat0.FileSize
        result:=-1
        NoScroll:=1


PRI HomeMachine | Pos, OTValue, Delta
{
    Send all axis in the + Direction until each hit the +Limit switch (Home)
    When all are tripped, reset each axis counter to 0 and return

    X_OT_Pos        = 10    ' X Overtravel Positive & Home     (Normally HIGH, Active LOW)
    X_OT_Neg        = 11    ' X Overtravel Negative Direction  (Normally HIGH, Active LOW)
    Y_OT_Pos        = 12    ' Y Overtravel Positive & Home     (Normally HIGH, Active LOW)
    Y_OT_Neg        = 13    ' Y Overtravel Negative Direction  (Normally HIGH, Active LOW)
    Z_OT_Pos        = 14    ' Z Overtravel Positive & Home     (Normally HIGH, Active LOW)
    Z_OT_Neg        = 15    ' Z Overtravel Negative Direction  (Normally HIGH, Active LOW) 


    OT_Mode    ' -16 Overtravel Mode. 0 = norm: OT will stop all motion & reset the move
               '                      1 = Home mode, OT will stop just the offending axis but the move will complete
 
}                                    
    Delta:=1.0
    f:=Var_Jog
    
    OffsetX:=OffsetY:=OffsetZ:=0
    G92X:=G92Y:=G92Z:=0
'    OffsetActive:=0
         
    ' Check to see if we are sitting on an overtravel switch
    ifnot ina[X_OT_Pos]
        s_ToX := fm.FSub(s_FromX,Delta)
        \lin(f,NoOTError,|<X_OT_Neg)
     
    ifnot ina[Y_OT_Pos]
        s_ToY:=fm.FSub(s_FromY,Delta)
        \lin(f,NoOTError,|<Y_OT_Neg)
     
    ifnot ina[Z_OT_Pos]
        s_ToZ:=fm.FSub(s_FromZ,Delta)
        \lin(f,NoOTError,|<Z_OT_Neg)

    Delta:=50.0    
    s_ToX:=fm.FAdd(s_FromX,Delta)
    s_ToY:=fm.FAdd(s_FromY,Delta)
    s_ToZ:=fm.FAdd(s_FromZ,Delta)
    \lin(f,NoOTError,(|< X_OT_Pos) + (|< Y_OT_Pos) + (|< Z_OT_Pos))              ' Find Home switch on each axis

    Delta:=0.1    
    s_ToX:=fm.FSub(s_FromX,Delta)
    s_ToY:=fm.FSub(s_FromY,Delta)
    s_ToZ:=fm.FSub(s_FromZ,Delta)
    \lin(f,NoOTError,(|< X_OT_Neg) + (|< Y_OT_Neg) + (|< Z_OT_Neg)) ' Move off Home switch on each axis

    f:=10.0
    Delta:=0.2    
    s_ToX:=fm.FAdd(s_FromX,Delta)
    s_ToY:=fm.FAdd(s_FromY,Delta)
    s_ToZ:=fm.FAdd(s_FromZ,Delta)
    \lin(f,NoOTError,(|< X_OT_Pos) + (|< Y_OT_Pos) + (|< Z_OT_Pos))        ' Find Home switch on each axis

    G92(0,0,0)


PRI G92(NewX,NewY,NewZ)
' Set current position to X,Y,Z (Floats)

'ser.position(1,10)
'ser.dec(s_state)

'ser.position(1,11)
'debug
'ser.dec(s_state)
'waitcnt(clkfreq+cnt)
    repeat while s_State            ' Wait until movement stops
    repeat while BufferUsed         ' Wait until buffer clears out    

'    UpdatePos(NewX, NewY, NewZ)
    ' Update current location (Float)
    s_ToX := s_FromX := NewX
    s_ToY := s_FromY := NewY
    s_ToZ := s_FromZ := NewZ

    ' convert to integer counts
    s_XAt := (fm.FRound(Fm.FMul(NewX,fm.FFloat(10000))) * fm.ftrunc(Var_SPI))/10000 ' StepsPerInch
    s_YAt := (fm.FRound(Fm.FMul(NewY,fm.FFloat(10000))) * fm.ftrunc(Var_SPI))/10000
    s_ZAt := (fm.FRound(Fm.FMul(NewZ,fm.FFloat(10000))) * fm.ftrunc(Var_SPI))/10000

    s_State:=92                  ' Disable & set starting positions
    repeat while s_State

'ser.position(1,12)
'debug

    G92X:=G92Y:=G92Z:=0         ' Clear G92 offsets
'    WorkOffset:=54

    ApplyWorkOffset    

'ser.position(1,13)
'debug

    DispPos

'PRI UpdatePos(NewX, NewY, NewZ)
' Calculate stepper counts for this new position.
' since monitoring cog uses integer counts not floats.
' Update actual location from these coordinate
' Enter with Float coordinates
'
'    DispPos


PRI DrawHeader


    GreenOnBlack

    ser.position(1,2)
    ser.str(string("Mode: "))
    ser.position(1,3)
    ser.str(string("File: "))

    if byte[@Var0] <> 32                                    ' Only display valid filename
        ser.position(8,3)
        ser.str(@Var0)
    
    ser.position(67,2)
    ser.str(string(            "X"))
    ser.position(67,3)
    ser.str(string(            "Y"))
    ser.position(67,4)
    ser.str(string(            "Z"))
    
    ser.position(32,2)
    ser.str(string(       "G-Mode"))
    ser.position(29,3)
    ser.str(string(    "Feed Rate"))
    ser.position(25,4)
    ser.str(string("Feed Override"))

    ser.position(44,1)
    ser.str(string(  "Offset G5"))
    ApplyWorkOffset    

    ser.position(58,1)
    ser.str(string(  "Machine"))

    ser.position(74,1)
    ser.str(string(  "Work"))

 
PRI Overtravel

    ser.RXFlush
    OpMessage(@OpMsgOT)
    MsgBox(45,15, @MsgPressKey, 1)
    
                                                  
PRI OpenFile(FilePtr)
   
    if byte[FilePtr] <> 32
        ProcessPtr:=0
        EOF:=0

        fat0.fatEngineStart(DOPin, CLKPin, DIPin, CSPin, -1,-1,-1,-1,-1)
        fat0.mountPartition(0)
        fat0.openFile(FilePtr, "R")     
        EnableDrives
         
         
        InComment:=0
        BufferedChar:=0
        LastChar:=0
         
        GreenOnBlack
        FillZone(8,3,3,12)
         
        ser.str(FilePtr)
    else
        fat0.unmountPartition                            ' Close file    
        abort

PRI CloseFile
    DisableDrives
    fat0.unmountPartition


PRI EnableDrives

    if (Var_Polarity & (|< EnablePin))
        outa[EnablePin]~                                             ' Enable stepper drive
    else
        outa[EnablePin]~~                                            ' Enable stepper drive

PRI DisableDrives
    dira[EnablePin]~~

    if (Var_Polarity & (|< EnablePin))
        outa[EnablePin]~~                                            ' Disable stepper drive
    else
        outa[EnablePin]~                                             ' Disable stepper drive

    
PRI tokenizeString(characters) 

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Removes white space and new lines arround the inside of a string of characters.
'' //
'' // Returns a pointer to the tokenized string of characters, or an empty string when out of tokenized strings of characters.
'' //
'' // Characters - A pointer to a string of characters to be tokenized, or null to continue tokenizing a string of characters.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if(characters)
    tokenStringPointer := characters

  result := tokenStringPointer := ignoreSpace(tokenStringPointer)
    
  repeat while(byte[tokenStringPointer])
    case byte[tokenStringPointer++]
         8 .. 13, 32, 127:
             byte[tokenStringPointer - 1] := 0
            quit
        
PRI ignoreSpace(characters) ' 4 Stack Longs

  result := characters
  repeat strsize(characters--)
    case byte[++characters]
      8 .. 13, 32, 127:
      other: return characters

PRI I2CInit

    dira[I2CBase..I2CBase+1]~

    ' setup i2cobject
    i2cSDA := (I2CBase+1)
    i2cSCL := I2CBase
    dira[i2cSDA] ~~          
    dira[i2cSCL] ~~
     
    outa[i2cSCL] ~~ ' Force stop condition         
    outa[i2cSDA] ~~ ' Set initial condition to both data and clock HIGH          

    if devicePresent(ADAddress)
    
        ' setup the config PGA x2, Continuous reading
        write(ADAddress & 127,0,ADS1000_ContConv | ADS1000_PGA2, 0)


PRI devicePresent(deviceAddress) : ackbit
  ' send the deviceAddress and listen for the ACK
  ' Return true if device is present, false if not present
  
    ackbit := false           
    i2cStart
    ackbit := i2cWrite((deviceAddress << 1) | 0,8)
    i2cStop
    if ackbit == 0 'Ack
        ackbit := true
    else
        ackbit := false
    return ackbit

  
PRI read(deviceAddress, deviceRegister, addressbits,databits) : i2cData | ackbit

  ' do a standard i2c address, then read
  ' read a device's register

    ackbit := 0 'Ack
    
    i2cStart     
    ackbit := (ackbit << 1) | i2cWrite((deviceAddress << 1) | 0,8)      ' Should be 0???
    ackbit := (ackbit << 1) | i2cWrite(deviceRegister << 24, 0)
    i2cStart
    ackbit := (ackbit << 1) | i2cWrite((deviceAddress << 1 ) | 1, 8)     
    i2cData := i2cRead(0) ' ACK
    i2cData := (i2cData <<8) | i2cRead(1)      
    i2cStop

    
PRI write(deviceAddress, deviceRegister, i2cDataValue, addressbits) : ackbit
  ' do a standard i2c address, then write
  ' return the ACK/NAK bit from the device address
    ackbit := 0 ' ACK=0
    i2cstart
    ackbit := (ackbit << 1) | i2cWrite(deviceAddress << 1 ,8)' r/w = 0 for write
    ackbit := (ackbit << 1) | i2cWrite(i2cDataValue,8)
    i2cStop
    return ackbit

  
' ******************************************************************************
' *   These are the low level routines                                         *
' ******************************************************************************  
 
PRI i2cStop
' i2c stop sequence - the SDA goes LOW to HIGH while SCL is HIGH
' must force both data and clock low to create stop condition

    outa[i2cSDA] ~    ' Set LOW
    dira[i2cSDA] ~~   ' Set to output
    outa[i2cSCL] ~~   ' Set HIGH
    dira[i2cSCL] ~~   ' Set to output
    outa[i2cSDA] ~~   ' Set HIGH
    dira[i2cSDA] ~~   ' Set to output

    
PRI i2cStart
    outa[i2cSCL] := 1       
    dira[i2cSCL] ~~
    dira[i2cSDA] ~~  
    outa[i2cSDA] := 1
    outa[i2cSDA] := 0     
    outa[i2cSCL] := 0       
  
PRI i2cWrite(i2cData, i2cBits) : ackbit
  ' Write i2c data.  Data byte is output MSB first, SDA data line is valid
  ' only while the SCL line is HIGH
  ' Return 0 if OK, return 1 if error
  
    ackbit := 1 'NAK=1 
    outa[i2cSDA]~
    dira[i2cSDA] ~~
    outa[i2cSCL]~
    dira[i2cSCL] ~~

    ' init the clock line                          

    ' send the data
    i2cData <<= (32 - i2cbits) ' Shift left
        
    repeat 8
        outa[i2cSDA] := (i2cData <-= 1) & 1         ' Rotate Left
        outa[i2cSCL] := 1
        outa[i2cSCL] := 0
       
    ' setup for ACK - pin to input immediately after falling edge of last bit            
    dira[i2cSDA] ~  ' Immediately Set data as input
    
    outa[i2cSCL] := 1
    ackbit := ina[i2cSDA]
    outa[i2cSCL] := 0      
    outa[i2cSDA] := 0    
    dira[i2cSDA] ~~   
    return ackbit' return the ackbit
            

PRI i2cRead(ackbit): i2cData
  ' Read in i2c data, Data byte is output MSB first, SDA data line is valid
  ' only while the SCL line is HIGH
  

    ' set the SCL to output and the SDA to input
    outa[i2cSCL] := 0
    dira[i2cSCL] ~~
    dira[i2cSDA] ~
     
    i2cData := 0
    repeat 8
        outa[i2cSCL] := 1
        i2cData := (i2cData << 1) | ina[i2cSDA]
        outa[i2cSCL] := 0
      
    ' send the ACK or NAK
    outa[i2cSDA] := ackbit
    dira[i2cSDA] ~~
    outa[i2cSCL] := 1
    outa[i2cSCL] := 0
         
    
    return i2cData ' return the data
    
PRI GreenOnBlack
    ser.str(string(27,"[32m",27,"[40m"))        ' Green Text / Black Background

PRI WhiteOnRed
    ser.str(string(27,"[41m",27,"[37m"))        ' White Letters / Red Background

PRI RedOnWhite
    ser.str(string(27,"[31m",27,"[47m"))        ' Red text /  White Background                

PRI OpMessage(MsgAddress)

    ser.position(8,2)
    GreenOnBlack
    ser.str(@OpMsgErase)
    ser.position(8,2)
    ser.str(MsgAddress)
    ser.HideCursor                

PRI MsgBox(Left, Top, Address, Wait) | ptr, rows, columns, tc  
    WhiteOnRed

    ' Find rows and columns used
    Columns:=Rows:=0
    tc~
    repeat ptr from address to strsize(Address)+address
        if byte[ptr]==13
            Rows++
            TC~
        else
            TC++            
            if TC>Columns
                Columns++

    columns+=2
            
    FillZone(Left,Top,Top+Rows,Columns)
    ser.position(++Left,top)

    repeat ptr from address to strsize(Address)+address
        if byte[ptr]==13
            ser.position(Left,++top)            
        else
            ser.char(byte[ptr])

    GreenOnBlack

    if Wait
        ser.showcursor
        ser.position(left+columns,top)
        bytefill(@Block,32,4)
        GetString(@block,4,0)  ' Yes/no response



PRI GetKey : Input | tmp, timer
' Get key sequence from keyboard
' Convert to single numeric value
' Return -1 if empty or key value

    bytefill(@KeyBuffer,0,8)
    
    input:=ser.RXCheck
    if input > 0

        byte[@KeyBuffer]:=input
        tmp:=1
      waitcnt(clkfreq/200+cnt)
        
        repeat ser.RXCount  
            byte[@KeyBuffer][tmp++]:=Ser.CharIn
            
        case tmp
           1:   input:=byte[@KeyBuffer]                     ' Single byte key sequence

           2:   input:=200+byte[@KeyBuffer][1]              ' add 200 to 2nd byte of 2-byte sequences
           
           3:   input:=300+byte[@KeyBuffer][2]              ' add 300 to 3rd byte of 3-byte sequences

           4:   input:=400+byte[@KeyBuffer][2]              ' add 400 to 3rd byte of 4-byte sequences

           5:   input:=500+byte[@KeyBuffer][3]              ' add 500 to 4th byte of 5-byte sequences

    

            
                  
PRI ReadConfig(DisplayProgress) | ParamPtr, VarPtr, tmp, FilePtr, SaveChr
' Read config file
' Display read progress if DisplayProgress==1

    if DisplayProgress
        PosString(@ConfigRead)
        
    ' Open configuration file
    fat0.fatEngineStart(DOPin, CLKPin, DIPin, CSPin, -1,-1,-1,-1,-1)
    \fat0.mountPartition(0)
    \fat0.openFile(@ConfigFile, "R")

    ' Read file entries formatted "Axis Steps Per Inch=4000<CR>"
    repeat

        FilePtr:=fat0.filetell
        
        \fat0.readstring(@Block,BufferSize-1)
        if strsize(@Block)==0
            quit
        
        ParamPtr:=@Param0
        VarPtr:=@Var1-4

        repeat result from 0 to strsize(@Block) ' trim out any leading non-printable characters
            if byte[@Block+result]<32
                bytemove(@Block,@Block+1,strsize(@Block)-1)
            else
                quit

        UCase(@Block)

        repeat 

            ' Find Param that matches string from file
            bytefill(@ShortBuf,0,ShortBufSize)
            bytemove(@ShortBuf,ParamPtr,strsize(ParamPtr)+1)
            UCase(@ShortBuf)

            SaveChr:=byte[@Block+strsize(ParamPtr)]
            byte[@Block+strsize(ParamPtr)]:=0

            result:=strcomp(@Block,@ShortBuf)
            byte[@Block+strsize(ParamPtr)]:=SaveChr                
            
            if result
            
                if DisplayProgress
                    ser.char(".")
            
                bytefill(@ShortBuf,0,ShortBufSize)
                bytemove(@ShortBuf,@Block+strsize(ParamPtr)+1,strsize(@block)-strsize(ParamPtr))

                case ParamPtr
                    @Param0:    ' Treat filename differently as a a string
                        bytemove(VarPtr-12,@ShortBuf,16)
                        NullFill(VarPtr-12,0,15)

                    @Param36:   ' Treat CNC file name extension as a a string
                        bytemove(VarPtr,@ShortBuf,4)
                        NullFill(VarPtr,0,3)                        

                    @Param37:   ' Read Hex value & convert to integer

                        '' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                        '' // Converts a hexadecimal string into an integer number. Expects a string with only "+-0123456789ABCDEFabdcef" characters.
                        '' // Characters - A pointer to the hexadecimal string to convert. The number returned will be 2's complement compatible.
                        '' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                           
                        tmp:=@ShortBuf
                        result:=0 
                        repeat (strsize(tmp) <# 8)
                            ifnot(checkDigit(tmp, "0", "9"))
                                ifnot(checkDigit(tmp, "A", "F") or checkDigit(tmp, "a", "f"))
                                    quit
                         
                                result += $90_00_00_00
                          result := ((result <- 4) + (byte[tmp++] & $F))

                        long[VarPtr]:=result
                    other:
                        long[Varptr]:=fs.StringToFloat(@ShortBuf)
                quit
               
            else
            
                VarPtr += 4
                ParamPtr += (strsize(ParamPtr)+1)                 ' Terminating '0'+ 4 bytes for a long
                        
        while (strsize(ParamPtr)>0)

    bytemove(@ValidExt,@Var_CNCExt,4)
    byte[@ValidExt+4]:=0
    UCase(@ValidExt)   ' Change file extension to upper case

    \fat0.CloseFile
    DisableDrives    
    \fat0.unmountPartition

PRI WriteConfig(DisplayProgress) | ParamPtr, VarPtr, tmp
    if DisplayProgress
        PosString(@ConfigWrite)
    

    ' Open configuration file
    fat0.fatEngineStart(DOPin, CLKPin, DIPin, CSPin, -1,-1,-1,-1,-1)

    \fat0.mountPartition(0)    
    \fat0.deleteEntry(@ConfigFile)    
    \fat0.newFile(@ConfigFile)
    \fat0.OpenFile(@ConfigFile, "W")

    ' Write file entries formatted "Axis Steps Per Inch=4000<CR>"

    VarPtr:=@Var0
    ParamPtr:=@Param0
    
    repeat
        \fat0.WriteString(ParamPtr)
        \fat0.WriteByte("=")

        case ParamPtr
            @Param0: ' Treat filename as a a string
                \fat0.WriteString(VarPtr)
                VarPtr+=12
                 
            @Param36: ' Treat last CNC file name extension as a a string
                \fat0.WriteString(@ValidExt)

            @Param37: ' Save polarity mask as HEX
                ' Add 1 to the low 9-bits of Var_Polarity = save counter
                long[VarPtr] := (((long[VarPtr]+1) & %1_1111_1111) | (long[VarPtr] & $FFFF_FE00))
                
                repeat 8
                    \fat0.WriteByte(lookupz((long[VarPtr] <-= 4) & $F : "0".."9", "A".."F"))

            @Param38: ' Save Chain value as an integer ASCII "0","1". remember it is 1 byte of 4-byte long
                      ' so trim out the CR/LF,Ctrl-Z when read by overlay file.
                    \fat0.WriteByte(long[VarPtr] +"0")
            
            Other:
                \fat0.WriteString(fs.FloatToString(long[VarPtr]))

        \fat0.WriteString(String(13,10))
        
        VarPtr += 4 ' Point to next long
        ParamPtr += (strsize(ParamPtr)+1)
        
    while (strsize(ParamPtr)>0)

    \fat0.WriteByte(26)   ' Terminate file with Ctrl-Z    
    \fat0.CloseFile
    DisableDrives
    \fat0.unmountPartition

    if DisplayProgress
        ser.str(string(" - Done.",13,10))
        
PRI CheckDigit(characters, low, high) ' 5 Stack Longs
' return true if byte[character] is between low and high
    result := byte[characters]
    return ((low =< result) and (result =< high))

PRI UCase(StringAdr)
'   Convert string to upper case
    repeat result from 0 to strsize(StringAdr)
        if (byte[StringAdr + result] > "@" and byte[StringAdr + result] < "{") 
            byte[StringAdr + result]:=byte[StringAdr + result] & %1101_1111                 

PRI PulseLength
    result:=(fm.FTrunc(fm.fDiv(Var_Pulse,fm.fDiv(1000000.0,fm.FFloat(clkfreq))))) #> MinPulse 'Shortest value that won't lock up
    result <#= MaxPulse

PRI FillZone(Left,Top,Bottom,Width)
'   Fill an area with spaces
    repeat result from Top to Bottom
        ser.position(Left,result)
        ser.chars(32,Width)
        ser.position(Left,result)
        
     
PRI NullFill(VarPtr,st,end)
'   Replace characters lower than 32 with 0                        
    repeat result from st to end
        if byte[VarPtr+result]<32
            byte[VarPtr+result]:=0

PRI PosString(Address)
'   Locate cursor based on first 2 bytes of string @ Address
'   Length of text is byte[Address+2) wide
    ser.position(byte[Address],byte[Address+1])
    ser.str(Address+3)       
    ser.chars(32,byte[address+2]-strsize(Address+3))

PRI GetString(MemLoc,Count,Update) | tmp
' Edit string at MemLoc x Count bytes long
' Return a zero terminated string
' If Update = non-zero, the position displays and feed rate override fields are updated
' return the last keysrtoke result
' Position cursor prior to calling this routine

  
    tmp:=0 ' set tmp equal to the number of used characters
    repeat count
        if byte[MemLoc+tmp]<>32
            ser.char(byte[MemLoc+tmp])
            tmp++
        else
            quit
        
    ser.ShowCursor
    
    repeat
        repeat
            result:=GetKey
            if Update
                ser.SaveCurPos
                ser.HideCursor
                DispPos                 ' Display feedrate override value while waiting
                ser.RestoreCurPos
                ser.ShowCursor
            
        while result == -1                               

        case result
            "#".."~":
                if tmp < Count ' How many characters to accept                            
                    ser.char(result)
                    byte[MemLoc][tmp++]:=result
            
            8:    ' Backspace
                if tmp
                    byte[MemLoc][--tmp]:=0
                    ser.str(@BackSpace)
            13,27:
                byte[MemLoc][tmp+1]:=0
                ser.HideCursor                
                quit
                
            other:  ' return movement keystrokes
                quit
                
    UCase(MemLoc)

     
    
dat
            ' Acceleration/Deceleration Table of coefficients
            long    247    ' How many segments in the Ramp table (base 0)                             
'AccTable long 1.0[250] ' replace table with all 1.0 to eliminate accel/decel

AccTable    long    8.4733,7.4651,6.7490,6.2063,5.7767,5.4256,5.1317,4.8809
            long    4.6636,4.4730,4.3041,4.1529,4.0166,3.8929,3.7800,3.6764
            long    3.5809,3.4924,3.4102,3.3335,3.2618,3.1946,3.1313,3.0716
            long    3.0152,2.9619,2.9112,2.8631,2.8173,2.7736,2.7319,2.6920
            long    2.6538,2.6172,2.5821,2.5483,2.5158,2.4846,2.4545,2.4254
            long    2.3974,2.3703,2.3441,2.3187,2.2942,2.2704,2.2474,2.2250
            long    2.2033,2.1822,2.1617,2.1418,2.1224,2.1035,2.0852,2.0673
            long    2.0498,2.0328,2.0162,2.0000,1.9842,1.9688,1.9537,1.9389
            long    1.9245,1.9104,1.8966,1.8831,1.8699,1.8570,1.8443,1.8319
            long    1.8197,1.8078,1.7961,1.7846,1.7733,1.7623,1.7514,1.7408
            long    1.7303,1.7201,1.7100,1.7001,1.6903,1.6807,1.6713,1.6621
            long    1.6530,1.6440,1.6352,1.6265,1.6180,1.6096,1.6013,1.5931
            long    1.5851,1.5772,1.5694,1.5617,1.5542,1.5467,1.5394,1.5321
            long    1.5250,1.5180,1.5110,1.5042,1.4974,1.4907,1.4841,1.4776
            long    1.4712,1.4649,1.4587,1.4525,1.4464,1.4404,1.4344,1.4286
            long    1.4228,1.4171,1.4114,1.4058,1.4003,1.3948,1.3894,1.3841
            long    1.3788,1.3736,1.3685,1.3634,1.3583,1.3533,1.3484,1.3435
            long    1.3387,1.3339,1.3292,1.3245,1.3199,1.3153,1.3108,1.3063
            long    1.3019,1.2975,1.2932,1.2889,1.2846,1.2804,1.2762,1.2721
            long    1.2680,1.2639,1.2599,1.2559,1.2520,1.2481,1.2442,1.2404
            long    1.2366,1.2328,1.2291,1.2254,1.2217,1.2181,1.2145,1.2109
            long    1.2074,1.2039,1.2004,1.1969,1.1935,1.1901,1.1868,1.1835
            long    1.1802,1.1769,1.1736,1.1704,1.1672,1.1641,1.1609,1.1578
            long    1.1547,1.1516,1.1486,1.1456,1.1426,1.1396,1.1367,1.1337
            long    1.1308,1.1280,1.1251,1.1223,1.1194,1.1166,1.1139,1.1111
            long    1.1084,1.1057,1.1030,1.1003,1.0976,1.0950,1.0924,1.0898
            long    1.0872,1.0847,1.0821,1.0796,1.0771,1.0746,1.0721,1.0697
            long    1.0672,1.0648,1.0624,1.0600,1.0576,1.0553,1.0529,1.0506
            long    1.0483,1.0460,1.0437,1.0414,1.0392,1.0370,1.0347,1.0325
            long    1.0303,1.0282,1.0260,1.0238,1.0217,1.0196,1.0175,1.0154
            long    1.0133,1.0112,1.0091,1.0071,1.0050,1.0030,1.0010,1.0000

'long 0[221]

block       byte    0[BufferSize+1]     ' Parsing String Storage
ShortBuf    byte    0[ShortBufSize]     ' short buffer for string comparison
KeyBuffer   byte    0[8]                ' keyboard input buffer
ValidExt    byte    0[5]                ' valid CNC filename extension, zero terminated
BackSpace   byte    8,32,8,0

OpMsgErase  byte    32[20],0            '"                ",0
OpMsgIdle   byte    "Idle",0
OpMsgAuto   byte    "Auto",0
OpMsgMDI    byte    "MDI",0
OpMsgSingleBk byte  "Single Block",0
OpMsgFinish byte    27,"[41m",27,"[37m","Finishing Move",0
OpMsgNoFR   byte    27,"[41m",27,"[37m","Feedrate Missing",0
OpMsgOT     byte    27,"[41m",27,"[37m"," Overtravel ",0    
OpMsgHoming byte    "Finding Home",0
OpMsgESTOP  byte    27,"[41m",27,"[37m"," Emergency Stop  ",0    

MenuPrompt  byte    58,16,20,"Menu Option:",0
Holding     byte    21,2,27, 27,"[41m",27,"[37m","HOLDING",27,"[32m",27,"[40m",0


MsgOverwrite byte   13,"Overwrite Existing File Y/N",0            
MsgGoodby   byte    13,"Bye",13,0
MsgOverlay  byte    13,"Can't Load Overlay File"
MsgPressKey byte    13,"  Press Any Key   ",13,0
MsgBadName  byte    13,"Error Opening File",13,13,13,0
MsgSaveFile byte    13,"Saving File",13,0

Splash      byte    13,"Starkey Propeller CNC Control",13,13
            byte    "Alpha Version 1.0 4/15/2012",13,13
            byte    "Don@StarkeyMail.com",7,13,0

Menu1       byte    "1 - Load File",13
            byte    "2 - Edit File",13
            byte    "3 - New File",13
            byte    "4 - MDI",13
            byte    "5 - Manual Jog",13
            byte    "6 - Restart File",13
            byte    "7 -             ",13
            byte    "8 - Offsets",13
            byte    "9 - Settings",13
            byte    "Q - Quit",13,0

MainText_11 byte    1,1,30,  "Reading SD Card Directory...",0
MainText_12 byte    1,1,21,  "Enter the file name:",0


Menu2       byte    "1 - Keyboard Jog",13
            byte    "  - Handle Jog",13
            byte    "3 - Return To 0,0,0",13
            byte    "4 - Set 0,0,0 (G92)",13
            byte    "5 - Set Work Offset",13
            byte    "6 -",13
            byte    "7 - Home Machine",13
            byte    "8 -",13
            byte    "9 - Return To Main",13,0

JogText_1   byte    "Keyboard Jog",13                 
            byte    "+/- to change dist.",13
            byte    "<ESC> to finish.",0                 

JogText_21  byte    36,6,21," 0.001 0.01 0.1 1 10 ",0
JogText_22  byte    36,7,21,"     Jog Amount",0

JogText_61  byte    55,6,23, " Save Work offset",0         
JogText_62  byte    55,7,23, " +/- to select offset.",0
JogText_63  byte    55,8,23, " <CR> to accept.",0
JogText_64  byte    55,9,23, " <ESC> to abort.",0
JogText_65  byte    30,6,50, "Copy MACHINE position to workplane offset.",0
JogText_66  byte    30,7,26, " G54 G55 G56 G57 G58 G59 ",0


Menu3       byte    "1 - Resume Auto",13
            byte    "2 - Single Block",13
            byte    "3 - Stop",13
            byte    "ESC = E-STOP",0

ConfigRead  byte    1,1,22,  "Loading Configuration",0
ConfigWrite byte    1,1,23,  "Saving Configuration",0

' Editor strings
Num_Msg     byte    17,25,15, 27,"[32m",27,"[40m","NUM",27,">",0 ' Green on Black, Cancel Application Keypad Mode
NumOff_Msg  byte    17,25,15, 27,"[32m",27,"[40m","   ",27,"=",0 ' Green on Black, Application Keypad Mode

ConfigFile  byte    "CONFIG.DAT",0      ' Configuration data file
RebootFile  byte    "REBOOT.ING",0      ' 
MDIfile     byte    "MDI.txt",0
OverlayFile byte    "CONFIG.OVL",0      ' Settings editor overlay file
ScratchFile byte    "%Edit%.txt",0      ' Editing temporary file
BackupExt   byte    "BAK"

        
' Parameter names Must be 30 bytes or shorter
Param0      byte    "Last CNC File",0
Param1      byte    "reserved 1",0
Param2      byte    "reserved 2",0   
Param3      byte    "reserved 3",0   
Param4      byte    "G54 X",0
Param5      byte    "G54 Y",0
Param6      byte    "G54 Z",0
Param7      byte    "G55 X",0
Param8      byte    "G55 Y",0
Param9      byte    "G55 Z",0
Param10     byte    "G56 X",0
Param11     byte    "G56 Y",0
Param12     byte    "G56 Z",0
Param13     byte    "G57 X",0
Param14     byte    "G57 Y",0
Param15     byte    "G57 Z",0
Param16     byte    "G58 X",0
Param17     byte    "G58 Y",0
Param18     byte    "G58 Z",0
Param19     byte    "G59 X",0
Param20     byte    "G59 Y",0
Param21     byte    "G59 Z",0
Param22     byte    "Tool 1 Offset",0
Param23     byte    "Tool 2 Offset",0
Param24     byte    "Tool 3 Offset",0
Param25     byte    "Tool 4 Offset",0
Param26     byte    "Tool 5 Offset",0
Param27     byte    "Tool 6 Offset",0
Param28     byte    "Tool 7 Offset",0
Param29     byte    "Tool 8 Offset",0

Param30     byte    "Feed Rate Override",0                  ' Feed Rate OverRide Value "200" = 200%
Param31     byte    "Axis Steps Per Inch",0                 ' Steps Per Inch on All Axis 4000 = .00025 Resolution
Param32     byte    "Rapid Feed Rate",0                     ' G0 feedrate 50 = 50 IPM
Param33     byte    "Jog Feed Rate",0                       ' Jogging feedrate 50 = 50 IPM
Param34     byte    "Step Driver Pulse Time",0              ' .5 = .5uS
Param35     byte    "Serial Terminal Baud Rate",0           ' 115200 baud
Param36     byte    "Default CNC File Extension",0          ' ".TXT"
Param37     byte    "Step Driver Polarity",0                ' bitmask
Param38     byte    "Chain",0                               ' Function to perform when chaining to overlay program
                                                            ' 0 = Edit Settings
                                                            ' 1 = Edit Offsets
            byte    0                   ' end of param table

' These variables must be long aligned
Var0        long    0[4]    ' Last CNC File = 12 bytes
Var1        long    0       ' reserved 1 = 1 Long each variable
Var2        long    0       ' reserved 2              
Var3        long    0       ' reserved 3
Var4        long    0       ' G54 X
Var5        long    0       ' G54 Y
Var6        long    0       ' G54 Z
Var7        long    0       ' G55 X
Var8        long    0       ' G55 Y
Var9        long    0       ' G55 Z
Var10       long    0       ' G56 X
Var11       long    0       ' G56 Y
Var12       long    0       ' G56 Z
Var13       long    0       ' G57 X
Var14       long    0       ' G57 Y
Var15       long    0       ' G57 Z
Var16       long    0       ' G58 X
Var17       long    0       ' G58 Y
Var18       long    0       ' G58 Z
Var19       long    0       ' G59 X
Var20       long    0       ' G59 Y
Var21       long    0       ' G59 Z
Var22       long    0       ' Tool 1 Offset
Var23       long    0       ' Tool 2 Offset
Var24       long    0       ' Tool 3 Offset
Var25       long    0       ' Tool 4 Offset
Var26       long    0       ' Tool 5 Offset
Var27       long    0       ' Tool 6 Offset
Var28       long    0       ' Tool 7 Offset
Var29       long    0       ' Tool 8 Offset



Var_Override long   0       ' Feed Rate Override 
Var_SPI     long    0       ' Axis Steps Per Inch 
Var_Rapid   long    0       ' Rapid Feed Rate
Var_Jog     long    0       ' Jog Feed Rate
Var_Pulse   long    0       ' Step Driver Pulse Time .5uS for the Superior SD200)
Var_Baud    long    0       ' Serial Terminal Baud Rate (need to convert to an integer)    
Var_CNCExt  long    0       ' Default CNC File Extension "TXT"
Var_Polarity long   0       ' Step Driver Polarity bitmask to apply to INA & OUTA to invert step & direction pins as needed
Var_Chain   long    0       ' Function to perform when chaining to overlay program
                            ' 0 = Edit Settings
                            ' 1 = Edit Offsets
 