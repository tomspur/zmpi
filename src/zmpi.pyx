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

import os

# data types
cdef public int MPI_INT = 1

cdef public void *MPI_STATUS_IGNORE = NULL

ctypedef public int MPI_Comm
ctypedef public int MPI_Datatype

cdef public struct MPI_Status:
    int state

cdef public int MPI_COMM_WORLD = 0
cdef int COMM_RANK = int(os.environ.get("ZMPI_RANK", "0"))
cdef int COMM_SIZE = int(os.environ.get("ZMPI_SIZE", "0"))

cdef public void ZMPI_Init(int *argc, char ***argv):
    print "calling INIT", <int> argc[0]
    for i in range(argc[0]):
        print 'arguments', argv[0][i]

cdef public void ZMPI_Finalize():
    print "calling FINALIZE"

cdef public void MPI_Comm_rank(MPI_Comm comm, int *rank):
    if comm == MPI_COMM_WORLD:
        rank[0] = COMM_RANK
    else:
        raise NotImplementedError

cdef public void MPI_Comm_size(MPI_Comm comm, int *size):
    if comm == MPI_COMM_WORLD:
        size[0] = COMM_SIZE
    else:
        raise NotImplementedError

cdef public void MPI_Send(void *buf, int count, MPI_Datatype datatype, int dest,
            int tag, MPI_Comm comm):
    pass

cdef public void MPI_Recv(void *buf, int count, MPI_Datatype datatype, int dest,
            int tag, MPI_Comm comm, MPI_Status *status):
    if status != NULL:
        raise NotImplementedError
