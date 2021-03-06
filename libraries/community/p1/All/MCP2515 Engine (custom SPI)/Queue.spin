{{File: Queue.spin}}
{{

┌───────────────────────────────────┬─────────────────────────────────────────┬───────────────┐
│ Queue v1.0                        │ (C)2007 Stephen Moraco, KZ0Q            │ 08 Dec 2007   │
├───────────────────────────────────┴─────────────────────────────────────────┴───────────────┤
│  This program is free software; you can redistribute it and/or                              │
│  modify it under the terms of the GNU General Public License as published                   │
│  by the Free Software Foundation; either version 2 of the License, or                       │
│  (at your option) any later version.                                                        │
│                                                                                             │
│  This program is distributed in the hope that it will be useful,                            │
│  but WITHOUT ANY WARRANTY; without even the implied warranty of                             │
│  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                              │
│  GNU General Public License for more details.                                               │
│                                                                                             │
│  You should have received a copy of the GNU General Public License                          │
│  along with this program; if not, write to the Free Software                                │
│  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA                  │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ Premise: implement general purpose queue for reuse (multiple instantiation) in app.         │
│                                                                                             │
│ NOTE: empty/full, under/overflow variables are kept so querying them does not require       │
│    use of lock (set/clear)  they are only set/cleared during code which is protected        │
│    by the lock for this queue.                                                              │
│                                                                                             │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ Revision History                                                                            │
│                                                                                             │
│ v1.0  Initial Draft                                                                         │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

}}

CON

  MAX_QUEUE_ENTRIES = 32        ' keep under 256 and power-of-2 for byte head/tail indexes to work!
  ENTRY_SIZE_IN_LONGS = 4       ' 4 longs = 16 bytes
  
  ' markers indicating state of each entry
  MARK_FILLED = $5f             ' (f)illed
  MARK_EMPTY = $3e              ' (e)mpty

  ' calculated values for use within our code
  QUEUE_INDEX_MASK = MAX_QUEUE_ENTRIES - 1
  EMPTY_FLAG_BYTE_OFFSET = (ENTRY_SIZE_IN_LONGS*4)-1   ' byte 15 of 0-15 within 16byte entry is our flag


VAR
  long  m_entryListAr[MAX_QUEUE_ENTRIES]
  long  m_entryDataAr[MAX_QUEUE_ENTRIES * ENTRY_SIZE_IN_LONGS]

  byte  m_nHeadIdx              ' 8 contiguous bytes!
  byte  m_nTailIdx
  byte  m_bIsEmpty
  byte  m_bIsFull
  byte  m_bDidOverflow
  byte  m_bDidUnderflow
  byte  m_nNbrQueued
  byte  m_nMaxQueued

  byte  m_nLockID               ' semaphore ID for this QUEUE


PUB Init | nIdx

'' Initialize our queue preparing it for first use

  ' preset variables
  m_nHeadIdx := 0
  m_nTailIdx := 0
  m_bIsEmpty := TRUE
  m_bIsFull := FALSE
  m_bDidOverflow := FALSE
  m_bDidUnderflow := FALSE
  m_nNbrQueued := 0
  m_nMaxQueued := 0

  m_nLockID := locknew

  repeat nIdx from 0 to MAX_QUEUE_ENTRIES - 1
    m_entryListAr[nIdx] := @long [@m_entryDataAr][nIdx*ENTRY_SIZE_IN_LONGS]
    MarkEntryEmpty(m_entryListAr[nIdx])


PUB IsNextEntryEmpty : bEntryState | pEntryBffr

'' determine if the next entry to be en-queued (head) is empty and ready to be reused
''  Return T/F where T means the next entry is ready to be removed from the QUEUE

  ' if we have a semaphore, lock it now
  if m_nLockID <> -1
    repeat until not lockset(m_nLockID)

  bEntryState := FALSE

  pEntryBffr := m_entryListAr[m_nHeadIdx]

  if IsEntryEmpty(pEntryBffr)
    bEntryState := TRUE

  ' if we have a semaphore, unlock it now
  if m_nLockID <> -1
    lockclr(m_nLockID)


PUB AllocEntry : pEntryBffr | nNextHeadIdx

