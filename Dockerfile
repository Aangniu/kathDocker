# syntax=docker/dockerfile:1
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
    # bzip2 \
    # ca-certificates \
    cmake \
    g++ \
    gcc \
    gfortran \
    git \
    # libgomp1 \
    # libnuma-dev \
    # libnuma1 \
    # libocct-data-exchange-7.5 \
    # libocct-data-exchange-dev \
    # libocct-foundation-7.5 \
    # libocct-foundation-dev \
    # libocct-modeling-algorithms-7.5 \
    # libocct-modeling-algorithms-dev \
    # libocct-modeling-data-7.5 \
    # libocct-modeling-data-dev \
    # libopenblas-base \
    # libopenblas-dev \
    libopenmpi-dev \
    libopenmpi3 \
    libreadline-dev \
    # libtbb2 \
    libyaml-cpp-dev \
    make \
    pkg-config \
    python3 \
    python3-numpy \
    python3-pip \
    wget \
    vim \
    # zlib1g \
    # zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

## New for umbridge
# RUN pip install matplotlib


RUN mkdir -p /home/tools

WORKDIR /tmp
RUN wget --progress=bar:force:noscroll https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.7/src/hdf5-1.10.7.tar.bz2 \
    && tar -xvf hdf5-1.10.7.tar.bz2 \
    && cd hdf5-1.10.7 \
    && CFLAGS="-fPIC" CC=mpicc FC=mpif90 ./configure --enable-parallel --with-zlib --disable-shared --enable-fortran --prefix /home/tools \
    && make -j$(nproc) && make install

RUN wget --progress=bar:force:noscroll ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-c-4.7.4.tar.gz \
    && tar -xvf netcdf-c-4.7.4.tar.gz \
    && cd netcdf-c-4.7.4 \
    && CFLAGS="-fPIC" CC=/home/tools/bin/h5pcc ./configure --enable-shared=no --prefix=/home/tools --disable-dap \
    && make -j$(nproc) && make install

RUN wget https://ftp.mcs.anl.gov/pub/pdetools/spack-pkgs/parmetis-4.0.3.tar.gz \
    && tar -xvf parmetis-4.0.3.tar.gz \
    && cd parmetis-4.0.3 \
    && sed -i 's/IDXTYPEWIDTH 32/IDXTYPEWIDTH 64/g' ./metis/include/metis.h \
    && CC=mpicc CXX=mpicxx make config prefix=/home/tools \
    && make -j$(nproc) && make install \
    && cp build/Linux-x86_64/libmetis/libmetis.a /home/tools/lib \
    && cp metis/include/metis.h /home/tools/include

RUN wget --progress=bar:force:noscroll https://www.lua.org/ftp/lua-5.3.6.tar.gz \
    && tar -xzvf lua-5.3.6.tar.gz \
    && cd lua-5.3.6 && make linux CC=mpicc && make local \
    && cp -r install/* /home/tools && cd ..

RUN wget --progress=bar:force:noscroll https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz \
    && tar -xf eigen-3.4.0.tar.gz \
    && cd eigen-3.4.0 && mkdir build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools \
    && make -j$(nproc) install

# RUN git clone https://github.com/OSGeo/PROJ.git \
#     && cd PROJ && git checkout 4.9.3 \
#     && mkdir build && cd build \
#     && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools \
    # && make -j$(nproc) && make install

RUN git clone https://github.com/hfp/libxsmm.git \
    && cd libxsmm \
    && git checkout 1.16.1 \
    && make -j$(nproc) generator \
    && cp bin/libxsmm_gemm_generator /home/tools/bin

### Put all dependencies, which point to a specific version, before this comment
### Put all dependencies, which use the lates version, after this comment to reduce build time

RUN git clone https://github.com/TUM-I5/ASAGI.git \
    && cd ASAGI \
    && git submodule update --init \
    && mkdir build && cd build \
    && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools -DSHARED_LIB=off -DSTATIC_LIB=on -DNONUMA=on \
    && make -j$(nproc) && make install

RUN git clone https://github.com/uphoffc/ImpalaJIT.git \
    && cd ImpalaJIT \
    && mkdir build && cd build \
    && cmake .. && make -j $(nproc) install

RUN git clone https://github.com/SeisSol/easi \
    && cd easi \
    && mkdir build && cd build \
    && CC=mpicc CXX=mpicxx cmake .. -DEASICUBE=OFF -DLUA=ON -DCMAKE_PREFIX_PATH=/home/tools -DCMAKE_INSTALL_PREFIX=/home/tools -DASAGI=ON -DIMPALAJIT=ON .. \
    && make -j$(nproc) && make install

RUN git clone -b damaged-material https://github.com/SeisSol/SeisSol.git \
    && cd SeisSol \
    && git submodule update --init \
    && mkdir build && cd build \
    && export PATH=$PATH:/home/tools/bin \
    && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_PREFIX_PATH=/home/tools -DGEMM_TOOLS_LIST=LIBXSMM -DASAGI=on -DNETCDF=on -DORDER=4 -DEQUATIONS="damaged-elastic" \
    && make -j$(nproc)
#     && cmake .. -DEQUATIONS=viscoelastic2 -DNUMBER_OF_MECHANISMS=3 \
#     && make -j$(nproc) \
#     && cp SeisSol_* /home/tools/bin
#     CC=mpicc CXX=mpicxx cmake .. -DCMAKE_PREFIX_PATH=/home/tools -DCMAKE_BUILD_TYPE=Debug -DGEMM_TOOLS_LIST=LIBXSMM -DASAGI=on -DNETCDF=on -DORDER=4 -DEQUATIONS="damaged-elastic"

RUN mkdir -p /home/ParameterFiles

WORKDIR /home
RUN git clone -b damaged-material-nonlinear-drB https://github.com/SeisSol/SeisSol.git \
    && cd SeisSol \
    && git submodule update --init \
    && mkdir build && cd build \
    && export PATH=$PATH:/home/tools/bin \
    && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_PREFIX_PATH=/home/tools -DGEMM_TOOLS_LIST=LIBXSMM -DASAGI=on -DNETCDF=on -DORDER=3 -DEQUATIONS="damaged-elastic" \
    && make -j$(nproc)

COPY ./ParameterFiles /home/ParameterFiles

RUN pip install matplotlib

RUN cd / && git clone https://github.com/UM-Bridge/umbridge.git

WORKDIR /home/ParameterFiles
RUN python3 generate_fengMat.py

RUN mkdir -p /home/ParameterFiles/output
# RUN bash runSeis.sh

# RUN python3 postprocessing.py

ENV SHARED_DIR=/home/ParameterFiles

WORKDIR /
COPY ./server.cpp server/
RUN cd /server && \
    g++ -o server server.cpp -I /umbridge/lib -lpthread

ENV PORT=4294
ENV RANKS=1
CMD /server/server
