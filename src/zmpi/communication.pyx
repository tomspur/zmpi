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
            self.init = {
                            "rank": self.rank,
                            "PULL": "tcp://127.0.0.1:%d"%self.port_pull,
                        }
            self.sock_push.send_json(self.init)
            self.init = self.sock_sub.recv_json()
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

    cdef MPI_Status *recv_from(self, char *buf, int count, MPI_Datatype datatype, int dest,
                               int tag, MPI_Comm comm):
        if dest == self.get_rank(comm):
            return NULL
        return NULL


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
        all_sockets = {}
        for i in range(self.size):
            message = self.sock_pull.recv_json()
            all_sockets[message["rank"]["0"]] = message
        self.sock_pub.send_json(all_sockets)

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
