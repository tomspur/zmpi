#include <assert.h>
#include <stdio.h>
#include <mpi.h>
#include <math.h>
#include <time.h>

#define ARRAY 10

int main (int argc, char **argv) {
    int rank, size;
    MPI_Init (&argc, &argv);
    MPI_Comm_rank (MPI_COMM_WORLD, &rank);
    MPI_Comm_size (MPI_COMM_WORLD, &size);
    float number = 0;
    int i, j;
    int *array = (int *)malloc(ARRAY*sizeof(float));
    if (size > 1) {
        if (rank == 0) {
            /* create array on processor 0 */
            for (i = 0; i < ARRAY; i++) {
                array[i] = i*i;
                printf("MASTER Number %d %d\n", i, array[i]);
            }
            for (i = 1; i < size; i++) {
                MPI_Send(array, ARRAY, MPI_FLOAT, i, 0, MPI_COMM_WORLD);
                printf("Process %d sent array to process %d\n", rank, i);
            }
            for (i = 1; i < size; i++) {
                number = 0;
                MPI_Recv(&number, 1, MPI_FLOAT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
                printf("Process 0 got sum %d\n", number);
                number += 0.1;
                assert(fabs(number - 285.1) < 1e-5);
            }
        } else {
            MPI_Recv(array, ARRAY, MPI_FLOAT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            printf("Process %d received array from process %d\n", rank, 0);
            for (i = 0; i < ARRAY; i++) {
                number += array[i];
                printf("Number %d %d %d\n", i, array[i], number);
            }
            MPI_Send(&number, 1, MPI_FLOAT, 0, 0, MPI_COMM_WORLD);
        }
    } else {
        printf("Rank must be bigger than 0 for a ping-pong.\n");
    }
    free(array);
    MPI_Finalize();
    return 0;
}
