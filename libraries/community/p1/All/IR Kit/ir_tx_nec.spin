{{ trytoggle.spin

  Bob Belleville

  This object implements the NEC IR transmission format to
  send data via IR.

  Attach some circuit like this to your chosen pin:
  
       5VDC
        
        └────────┐              ┌───┐
           R1  IR    │              │   │ 2N7000 front view (flat side)
               LED   │              └┬┬┬┘
                     │D              │││
        P0 ──────── 2N7000        SGD
                  G  │S
                     
                    Vss

  Select R1 value so that the current through the Led is
  about the ABS MAX rating.  It is pulsed so you might be
  able to go a bit beyond (say 25%) max but 100% is safer.
  Remember to account for the Led voltage drop and the
  sat. voltage of the 2N7000.  This will be perhaps 0.6V
  and 1.5V about.  Mine was about 34ohms for about 100 ma.
  The 30ma from the prop may run some high output LEDs
  directly, but not the one I had about.

  see readme.pdf for more documentaton

  2007/03/06 - from scratch but cribbing from FullDuplex.spin
  2007/03/10 - clean up, fix 4.5ms vs 2.25ms space error

}}
 
CON
        
VAR

                      'three longs, this order, kept together
  long  irxpin        'pin mask
  long  busy          '1 if transmitting else 0
  long  keycode       'data to transmit

OBJ

PUB start(pin)

  irxpin := |< pin
  busy~
  return cognew(@nec32, @irxpin)

PUB send(code)
{{
  transmit 1 nec ir code
  code is 00KKDDDD for new code
          80000000 for a repeat
  will block until transmitter free
  ~108ms per code
}}
  repeat while busy             'spin lock until free
  keycode := code
  busy    := 1

            
DAT
{       2     3         4       5               6       7                       }
                        org     0
nec32                   mov     addr,par                'get pin mask
                        rdlong  xpin,addr
                        or      dira,xpin               'output to circuit
                        
:waitany                mov     addr,par                'check busy
                        add     addr,#4                 'busy (a long)
                        rdlong  val,addr        wz
              if_z      jmp     #:waitany
                        add     addr,#4                 'get keycode long
                        rdlong  xbuff,addr
                        sub     addr,#4
                        
                        mov     codestart,cnt           'to get codes spaced
                        
                        call    #leadin                 'start burst
                        
                        rol     xbuff,#1        wc,nr   '8000_0000 means repeat
              if_c      jmp     #:repeat
              
                        mov     ntd,longspace           '2.25 ms here
                        call    #space                  'brings to 4.5 ms new code
                        
                        mov     val,xbuff               '1's comp key code
                        shr     val,#16
                        xor     val,#$FF
                        shl     val,#24                 'to high order byte
                        or      xbuff,val
                        call    #dataout
:repeat                        
                        call    #leadout                'stop burst pair

                        mov     val,#0
                        wrlong  val,addr                'clear busy flag
                        jmp     #:waitany

space         'given ntd set to the number of cnt cycles to space
              '  do nothing at all
                        mov     timer,cnt               'current time
                        add     timer,ntd
                        waitcnt timer,#0
space_ret               ret
                        
mark          'given ntd set as a count of carrier cycles to transmit
              'modulate led at 38KHz
                        mov     timer,cnt               'sync to 38KHz
                        add     timer,cnt38khz
:onecycle                                               '1 carrier cycle
                                                        'led on 8.77 usec
                                                        '26.3usec total = 38Khz
                        or      outa,xpin               'led on
                        mov     timer2,cnt              'and LED on time
                        add     timer2,carrieron                                                
                        waitcnt timer2,#0
                        andn    outa,xpin               'off
                        waitcnt timer,cnt38khz          'for next
                        djnz    ntd,#:onecycle          'number to do
mark_ret                ret                        

leadin        'generate a leadin burst pair

                        mov     ntd,longmark
                        call    #mark
                        mov     ntd,longspace           '2.25 ms here
                        call    #space
leadin_ret              ret                        

leadout       'generate a leadout burst 'pair'
                        mov     ntd,bitmark
                        call    #mark
                        add     codestart,intercode
                        waitcnt codestart,#0
leadout_ret             ret                        

send1         'send a 1 burst
                        mov     ntd,bitmark
                        call    #mark
                        mov     ntd,bitone
                        call    #space
send1_ret               ret
                        
send0         'send a 0 burst
                        mov     ntd,bitmark
                        call    #mark
                        mov     ntd,bitzero
                        call    #space
send0_ret               ret
                        
dataout       'transmit 32 bits from data
                        mov     nbits,#32
:l1                     ror     xbuff,#1        wc      'lsb first
        if_c            call    #send1
        if_nc           call    #send0
                        djnz    nbits,#:l1
dataout_ret             ret                                                
                        
                                                        'initialized cog mem
cnt38khz      long      2105
longmark      long      342                             'carrier cycles in leadin mark
bitmark       long      21                              'carrier cycles in bit mark
carrieron     long      702                             'prop cycles in led on time 
longspace     long        180_000                       'prop cycles in 0.5 leadin space
bitone        long        135_200                       'prop cycles in 1 bit space
bitzero       long         45_200                       '               0 bit space
intercode     long      8_640_000                       '108 ms between chars min

                                                        'allocated cog mem
xpin          res       1                               'output pin
ntd           res       1                               'number of carrier cycles
                                                        '  or space delay
timer         res       1                               'for spaces
timer2        res       1                               'for LED on
codestart     res       1                               'cnt at start of code
nbits         res       1                               'number of bits to send
xbuff         res       1                               'data bits
addr          res       1                               'working address
val           res       1                               'working value
