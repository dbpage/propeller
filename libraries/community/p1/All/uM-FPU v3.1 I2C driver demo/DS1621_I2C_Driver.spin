{{
┌─────────────────────────────┬───────────────────┬──────────────────────┐
│ DS1621_I2C_Driver.spin v1.2 │ Author: I.Kövesdi │ Release: 25 08 2008  │
├─────────────────────────────┴───────────────────┴──────────────────────┤
│                    Copyright (c) 2008 CompElit Inc.                    │               
│                   See end of file for terms of use.                    │               
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  This is a driver object for the DS1621 digital temperature sensor IC, │
│ that uses I2C protocol for the data transfer. This Driver is coded in  │
│ SPIN and needs only the COG for the SPIN interpreter. It uses a simple │
│ I2C driver object which is implemented in SPIN, too.                   │
│                                                                        │ 
├────────────────────────────────────────────────────────────────────────┤
│ Background and Detail:                                                 │
│  This driver object fully exploits the capabilities of DS1621. The user│
│ has access to all internal registers, measurement modes and thermostat │
│ controls, as well.                                                     │
│                                                                        │
├────────────────────────────────────────────────────────────────────────┤
│ Note:                                                                  │
│  The driver software, especially the 9 bit temperature reading was not │
│ tested below zero degrees of Celsius. This is something to left for the│
│ interested and careful user. I made a fair attempt to make the code    │
│ correct, but I tested only at room temperatures.                       │
│                                                                        │ 
└────────────────────────────────────────────────────────────────────────┘
}}


CON

'DS1621 command set
'Temperature conversion commands
  _ReadTemp       = $AA 
  _ReadCounter    = $A8 
  _ReadSlope      = $A9
  _StartConvert   = $EE                'Begins conversion in both modes
  _StopConvert    = $22                'Halts DS1621 in continuous mode

'Bits of the Configutration register byte of DS1621 
  _ConvDoneBit    = %1000_0000
  _TempHighFlag   = %0100_0000
  _TempLowFlag    = %0010_0000
  _NVMemBusy      = %0001_0000
  _OutPutPolarity = %0000_0010  
  _OneShotModeBit = %0000_0001
  
'Thermostat commands  
  _AccessTH       = $A1
  _AccessTL       = $A2 
  _AccessConfig   = $AC

'Nonvolatile memory write delay
  _NVMemWrDelay   = 800_000          '10 ms nonvolatile memory write delay
                                     'at 80 MHz 

  
VAR

  long  ds1621Addr


'Data Flow within DS1621_I2C_Driver object:
'=======================================
'This SPIN implemented driver object calls some procedures of an I2C      
'driver object and passes and returns parameters by value.
'
'
'Data Flow between DS1621_SPI_Driver object and a calling SPIN code:
'===================================================================
'External SPIN code objects can call the available PUB procedures of this
'FPU_SPI_Driver object in the standard way. All parameters and returns are
'passed by value.  
  
  
OBJ

  I2C     : "I2C_Driver" 

  
PUB Init(addr, sda, scl): okay
'-------------------------------------------------------------------------
'----------------------------------┌──────┐-------------------------------
'----------------------------------│ Init │-------------------------------
'----------------------------------└──────┘-------------------------------
'-------------------------------------------------------------------------
''     Action: Initializes I2C lines and checks for DS1621 present                                                      
'' Parameters: Device Address and I2C lines                                         
''    Results: Okay if everybody on board                              
''+Reads/Uses: /ds1621Addr
''  +Modifies: ds1621Addr
''      Calls: I2C_Driver--->I2C.PingDeviceAt
'-------------------------------------------------------------------------
  ds1621Addr := addr
  okay := I2C.Init(sda, scl)

  if okay == true
    okay := I2C.PingDeviceAt(ds1621Addr)

  return okay
'-------------------------------------------------------------------------


PUB ReadConfig : configReg
'-------------------------------------------------------------------------
'-------------------------------┌────────────┐----------------------------
'-------------------------------│ ReadConfig │----------------------------
'-------------------------------└────────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Reads Configuration Register of DS1621                                                          
'' Parameters: None                                         
''    Results: Configuration Register                             
''+Reads/Uses: /ds1621Addr, _AccessConfig
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.ReadByteFrom
'-------------------------------------------------------------------------
  configReg := I2C.ReadByteFrom(ds1621Addr, _AccessConfig)

  return configReg   
