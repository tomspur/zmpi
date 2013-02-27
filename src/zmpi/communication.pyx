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
import os
import zmq

DEBUG = True

cdef class Communication:
    """Common communication tasks shared between Master and Clients.
    """
    def __init__(self):
        self.rank = 0
        self.size = 0
        self.context = zmq.Context()
        self.sock_pub = self.context.socket(zmq.PUB)
        self.port_pub = self.sock_pub.bind_to_random_port("tcp://*")


cdef class Client(Communication):
    """Client process that encapsulates the MPI layer.
    """
    def __init__(self):
        super(Client, self).__init__()
        print "Calling Client.__init__"
        self.rank = int(os.environ.get("ZMPI_RANK", "0"))
        self.size = int(os.environ.get("ZMPI_SIZE", "0"))
        self.sock_sub = self.context.socket(zmq.SUB)
        self.sock_sub.connect(os.environ["ZMPI_PORT_SUB"])

    def __del__(self):
        print "Calling Client.__del__"


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

    cpdef run(self):
        import subprocess
        # setup environments
        envs = []
        for i in range(self.size):
            envs.append(os.environ.copy())
            envs[i]["ZMPI_RANK"] = str(i)
            envs[i]["ZMPI_SIZE"] = str(self.size)
            envs[i]["ZMPI_PORT_SUB"] = "tcp://127.0.0.1:%d"%(self.port_pub)

        if DEBUG:
            print "Starting %d processes."% self.size
            print "Executable:", self.cmd

        pool = []
        for i in self.ranks:
            pool.append(subprocess.Popen(self.cmd, shell=True, env=envs[i]))
        
        ret = []
        for item in pool:
            ret.append(item.wait())
        return -min(ret)
