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
import sys

from zmpi.communication cimport Master
cdef Master master

parser = argparse.ArgumentParser(description='Start Master of zmpi.')
parser.add_argument("-np", dest="np", type=int)
parser.add_argument("--ranks", dest="ranks", type=str)
parser.add_argument("--cmd", dest="cmd", type=str)
args = parser.parse_args()

# TODO other type in parser?
args.ranks = eval(args.ranks)
master = Master(size=args.np, ranks=args.ranks, cmd=args.cmd)

sys.exit(master.run())
