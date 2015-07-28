# Copyright (c) 2013 Thomas Spura
#
# This file is part of ZMPI.
#
# ZMPI is free software; you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# ZMPI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

from zmpi.core cimport MPI_Comm, MPI_Datatype, MPI_Op, MPI_Status
from zmpi.communication cimport Client

cdef Client client

cdef public void *MPI_STATUS_IGNORE = NULL

cdef public void ZMPI_Init(int *argc, char ***argv):
    global client
    client = Client()
    print "calling INIT", <int> argc[0]
    for i in range(argc[0]):
        print 'arguments', argv[0][i]

cdef public void ZMPI_Finalize():
    global client
    #TODO Deletion of global C variable not allowed anymore with newer cython
    #     Properly shut it down
    #del client

cdef public void MPI_Comm_rank(MPI_Comm comm, int *rank):
    rank[0] = client.get_rank(comm)

cdef public void MPI_Comm_size(MPI_Comm comm, int *size):
    size[0] = client.get_size(comm)

cdef public void MPI_Send(char *buf, int count, MPI_Datatype datatype, int dest,
                          int tag, MPI_Comm comm):
    client.send_to(buf, count, datatype, dest, tag, comm)

cdef public void MPI_Recv(char *buf, int count, MPI_Datatype datatype, int dest,
                          int tag, MPI_Comm comm, MPI_Status *status):
    state = client.recv_from(buf, count, datatype, dest, tag, comm)
    if status != MPI_STATUS_IGNORE:
        status = state

cdef public void MPI_Reduce(char *bufout, char *bufin, int count, MPI_Datatype datatype,
                            MPI_Op op, int dest, MPI_Comm comm):
    client.MPI_reduce(bufout, bufin, count, datatype, op, dest, comm)