'-------------------------------------------------------------------------

  
PUB WriteConfig(configByte) : AckBits
'-------------------------------------------------------------------------
'------------------------------┌─────────────┐----------------------------
'------------------------------│ WriteConfig │----------------------------
'------------------------------└─────────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Writes Configuration Register of DS1621                                                     
'' Parameters: New Configuration Register byte                                         
''    Results: ACK bits                             
''+Reads/Uses: /ds1621Addr, _AccessConfig
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.WriteByteTo
'-------------------------------------------------------------------------
  ackBits := I2C.WriteByteTo(ds1621Addr, _AccessConfig, configByte)
  
  return AckBits
'-------------------------------------------------------------------------

    
PUB OrWithConfig(configByte) : AckBits | configReg
'-------------------------------------------------------------------------
'------------------------------┌──────────────┐---------------------------
'------------------------------│ OrWithConfig │---------------------------
'------------------------------└──────────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: ORs Data Byte with Configuration Register [to set bit(s)]                                                     
'' Parameters: Data Byte                                         
''    Results: ACK bits                             
''+Reads/Uses: /ds1621Addr, _AccessConfig
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.ReadByteFrom
''                           I2C.WriteByteTo
'-------------------------------------------------------------------------
  configReg := I2C.ReadByteFrom(ds1621Addr, _AccessConfig)
  configReg := configReg | configByte
  ackBits := I2C.WriteByteTo(ds1621Addr, _AccessConfig, configReg)
  
  return AckBits
'-------------------------------------------------------------------------


PUB ReadTH : thReg
'-------------------------------------------------------------------------
'---------------------------------┌────────┐------------------------------
'---------------------------------│ ReadTH │------------------------------
'---------------------------------└────────┘------------------------------
'-------------------------------------------------------------------------
''     Action: Reads the TH register in 9 bit format, e.g. 51 means 25.5 C                                                        
'' Parameters: None                                         
''    Results: TH                              
''+Reads/Uses: /ds1621Addr, _AccessTH
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.Read2BytesFrom
'-------------------------------------------------------------------------
  thReg := I2C.Read2BytesFrom(ds1621Addr, _AccessTH)
  thReg := thReg ~> 7
  
  return thReg
'-------------------------------------------------------------------------


PUB WriteTH(thVal) : ackBits | msByte, lsByte
'-------------------------------------------------------------------------
'---------------------------------┌─────────┐-----------------------------
'---------------------------------│ WriteTH │-----------------------------
'---------------------------------└─────────┘-----------------------------
'-------------------------------------------------------------------------
''     Action: Writes the TH register in 9 bit format,
''             e.g. for 25.5 C write 51                                                       
'' Parameters: TH                                         
''    Results: ACK bits                             
''+Reads/Uses: /ds1621Addr, _AccessTH
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.Write2BytesTo
'------------------------------------------------------------------------- 
  thVal := thVal << 7
  msByte := thVal & %11111111_00000000
  msByte := msByte >> 8
  lsByte := thVal & %10000000
  ackBits := I2C.Write2BytesTo(ds1621Addr, _AccessTH, msByte, lsByte)
  
  return ackBits  
'-------------------------------------------------------------------------


PUB ReadTL : tlReg
'-------------------------------------------------------------------------
'---------------------------------┌────────┐------------------------------
'---------------------------------│ ReadTL │------------------------------
'---------------------------------└────────┘------------------------------
'-------------------------------------------------------------------------
''     Action: Reads the TL register in 9 bit format, e.g. 31 means 15.5 C                                                       
'' Parameters: None                                         
''    Results: TL                             
''+Reads/Uses: /ds1621Addr, _AccessTL
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.Read2BytesFrom
'-------------------------------------------------------------------------
  tlReg := I2C.Read2BytesFrom(ds1621Addr, _AccessTL)
  tlReg := tlReg ~> 7
  
  return tlReg       
'-------------------------------------------------------------------------


PUB WriteTL(tlVal) : ackBits | msByte, lsByte
'-------------------------------------------------------------------------
'---------------------------------┌─────────┐-----------------------------
'---------------------------------│ WriteTL │-----------------------------
'---------------------------------└─────────┘-----------------------------
'-------------------------------------------------------------------------
''     Action: Writes the TL register in 9 bit format, e.g. 15.5 C --> 31                                                      
'' Parameters: TL                                         
''    Results: ACK bits                             
''+Reads/Uses: /ds1621Addr, _AccessTL
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.Write2BytesTo
'------------------------------------------------------------------------- 
  tlVal := tlVal << 7
  msByte := tlVal & %11111111_00000000
  msByte := msByte >> 8
  lsByte := tlVal & %10000000
  ackBits := I2C.Write2BytesTo(ds1621Addr, _AccessTL, msByte, lsByte)
  
  return ackBits  
