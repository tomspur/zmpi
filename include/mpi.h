/*
 *  Copyright (c) 2012 Thomas Spura
 *
 *  This file is part of ZMPI.
 *
 *  ZMPI is free software; you can redistribute it and/or modify it under
 *  the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  ZMPI is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#ifndef MPI_H
#define MPI_H

/* Expose Python.h into zmpi */
#include <Python.h>
#include <zmpi.h>

/* temporary for printing */
#include <stdlib.h>

/* wrap init and finalize of zmpi */
void MPI_Init(int *argc, char ***argv) {
    Py_Initialize();
    initzmpi();
    ZMPI_Init(argc, argv);
};

void MPI_Finalize() {
    ZMPI_Finalize();
    Py_Finalize();
};

#endif /* MPI_H */
