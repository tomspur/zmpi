#include <assert.h>
#include <stdio.h>
#include <mpi.h>
#include <time.h>

int main (int argc, char **argv) {
    int rank, size;
    MPI_Init (&argc, &argv);
    MPI_Comm_rank (MPI_COMM_WORLD, &rank);
    MPI_Comm_size (MPI_COMM_WORLD, &size);
    int number = 0;
    MPI_Reduce(&rank, &number, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    printf("Rank %d got number %d\n", rank, number);
    if (rank == 0)
        assert(number == size*(size-1)/2);
    MPI_Finalize();
    return 0;
}
