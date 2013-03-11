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

from zmpi.core cimport MPI_Comm, MPI_Datatype, MPI_Status

cdef extern from "zmpi.h":
    int MPI_DOUBLE
    int MPI_INT
    int MPI_FLOAT
    int MPI_SUM
    int MPI_COMM_WORLD

import os
import time
import zmq

DEBUG = True

cdef class Communication:
    """Common communication tasks shared between Master and Clients.
    """
    def __init__(self):
        self.context = zmq.Context()
        self.sock_pub = self.context.socket(zmq.PUB)
        self.port_pub = self.sock_pub.bind_to_random_port("tcp://*")
        self.sock_pull = self.context.socket(zmq.PULL)
        self.port_pull = self.sock_pull.bind_to_random_port("tcp://*")


cdef class Client(Communication):
    """Client process that encapsulates the MPI layer.
    """
    def __init__(self):
        super(Client, self).__init__()
        print "Calling Client.__init__"
        self.rank = {0: int(os.environ.get("ZMPI_RANK", "0"))}
        self.size = {0: int(os.environ.get("ZMPI_SIZE", "1"))}
        self.sock_push = self.context.socket(zmq.PUSH)
        self.sock_sub = self.context.socket(zmq.SUB)
        try:
            self.sock_sub.connect(os.environ["ZMPI_MASTER_PUB"])
            self.sock_sub.setsockopt(zmq.SUBSCRIBE, "")
            self.sock_push.connect(os.environ["ZMPI_MASTER_PULL"])
            time.sleep(0.1)
            self._send = {
                            "rank": self.rank,
                            "PULL": "tcp://127.0.0.1:%d"%self.port_pull,
                        }
            self.sock_push.send_pyobj(self._send)
            self._send = self.sock_sub.recv_pyobj()

            for client in self._send[MPI_COMM_WORLD]:
                if client != self.rank[0]:
                    self._send[MPI_COMM_WORLD][client]["PUSH"] = self.context.socket(zmq.PUSH)
                    self._send[MPI_COMM_WORLD][client]["PUSH"].connect(self._send[MPI_COMM_WORLD][client]["PULL"])
                    print client
            print self._send
        except KeyError:
            pass

    def __del__(self):
        print "Calling Client.__del__"

    cdef int get_rank(self, MPI_Comm comm):
        """Get rank in the communicator.
        """
        return self.rank[comm]

    cdef int get_size(self, MPI_Comm comm):
        """Get size in the communicator.
        """
        return self.size[comm]

    cdef void send_to(self, char *buf, int count, MPI_Datatype datatype, int dest,
                      int tag, MPI_Comm comm):
        if dest == self.get_rank(comm):
            return
        # TODO send numpy array
        sending = []
        if datatype == MPI_INT:
            for i in range(count):
                sending.append((<int *> buf)[i])
        elif datatype == MPI_DOUBLE:
            for i in range(count):
                sending.append((<double *> buf)[i])
        elif datatype == MPI_FLOAT:
            for i in range(count):
                sending.append((<float *> buf)[i])
        else:
            raise NotImplementedError("MPI_Datatype %s is not supported."%(datatype))
        self._send[MPI_COMM_WORLD][dest]["PUSH"].send_pyobj(sending)

    cdef MPI_Status *recv_from(self, char *buf, int count, MPI_Datatype datatype, int dest,
                               int tag, MPI_Comm comm):
        if dest == self.get_rank(comm):
            return NULL
        msg = self.sock_pull.recv_pyobj()
        for i in range(count):
            if datatype == MPI_INT:
                (<int *>buf)[i] = msg[i]
            elif datatype == MPI_DOUBLE:
                (<double *>buf)[i] = msg[i]
            elif datatype == MPI_FLOAT:
                (<float *>buf)[i] = msg[i]
            else:
                raise NotImplementedError("MPI_Datatype %s is not supported."%(datatype))
        return NULL

    cdef MPI_reduce(self, char *bufin, char *bufout, int count, MPI_Datatype datatype,
                    MPI_Op op, int dest, MPI_Comm comm):
        if op == MPI_SUM:
            # TODO implement fancier algorithm for reducing
            if self.get_rank(comm) == dest:
                ret = []
                if datatype == MPI_INT:
                    for i in range(count):
                        ret.append((<int *> bufin)[i])
                elif datatype == MPI_DOUBLE:
                    for i in range(count):
                        ret.append((<double *> bufin)[i])
                elif datatype == MPI_FLOAT:
                    for i in range(count):
                        ret.append((<float *> bufin)[i])
                else:
                    raise NotImplementedError("MPI_Datatype %s is not supported."%(datatype))
                for i in range(self.get_size(comm)):
                    if i == dest:
                        continue
                    msg = self.sock_pull.recv_pyobj()
                    for j, item in enumerate(msg):
                        ret[j] += item
                for i in range(count):
                    if datatype == MPI_INT:
                        (<int *>bufout)[i] = ret[i]
                    elif datatype == MPI_FLOAT:
                        (<float *>bufout)[i] = ret[i]
                    elif datatype == MPI_DOUBLE:
                        (<double *>bufout)[i] = ret[i]
                    else:
                        raise NotImplementedError("MPI_Datatype %s is not supported."%(datatype))
            else:
                self.send_to(bufin, count, datatype, dest, 0, comm)
        else:
            raise NotImplementedError("MPI_Op %s is not supported."%(op))


cdef class Master(Communication):
    """Master process that handles all clients per node.

    The first Master process starts the other Master processes on other nodes.
    Each one of them will then be responsible for the starting "worker"
    clients on that node.
    """
    def __init__(self, size, ranks, cmd):
        super(Master, self).__init__()
        assert(len(ranks) == size)
        self.ranks = ranks
        self.size = size
        self.cmd = cmd

    cdef handle_startup(self):
        """Collect PULL sockets of each Client and broadcast them around.
        """
        all_sockets = {MPI_COMM_WORLD: {}}
        for i in range(self.size):
            message = self.sock_pull.recv_pyobj()
            all_sockets[MPI_COMM_WORLD][message["rank"][0]] = message
        self.sock_pub.send_pyobj(all_sockets)

    cpdef run(self):
        import subprocess
        # setup environments
        envs = []
        for i in range(self.size):
            envs.append(os.environ.copy())
            envs[i]["ZMPI_RANK"] = str(i)
            envs[i]["ZMPI_SIZE"] = str(self.size)
            envs[i]["ZMPI_MASTER_PUB"] = "tcp://127.0.0.1:%d"%(self.port_pub)
            envs[i]["ZMPI_MASTER_PULL"] = "tcp://127.0.0.1:%d"%(self.port_pull)

        if DEBUG:
            print "Starting %d processes."% self.size
            print "Executable:", self.cmd

        pool = [subprocess.Popen(self.cmd, shell=True, env=envs[i])
                for i in self.ranks]

        self.handle_startup()

        ret = [client.wait() for client in pool]
        return -min(ret)
