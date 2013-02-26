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
##import zmq

DEBUG = True

cdef class Communication:
    """Common communication tasks shared between Master and Clients.
    """
    def __init__(self):
        self.rank = 0
        self.size = 0

cdef class Client(Communication):
    """Client process that encapsulates the MPI layer.
    """
    def __cinit__(self):
        super(Client, self).__init__()
        self.rank = 1111

    def __init__(self):
        super(Client, self).__init__()
        print "Calling Client.__init__"
        self.rank = int(os.environ.get("ZMPI_RANK", "0"))
        self.size = int(os.environ.get("ZMPI_SIZE", "0"))


cdef class Master(Communication):
    """Master process that handles all clients per node.

    The first Master process starts the other Master processes on other nodes.
    Each one of them will then be responsible for the starting "worker"
    clients on that node.
    """
    def __init__(self, size, cmd):
        super(Master, self).__init__()
        self.size = size
        self.cmd = cmd
#        self.port_rep_master = 0
#        #self.sock_rep_master = self.context.socket(zmq.REP)
#        #self.port_rep_master = self.sock_rep_master.bind_to_random_port("tcp://*")
        self.port_rep_master = 234
#
    cpdef run(self):
        import subprocess
        # setup environments
        envs = []
        for i in range(self.size):
            envs.append(os.environ.copy())
            envs[i]["ZMPI_RANK"] = str(i)
            envs[i]["ZMPI_SIZE"] = str(self.size)
            envs[i]["ZMPI_PORT"] = str(self.port_rep_master)
        
        pool = []
        for i in range(self.size):
            pool.append(subprocess.Popen(self.cmd, shell=True, env=envs[i]))
        
        ret = []
        for item in pool:
            ret.append(item.wait())
        return -min(ret)
