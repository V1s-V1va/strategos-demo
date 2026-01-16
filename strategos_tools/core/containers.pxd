#distutils: language = c
#cython: language_level 3

from strategos_tools.core.CONSTS cimport *

cdef class vector_int:

	cdef:
		uint size, capacity
		int *_data
		int1 _data_view

	cdef uint       __get_min_spanning_cap( vector_int self ) #noexcept

	cdef void       resize( vector_int self, uint newCap=* ) #noexcept

	cdef void       shrink_wrap( vector_int self ) #noexcept

	cdef bint       contains( vector_int self, int item ) #noexcept

	cdef int        at( vector_int self, uint idx ) #noexcept

	cdef uint       index_of( vector_int self, int item ) #noexcept

	cdef void       set_data( vector_int self, int1 from_view ) #noexcept

	cdef void       append( vector_int self, int newElement ) #noexcept

	cdef int        pop( vector_int self ) #noexcept

	cdef void       replace( vector_int self, uint at_idx, int newItem ) #noexcept

	cdef vector_int copy( vector_int self ) #noexcept

	cdef vector_int without( vector_int self, int item ) #noexcept

	cdef int1       view( vector_int self ) #noexcept

cdef class vector_dbl:

	cdef:
		uint    size, capacity
		double *_data
		dbl1    _data_view

	cdef uint       __get_min_spanning_cap( vector_dbl self ) #noexcept

	cdef void       resize( vector_dbl self, uint newCap=* ) #noexcept

	cdef void       shrink_wrap( vector_dbl self ) #noexcept

	cdef bint       contains( vector_dbl self, double item ) #noexcept

	cdef double     at( vector_dbl self, uint idx ) #noexcept

	cdef uint       index_of( vector_dbl self, double item ) #noexcept

	cdef void       set_data( vector_dbl self, dbl1 from_view ) #noexcept

	cdef void       append( vector_dbl self, double newElement ) #noexcept

	cdef double     pop( vector_dbl self ) #noexcept

	cdef void       replace( vector_dbl self, uint at_idx, double newItem ) #noexcept

	cdef vector_dbl copy( vector_dbl self ) #noexcept

	cdef vector_dbl without( vector_dbl self, double item ) #noexcept

	cdef dbl1 view( vector_dbl self ) #noexcept

cdef class vector_ll:

	cdef:
		uint size, capacity
		ll  *_data
		ll1  _data_view

	cdef uint      __get_min_spanning_cap( vector_ll self ) #noexcept

	cdef void      resize( vector_ll self, uint newCap=* ) #noexcept

	cdef void      shrink_wrap( vector_ll self ) #noexcept

	cdef bint      contains( vector_ll self, ll item ) #noexcept

	cdef ll        at( vector_ll self, uint idx ) #noexcept

	cdef uint      index_of( vector_ll self, ll item ) #noexcept

	cdef void      set_data( vector_ll self, ll1 from_view ) #noexcept

	cdef void      append( vector_ll self, ll newElement ) #noexcept

	cdef ll        pop( vector_ll self ) #noexcept

	cdef void      replace( vector_ll self, uint at_idx, ll newItem ) #noexcept

	cdef vector_ll copy( vector_ll self ) #noexcept

	cdef vector_ll without( vector_ll self, ll item ) #noexcept

	cdef ll1       view( vector_ll self ) #noexcept

cdef class vector_str:

	cdef:
		uint   size, capacity
		void **_data
		list   __dataList
		#Objects must be kept in ^this list simply so they stay alive & in place for the pointers stored in _data
		#NB this list is not intended to ever be used for access as py list access is very inefficient
		#For access, get node ptr from _data and do <str> cast instead; this SHOULD bypass python overhead

	cdef uint __get_min_spanning_cap( vector_str self ) #noexcept

	cdef void resize( vector_str self, uint newCap=* ) #noexcept

	cdef void shrink_wrap( vector_str self ) #noexcept

	cdef void append( vector_str self, str newItem ) #noexcept

	cdef str  at( vector_str self, uint idx ) #noexcept

cdef class matrix_int:

	cdef:
		uint size, nrows, ncols, rowsize
		int *_data
		int2 _data_view

	cdef void set_data( matrix_int self, int2 from_view ) #noexcept

	cdef int2 view( matrix_int self ) #noexcept

cdef class matrix_flt:

	cdef:
		uint   size, nrows, ncols, rowsize
		float *_data
		flt2   _data_view

	cdef void set_data( matrix_flt self, flt2 from_view ) #noexcept

	cdef flt2 view( matrix_flt self ) #noexcept

cdef class matrix_dbl:

	cdef:
		uint    size, nrows, ncols, rowsize
		double *_data
		dbl2    _data_view

	cdef void set_data( matrix_dbl self, dbl2 from_view ) #noexcept

	cdef dbl2 view( matrix_dbl self ) #noexcept

cdef class MultiMat:

	cdef:
		uint   size, nmats, matsize, nrows, rowsize, ncols
		float *_data
		flt3   _data_view

	cdef void set_matrix( MultiMat self, uint matIdx, flt2 from_data ) #noexcept

	cdef flt3 view( MultiMat self ) #noexcept

	cdef void replace( MultiMat self, uint at_idx, matrix_flt newMat ) #noexcept

cdef class index_map:

	cdef vector_ll  Keys
	cdef vector_int Indices

	cdef int  at( index_map self, ll key ) #noexcept

	cdef void append( index_map self, ll newKey, int newIndex ) #noexcept
