from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension("libzmpi",
              ["libzmpi.pyx"],
#              libraries = ['mpi_int'],
#              library_dirs = ['../include']
             ),
    Extension("zmpi.core",
              ["zmpi/core.pyx"],
             ),
    Extension("zmpi.communication",
              ["zmpi/communication.pyx"],
             )
    ]

setup(
    ext_modules = cythonize(ext_modules)
)
