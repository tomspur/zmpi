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

#import multiprocessing
from zmq.core.context cimport Context
from zmq.core.socket cimport Socket
from zmpi.core cimport MPI_Comm, MPI_Datatype, MPI_Status

cdef class Communication:#(multiprocessing.Process):
    cdef Context context
    cdef Socket sock_pub
    cdef Socket sock_pull
    cdef Socket sock_sub
    cdef int port_pub
    cdef int port_pull
    cdef int port_sub

cdef class Client(Communication):
    cdef Socket sock_push
    cdef object rank
    cdef object size
    cdef int get_rank(self, MPI_Comm comm)
    cdef int get_size(self, MPI_Comm comm)
    cdef void send_to(self, char *buf, int count, MPI_Datatype datatype, int dest,
                      int tag, MPI_Comm comm)
    cdef MPI_Status *recv_from(self, char *buf, int count, MPI_Datatype datatype, int dest,
                               int tag, MPI_Comm comm)

cdef class Master(Communication):
    cdef str cmd
    # TODO ndarray?
    cdef object ranks
    cdef int size
    cpdef run(self)
