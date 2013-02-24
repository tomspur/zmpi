#include <stdio.h>
#include <mpi.h>

int main (int argc, char **argv) {
    int rank, size;
    MPI_Init (&argc, &argv);
    MPI_Comm_rank (MPI_COMM_WORLD, &rank);
    MPI_Comm_size (MPI_COMM_WORLD, &size);
    int number = -1;
    int i;
    if (size > 0) {
        if (rank == 0) {
            for (i = 0; i < size; i++) {
                number = i*i;
                MPI_Send(&number, 1, MPI_INT, i, 0, MPI_COMM_WORLD);
                printf("Process %d sent number %d to process %d\n", rank, number, i);
            }
        } else {
            MPI_Recv(&number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            printf("Process %d received number %d from process %d\n", rank, number, rank-1);
            assert(number == rank*rank);
        }
    } else {
        printf("Rank must be bigger than 0 for a ping-pong.\n");
    }
    MPI_Finalize();
    return 0;
}