'' logically add an entry to the head of the QUEUE

  ' if we have a semaphore, lock it now
  if m_nLockID <> -1
    repeat until not lockset(m_nLockID)

  pEntryBffr := m_entryListAr[m_nHeadIdx]

  nNextHeadIdx := (m_nHeadIdx + 1) & QUEUE_INDEX_MASK
  if (nNextHeadIdx == m_nTailIdx)

    m_bDidOverflow := TRUE
    m_bIsFull := TRUE

  else

    m_bIsEmpty := FALSE
    m_bIsFull := FALSE

    m_nHeadIdx := (m_nHeadIdx + 1) & QUEUE_INDEX_MASK

    m_nNbrQueued++
    if m_nNbrQueued > m_nMaxQueued
      m_nMaxQueued := m_nNbrQueued

  ' if we have a semaphore, unlock it now
  if m_nLockID <> -1
    lockclr(m_nLockID)


PUB MarkEntryFilled(pEntryBffr)

'' mark removed entry as being in use

  byte [pEntryBffr][EMPTY_FLAG_BYTE_OFFSET] := MARK_FILLED


PUB IsNextEntryFilled : bEntryState | pEntryBffr

'' determine if the next entry to be de-queued (tail) is filled and ready to be removed
''  Return T/F where T means the next entry is filled and ready to be removed from the QUEUE

  ' if we have a semaphore, lock it now
  if m_nLockID <> -1
    repeat until not lockset(m_nLockID)

  bEntryState := FALSE

  if NOT IsEmpty
    pEntryBffr := m_entryListAr[m_nTailIdx]
    if NOT IsEntryEmpty(pEntryBffr)
      bEntryState := TRUE

  ' if we have a semaphore, unlock it now
  if m_nLockID <> -1
    lockclr(m_nLockID)


PUB PopEntry : pEntryBffr

'' logically remove an entry from the tail of the QUEUE

  ' if we have a semaphore, lock it now
  if m_nLockID <> -1
    repeat until not lockset(m_nLockID)

  pEntryBffr := m_entryListAr[m_nTailIdx]

  if m_nTailIdx == m_nHeadIdx

    m_bDidUnderflow := TRUE
    m_bIsEmpty := TRUE

  else

    m_bIsFull := FALSE
    m_bIsEmpty := FALSE
    m_nTailIdx := (m_nTailIdx + 1) & QUEUE_INDEX_MASK

    m_nNbrQueued--
    if m_nNbrQueued == 0
      m_bIsEmpty := TRUE

  ' if we have a semaphore, unlock it now
  if m_nLockID <> -1
    lockclr(m_nLockID)


PUB MarkEntryEmpty(pEntryBffr)

'' mark removed entry as being available for re-use

  byte [pEntryBffr][EMPTY_FLAG_BYTE_OFFSET] := MARK_EMPTY


PRI IsEntryEmpty(pEntryBffr) : bEmptyState

' return T/F where T means that this entry is empty (not filled)

  bEmptyState := byte [pEntryBffr][EMPTY_FLAG_BYTE_OFFSET] == MARK_EMPTY


PUB IsEmpty : bEmptyState

'' return T/F where T means the queue is currently empty

  bEmptyState :=  m_bIsEmpty


PUB IsFull : bFullState

'' return T/F where T means the queue is currently full

  bFullState := m_bIsFull


PUB DidOverflow : bOverflowState

'' return T/F where T means we have attempted to place too many entries on this queue

  bOverflowState := m_bDidOverflow


PUB DidUnderflow : bUnderflowState

'' return T/F where T means we have attempted to remove too many entries from this queue (there weren't any more)

  bUnderflowState := m_bDidUnderflow


PUB GetQueueState(pBffr)

'' return 8-bytes into callers memory [hdIdx, tlIdx, bIsEmpty, bIsFull, bOverflow, bUnderflow, nNbrEntries, nMaxEntries]

  byteMove(pBffr,@m_nHeadIdx,8)


PUB GetAddrOfQueueVars(pBeginAddr, pEndAddr)            '' (DBG) return address range of Queue VARs section (All data associated with this Queue)

   long [pBeginAddr] := @m_entryListAr
   long [pEndAddr] := (((@m_nLockID) + 3) & $fffffffc) - 1
   
  