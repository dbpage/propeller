{{
*************************************
* Numbers v1.1                      *
* Author: Jeff Martin               *
* Copyright (c) 2005 Parallax, Inc. *
* See end of file for terms of use. *
*************************************

{-----------------REVISION HISTORY-----------------
 v1.1 - 5/5/2009 fixed formatting bug caused by specifying field width smaller than location of first grouping character.}

}}

VAR
  long  BCX0, BCX1, BCX2, BCX3  'BCX Workspace
  byte  Symbols[7]              'Special symbols (7 characters)
  byte  StrBuf[49]              'Internal String Buffer

PUB Init 
''Initialize to default settings.  Init MUST be called before first object use.
''  ┌──────────────────────────────────────────────────┐
''  │             DEFAULT SPECIAL SYMBOLS              │
''  ├─────┬──────┬─────────────────────────────────────┤
''  │ ID  │ Char │ Usage                               │
''  ├─────┼──────┼─────────────────────────────────────┤
''  │  1  │  ,   │ Comma (digit group separator)       │
''  │  2  │  _   │ Underscore (digit group separator)  │
''  │  3  │  $   │ Dollar Sign (Hexadecimal indicator) │
''  │  4  │  %   │ Percent Sign (Binary indicator)     │
''  │ 5-7 │      │ Unused (User definable via Config)  │
''  └─────┴──────┴─────────────────────────────────────┘
  Config(@DefaultSymbols)

  
PUB Config(SymAddr)
{{Configure for custom symbols.
  PARAMETERS: SymAddr = Address of a string of characters (7 or less) to be used as Special Symbols (indexed from 1 to 7).  New symbols can be added or
              existing symbols can be modified based on regional customs.  Note:  The first four symbols must always be the logical: 1) digit group separator
              (default is ','), 2) general separator (default is '_'), 3) hexadecimal base indicator (default is '$'), and 4) binary base indicator
              (default is '%').}}  
  bytemove(@Symbols, SymAddr, 7)        


