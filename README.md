# zmpi
MPI implementation build on top of ZeroMQ

This project was started to try out the possibility to implement MPI based on `python-zmq`,
i.e. ZeroMQ sockets are used to send the data back and forth and everything is implemented in python+cython.

Currently this implementation cannot do much and is not usable in the current state.
Yet, maybe it will be usefull in the future or I find the time again to play with it.
Based on the ZeroMQ sockets and python implementation, this project is not much more than a proof of concept
and it is very unlikely that it will be competitive to openmpi/mpich or other MPI implementations.