'-------------------------------------------------------------------------

  
PUB StartConversion : ackBits
'-------------------------------------------------------------------------
'-----------------------------┌─────────────────┐-------------------------
'-----------------------------│ StartConversion │-------------------------
'-----------------------------└─────────────────┘-------------------------
'-------------------------------------------------------------------------
''     Action: Starts temperature conversion                                                      
'' Parameters: None                                         
''    Results: ACK bits                             
''+Reads/Uses: /ds1621Addr, _StartConvert
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.Start
''                           I2C.Write
''                           I2C.Stop  
'-------------------------------------------------------------------------
  ackBits := 0
  I2C.Start
  ackBits := (ackBits << 1) | I2C.Write(ds1621Addr | 0)
  ackBits := (ackBits << 1) | I2C.Write(_StartConvert)
  I2C.Stop

  return ackBits
'-------------------------------------------------------------------------


PUB StopConversion : ackBits
'-------------------------------------------------------------------------
'-----------------------------┌────────────────┐--------------------------
'-----------------------------│ StopConversion │--------------------------
'-----------------------------└────────────────┘--------------------------
'-------------------------------------------------------------------------
''     Action: Stops temperature conversion                                                     
'' Parameters: None                                         
''    Results: ACK bits                             
''+Reads/Uses: /ds1621Addr, _StopConvert
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.Start
''                           I2C.Write
''                           I2C.Stop
''       Note: Practical use in continuous conversion mode.  
'-------------------------------------------------------------------------
  ackBits := 0
  I2C.Start
  ackBits := (ackBits << 1) | I2C.Write(ds1621Addr | 0)
  ackBits := (ackBits << 1) | I2C.Write(_StopConvert)
  I2C.Stop

  return ackBits  
'-------------------------------------------------------------------------


PUB Read8BitTemp : tempC
'-------------------------------------------------------------------------
'------------------------------┌──────────────┐---------------------------
'------------------------------│ Read8BitTemp │---------------------------
'------------------------------└──────────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: Reads temperatue in C, 8 bit, e.g. 20 = 20 C                                                         
'' Parameters: None                                         
''    Results: Temperature in C (1 C resolution)                             
''+Reads/Uses: /ds1621Addr, _ReadTemp
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.ReadByteFrom
''       Note: 2nd byte of the 9-bit temp is simply not read
'-------------------------------------------------------------------------
  tempC := I2C.ReadByteFrom(ds1621Addr, _ReadTemp)
  
  return tempC
'-------------------------------------------------------------------------


PUB Read9BitTemp : tempC
'-------------------------------------------------------------------------
'------------------------------┌──────────────┐---------------------------
'------------------------------│ Read9BitTemp │---------------------------
'------------------------------└──────────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: Reads temperatue in C, 9 bit, e.g. reading 41 = 20.5 C                                                      
'' Parameters: None                                         
''    Results: 9 bit temperature reading            
''+Reads/Uses: /ds1621Addr, _ReadTemp
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.Read2BytesFrom
''       Note: Beside the 1st byte only the MS bit of 2nd byte is used
''             Divide the 9 bit reading by 2 later to obtain temp in C 
'-------------------------------------------------------------------------
  tempC := I2C.Read2BytesFrom(ds1621Addr, _ReadTemp)
  tempC := tempC ~> 7

  return tempC
'-------------------------------------------------------------------------
  

PUB ReadCounter : cntr
'-------------------------------------------------------------------------
'-------------------------------┌─────────────┐---------------------------
'-------------------------------│ ReadCounter │---------------------------
'-------------------------------└─────────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: Reads COUNT_REMAIN register                                                      
'' Parameters: None                                         
''    Results: COUNT_REMAIN byte                             
''+Reads/Uses: /ds1621Addr, _ReadCounter
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.ReadByteFrom
''       Note: With COUNT_REMAIN, COUNT_PER_C and (8 bit)Temp bytes 1/16 C
''             resolution temperature value can be calculated as:
''             (8 bit)Temp + (COUNT_PER_C-COUNT_REMAIN)/COUNT_PER_C - 0.25 
'-------------------------------------------------------------------------
  cntr := I2C.ReadByteFrom(ds1621Addr, _ReadCounter)
  
  return cntr
'-------------------------------------------------------------------------


PUB ReadSlope : slope
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ ReadSlope │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Reads COUNT_PER_C register                                                     
'' Parameters: None                                         
''    Results: COUNT_PER_C byte                             
''+Reads/Uses: /ds1621Addr, _ReadSlope
''  +Modifies: None
''      Calls: I2C_Driver--->I2C.ReadByteFrom
'-------------------------------------------------------------------------
  slope := I2C.ReadByteFrom(ds1621Addr, _ReadSlope)
  
  return slope
'-------------------------------------------------------------------------


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