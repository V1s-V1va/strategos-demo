#distutils: language = c
#cython: language_level 3

from strategos_tools.core.CONSTS cimport *


cdef class gameevent:

	cdef uint  Type, PlayedBy, RaiseAmt, BetTotal, Is_AllIn, AllInDiff, DealTo, CDealt

	cdef void  __AUTOINIT__( gameevent self, uint1 from_array ) #noexcept

	cdef void  __MANUAL_INIT__( gameevent self, uint eventType, uint playedBy, uint raiseAmt, uint betTotal, 
								uint is_allin, uint allInDiff, uint dealTo, uint cDealt ) #noexcept

	cdef bint  __EQ__( gameevent self, gameevent e ) #noexcept

	cdef uint1   to_array( gameevent self ) #noexcept

	cdef str     GTString( gameevent self ) #noexcept

	cdef str     ShortString( gameevent self ) #noexcept

	cdef str     ShorterString( gameevent self, uint stepNum, bint Include_Array=* ) #noexcept


cdef uint2 AllNonRaises( uint player, uint callAmt=*, bint allin_call=*, uint callDiff=* ) #noexcept

cdef bint  Is_Dealer_Action( uint1 e ) #noexcept

cdef bint  Is_Null( uint1 e ) #noexcept

# *-* #