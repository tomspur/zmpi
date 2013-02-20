#  Copyright (c) 2011 Thomas Spura
#
#  This file is part of ZMPI.
#
#  ZMPI is free software; you can redistribute it and/or modify it under
#  the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  ZMPI is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

cdef public int MPI_COMM_WORLD = 0
cdef int COMM_RANK
cdef int COMM_SIZE

cdef public void ZMPI_Init(int *argc, char ***argv):
    print "calling INIT", <int> argc[0]
    COMM_RANK = 0
    for i in range(argc[0]):
        print 'arguments', argv[0][i]

cdef public void ZMPI_Finalize():
    print "calling FINALIZE"

cdef public void MPI_Comm_rank(int comm, int *rank):
    if comm == MPI_COMM_WORLD:
        rank[0] = COMM_RANK
    else:
        raise NotImplementedError

cdef public void MPI_Comm_size(int comm, int *size):
    if comm == MPI_COMM_WORLD:
        size[0] = COMM_SIZE
    else:
        raise NotImplementedError
