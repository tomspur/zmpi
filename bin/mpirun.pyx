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

import argparse
import os
import subprocess
import sys

from zmpi.communication cimport Master
cdef Master master

parser = argparse.ArgumentParser(description='Start MPI jobs.')
parser.add_argument("-np", dest="np", type=int)
args, pos_args = parser.parse_known_args()
pos_args = " ".join(pos_args)

#TODO parse hostfile
#TODO how many processes on this host?
ranks = [i for i in range(args.np)]
#TODO setup args.np == size of processes on this host
proc = subprocess.Popen("mpimaster -np %d --ranks '%s' --cmd '%s'"%(args.np, ranks, pos_args), shell=True)

sys.exit(proc.wait())