PUB ToStr(Num, Format): StrAddr
{{Convert long Num to z-string using Format; returns string address.
  PARAMETERS: Num     = 32-bit signed value to translate to ASCII string.
              Format  = Indicates output format: base, width, grouping, etc. See "FORMAT SYNTAX" for more information.
  RETURNS:    Actual length of output string, not including null terminator.}}
  BCXToText(Format >> 19 & 7, Format >> 13 & $3F, Format >> 12 & 1, Format >> 11 & 1, Format >> 5 & $3F, BinToBCX(Num, Format & $1F #> 2 <# 16))
  StrAddr := @StrBuf
  

PUB FromStr(StrAddr, Format): Num | Idx, N, Val, Char, Base, GChar, IChar, Field
''Convert z-string (at StrAddr) to long Num using Format.
''PARAMETERS: StrAddr = Address of string buffer containing the numeric string to convert.
''            Format  = Indicates input format: base, width, etc. See "FORMAT SYNTAX" for more information.  Note: three Format elements are ignored by
''                      FromStr(): Zero/Space Padding, Hide/Show Plus Sign, and Digit Group Size.  All other elements are actively used during translation.
''RETURNS:    Long containing 32-bit signed result.
  Base := Format & $1F #> 2 <# 16                                                                       'Get base
  if GChar := Format >> 13 & 7                                                                          'Get grouping character
    GChar := Symbols[--GChar #> 0]
  if IChar := Format >> 19 & 7                                                                          'Get indicator character
    IChar := Symbols[--IChar #> 0]
  Field := Format >> 5 & $3F - 1                                                                        'Get field size, if any (subtract out sign char)
  longfill(@Idx, 0, 3)                                                                                  'Clear Idx, N and Val
  repeat while Char := byte[StrAddr][Idx]                                                               'While not null
    if (not IChar or (IChar and Val)) and InBaseRange(Char, Base) > 0                                   'Found first valid digit? (with prefix indicator if required)?
      quit                                                                                              '  exit to process digits
    else                                                                                                'else
      if not Val := IChar and (Char == IChar)                                                           '  look for indicator character (if required)
        N := Char == "-"                                                                                'Update N flag if not indicator
    Idx++
  Field += Val                                                                                          'Subract indicator character from remaining field size
  repeat while (Field--) and (Char := byte[StrAddr][Idx++]) and ((Val := InBaseRange(Char, Base)) > 0 or (GChar and (Char == GChar)))           
    if Val                                                                                              'While not null and valid digit or grouping char
      Num := Num * Base + --Val                                                                         'Accumulate if valid digit
  if N
    -Num                                                                                                'Negate if necessary


PRI BinToBCX(Num, Base): Digits | N
'Convert signed binary Num to signed BCX value (Binary Coded X ;where X (2..16) is determined by Base)
'Returns: Number of significant Digits (not counting zero-left-padding).
  longfill(@BCX0, 0, 4)                                                                                 'Clear BCX Workspace
  N := (Num < 0) & $10000000                                                                            'Remember if Num negative
  repeat                                                                                                'Calc all BCX digits
    byte[@BCX0][Digits++ >> 1] += ||(Num // Base) << (4 * Digits&1)
  while Num /= Base
  BCX3 |= N                                                                                             'If negative, set flag (highest digit of BCX Workspace)

  
PRI BCXToText(IChar, Group, ShowPlus, SPad, Field, Digits): Size | Idx, GCnt, SChar, GChar, X
'Convert BCX Buffer contents to z-string at StrBuf.
'IChar..Field each correspond to elements of Format.  See "FORMAT SYNTAX" for more information.
'If Field = 0, Digits+1+Group is the effective field (always limited to max of 49).
'Digits  : Number of significant digits (not counting zero-left-padding).
'RETURNS:    Actual Size (length) of output string, not including null terminator.
  X := 1-(IChar > 0)                                                                                    'Xtra char count (1 or 2, for sign and optional base indicator)
  IChar := Symbols[--IChar]                                                                             'Get base indicator character
  SChar := "+" + 2*(BCX3 >> 28) + 11*(not (ShowPlus | (BCX3 >> 28)) or ((Digits == 1) and (BCX0 == 0))) 'Determine sign character ('+', ' ' or '-')
  GChar := Symbols[Group & 7 - 1 #> 0]                                                                  'Get group character
  if Field > 0 and SPad^1 and Digits < 32                                                               'Need to add extra zero-padding?
    BCX3 &= $0FFFFFFF                                                                                   '  then clear negative flag and set to 32 digits
    Digits := 32
  Group := -((Group >>= 3)-(Group > 0))*(Group+1 < Digits)                                              'Get group size (0 if not enough Digits)
  Size := (Field - (Field==0)*(Digits+X+((Digits-1)/Group))) <# 49                                      'Field = 0?  Set Size to Digits+X+Group (max 49).
  if Group                                                                                              'Insert group chars
    bytefill(@StrBuf+(Size-Digits-(Digits-1)/Group #> 2), GChar, Digits+(Digits-1)/Group <# Size)
  Idx~~                                                                                                 'Insert digits
  repeat while (++Idx < Digits) and (Idx + (GCnt := Idx/Group) < Size-X)
    byte[@StrBuf][Size-Idx-1-GCnt] := lookupz(byte[@BCX0][Idx>>1] >> (4 * Idx&1) // 16: "0".."9","A".."F")
  bytefill(@StrBuf, " ", Size-Idx-(Idx-1)/Group #> 0)                                                   'Left pad with spaces, if necessary
  byte[@StrBuf][Size-X-Idx-(Idx-1)/Group #> 0] := SChar                                                 'Insert sign
  if X == 2
    byte[@StrBuf][Size-1-Idx-(Idx-1)/Group #> 1] := IChar                                               'Insert base indicator, if necessary
  byte[@StrBuf][Size] := 0                                                                              'Zero-terminate string


PRI InBaseRange(Char, Base): Value
'Compare Char against valid characters for Base (1..16) (adjusting for lower-case automatically).
'Returns 0 if Char outside valid Base chars or, if valid, returns corresponding Value+1.
   Value := ( Value -= (Char - $2F) * (Char => "0" and Char =< "9") + ((Char &= $DF) - $36) * (Char => "A" and Char =< "F") ) * -(Value < ++Base)


DAT
  DefaultSymbols        byte    ",_$%xxx"                                                               'Special, default, symbols ("x" means unused)


''
''
''**************************
''* FUNCTIONAL DESCRIPTION *
''**************************
''
''The Numbers object converts values in variables (longs) to strings and vice-versa in any base from 2 to 16.
''
''Standard/Default Features:
''   * supports full 32-bit signed values
''   * converts using any base from 2 to 16 (binary to hexadecimal)
''   * defaults to variable widths (ouputs entire number, regardless of size)
''   * uses ' ' or '-' for sign character
''
''Optional Features
''   * allows fixed widths (1 to 49 characters); left padded with either zeros (left justified) or spaces (right justified)
''   * can show plus sign for values > 0
''   * allows digit grouping (each 2 to 8 characters) with customizable separators; ex: 1000000 becomes 1,000,000 and 7AB14B9C becomes 7AB1_4B9C
''   * allows base indicator character (inserted right after sign) with customizable characters; ex: 7AB1 becomes $7AB1 and -1011 becomes -%1011 
''   * all special symbols can be customized
''
''
''**************************
''*     FORMAT SYNTAX      *
''**************************
''
''The Format parameter of ToStr() and FromStr() is a 22-bit value indicating the desired output or input format.  Custom values can be used for the Format
''parameter, however, a series of pre-defined constants for common formats as well as each of the elemental building blocks have already been defined by this
''object.  These pre-defined constants are listed below, followed by a detailed explanation of the syntax of the Format parameter.
''
''┌────────────────────────────────────────────────────────────────────────────────────────┐          ┌───────────────────────────────────────┐
''│                                 COMMON FORMAT CONSTANTS                                │          │            Working Examples           │
''├─────────────────────┬───────────┬────────────┬─────────┬─────────────┬─────────────────┤          ├────────────┬────────┬─────────────────┤
''│       CONSTANT      │ INDICATED │ DELIMITING │ PADDING │    BASE     │      WIDTH      │          │ Long Value │ Format │ String Result   │
''│                     │   BASE    │            │         │             │ (incl. symbols) │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ DEC    │ -1234           │
''│ BIN                 │           │            │         │   Binary    │     Variable    │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │    1234    │ DEC    │  1234           │
''│ IBIN                │     %     │            │         │   Binary    │     Variable    │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │    1234    │ HEX    │  4D2            │
''│ DBIN                │           │ Underscore │         │   Binary    │     Variable    │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ IHEX   │ -$4D2           │
''│ IDBIN               │     %     │ Underscore │         │   Binary    │     Variable    │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │    1234    │ BIN    │  10011010010    │
''│ BIN2..BIN33         │           │            │   Zero  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ IBIN   │ -%10011010010   │
''│ IBIN3..IBIN34       │     %     │            │   Zero  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │    1234    │ DDEC   │  1,234          │
''│ DBIN7..DBIN40       │           │ Underscore │   Zero  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ DDEC8  │ -001,234        │
''│ IDBIN8..IDBIN41     │     %     │ Underscore │   Zero  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ DSDEC8 │   -1,234        │
''│ SBIN3..SBIN33       │           │            │  Space  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │    1234    │ DBIN   │  100_1101_0010  │
''│ ISBIN4..ISBIN34     │     %     │            │  Space  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ DBIN15 │ -0100_1101_0010 │
''│ DSBIN7..DSBIN40     │           │ Underscore │  Space  │   Binary    │      Fixed      │          └────────────┴────────┴─────────────────┘
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          *Note: In these examples, all positive
''│ IDSBIN8..IDSBIN41   │     %     │ Underscore │  Space  │   Binary    │      Fixed      │                 values' output strings have a space
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤                 for the sign character.  Don't forget
''│ DEC                 │           │            │         │   Decimal   │     Variable    │                 that fact when sizing string buffer
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤                 or otherwise using result.
''│ DDEC                │           │   Comma    │         │   Decimal   │     Variable    │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ DEC2..DEC11         │           │            │   Zero  │   Decimal   │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ SDEC3..SDEC11       │           │            │  Space  │   Decimal   │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ DSDEC6..DSDEC14     │           │   Comma    │  Space  │   Decimal   │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ HEX                 │           │            │         │ Hexadecimal │     Variable    │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ IHEX                │     $     │            │         │ Hexadecimal │     Variable    │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ DHEX                │           │ Underscore │         │ Hexadecimal │     Variable    │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ IDHEX               │     $     │ Underscore │         │ Hexadecimal │     Variable    │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ HEX2..HEX9          │           │            │   Zero  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ IHEX3..IHEX10       │     $     │            │   Zero  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ DHEX7..DHEX10       │           │ Underscore │   Zero  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ IDHEX8..IDHEX11     │     $     │ Underscore │   Zero  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ SHEX3..SHEX9        │           │            │  Space  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ ISHEX4..ISHEX10     │     $     │            │  Space  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ DSHEX7..DSHEX10     │           │ Underscore │  Space  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ IDSHEX8..IDSHEX11   │     $     │ Underscore │  Space  │ Hexadecimal │      Fixed      │
''└─────────────────────┴───────────┴────────────┴─────────┴─────────────┴─────────────────┘
''
''
''If the desired format was not already defined by the Common Format Constants, above, you may use the following constants as building blocks to create
''the customer format you need.
''
''┌─────────────────────────────────────────────────────┐
''│          FORMAT CONSTANT "BUILDING BLOCKS"          │
''│ (use these if no equivelant common format exisits)  │
''├────────────────────┬────────────────────────────────┤
''│     CONSTANT       │           DESCRIPTION          │
''├────────────────────┼────────────────────────────────┤
''│ BIN, DEC or HEX    │ Binary, Decimal or Hexadecimal │
''├────────────────────┼────────────────────────────────┤
''│ CHAR1..CHAR48      │ Field Width (includes symbols) │
''├────────────────────┼────────────────────────────────┤
''│ <nothing> / SPCPAD │        Zero / Space Pad        │
''├────────────────────┼────────────────────────────────┤
''│ <nothing> / PLUS   │        Hide / Show Plus        │
''├────────────────────┼────────────────────────────────┤
''│ COMMA, USCORE      │        Group Character         │
''├────────────────────┼────────────────────────────────┤
''│ GROUP2..GROUP8     │           Group Size           │
''├────────────────────┼────────────────────────────────┤
''│ BINCHAR or HEXCHAR │      Indicator Character       │
''└────────────────────┴────────────────────────────────┘
''
''
''The detailed syntax of the Format parameter is described below.
''
''There are 7 elements of the Format parameter:
''  1) Base,
''  2) Field Width,
''  3) Zero/Space Padding,
''  4) Hide/Show Plus Sign,
''  5) Grouping Character ID,
''  6) Digit Group Size,
''  7) Indicator Character
''Only the Base element is required, all others are optional.
''
''The 22-bit syntax is as follows:
''
''  III ZZZ GGG P S FFFFFF BBBBB
''
''I : Indicator Character ID (0-7).  0 = no indicator character, 1 = Comma, 2 = Underscore, 3 = Dollar Sign, 4 = Percent Sign, etc., as defined by default Init; may be customized via call to Config().
''Z : Digit Group Size (0-7).  0 = no digit group characters, 1 = every 2 chars, 2 = every 3 chars, etc.
''G : Grouping Character ID (0-7).  0 or 1 = Comma, 2 = Underscore, etc., as defined by default Init; may be customized via call to Config().
''P : Hide/Show Plus Sign (0-1).  For Num values > 0, sign char is: ' ' (if P = 0), or '+' (if P = 1).
''S : Zero/Space Pad (0-1).  [Ignored unless Field Width > 0].  0 = left pad with zeros (left justified), 1 = left pad with spaces (right justified).
''F : Field Width (0-48).  String field width, including sign character and any special characters (not including zero terminator).
''B : Base (2-16).  Base to convert number to; 2 = binary, 10 = decimal, 16 = hexadecimal, etc.  This element is required.
''
''Examples:
''
''Conversion to variable-width decimal value:
''  Use Format of: %000_000_000_0_0_000000_01010, or simply %1010 (decimal 10).
''
''Conversion to 5-character wide, fixed-width hexadecimal value (left padded with zeros):
''  Use Format of: %000_000_000_0_0_000101_10000
''
''Conversion to 5-character wide, fixed-width hexadecimal value (left padded with spaces):
''  Use Format of: %000_000_000_0_1_000101_10000
''
''Conversion to variable-width decimal value comma-separated at thousands:
''  Use Format of: %000_010_001_0_0_000000_01010
''
''Conversion to Indicated, 6-character wide, fixed-width hexadecimal value (left padded with spaces):
''  Use Format of: %011_000_000_0_1_000110_10000
''
''For convenience and code readability, a number of pre-defined symbolic constants are included that can be added together for any format
''combination imaginable.  See "FORMAT CONSTANT 'BUILDING BLOCKS'", above.  For example, using these constants, the above example format values become
''the following, respectively:
''  DEC
''  HEX+CHAR5
''  HEX+CHAR5+SPCPAD
''  DEC+GROUP3+COMMA
''  HEX+CHAR6+HEXCHAR+SPCPAD
''
''
''┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
''│                                         32-Bit Statistics for Bases 2 to 16                                        │
''├──────┬────────────┬────────────────────────────────────────────────────────────────────────────┬───────────────────┤
''│ Base │ Max Digits │                                Range (Signed)                              │   Range Is Shown  │
''│      │ w/o symbols│               Minimum                │               Maximum               │     Grouped By    │ 
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   2  │     32     │ -10000000_00000000_00000000_00000000 │ +1111111_11111111_11111111_11111111 │    Bytes (exact)  │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   3  │     20     │             -12112_12221_21102_02102 │            +12112_12221_21102_02101 │       Bytes       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   4  │     16     │                 -2000_0000_0000_0000 │                +1333_3333_3333_3333 │    Bytes (exact)  │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   5  │     14     │                    -13_344223_434043 │                   +13_344223_434042 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   6  │     12     │                       -553032_005532 │                      +553032_005531 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   7  │     12     │                      -10_41342_11162 │                     +10_41342_11161 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   8  │     11     │                       -2_00000_00000 │                      +1_77777_77777 │  Words (15 bits)  │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   9  │     10     │                         -54787_73672 │                        +54787_73671 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  10  │     10     │                       -2,147,483,648 │                      +2,147,483,647 │ Thousands (exact) │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  11  │      9     │                         -A_0222_0282 │                        +A_0222_0281 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  12  │      9     │                         -4_BB23_08A8 │                        +4_BB23_08A7 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  13  │      9     │                         -2_82BA_4AAB │                        +2_82BA_4AAA │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  14  │      9     │                         -1_652C_A932 │                        +1_652C_A931 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  15  │      8     │                           -C87D_66B8 │                          +C87D_66B7 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  16  │      8     │                           -8000_0000 │                          +7FFF_FFFF │   Words (exact)   │
''└──────┴────────────┴──────────────────────────────────────┴─────────────────────────────────────┴───────────────────┘



CON
'
 

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
