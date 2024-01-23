#!/bin/bash

# Job Name and Files (also --job-name)
#SBATCH -J NepM78Dam
#Output and error (also --output, --error):
#SBATCH -o ./%j.%x.out
#SBATCH -e ./%j.%x.err

#Initial working directory:
#SiBATCH --chdir=./

#Notification and type
#SBATCH --mail-type=END
#SBATCH --mail-user=zihua.niu@lmu.de

# Wall clock limit:
#SBATCH --no-requeue

#Setup of execution environment
#SBATCH --export=ALL
#SBATCH --account=pn49ha
#constraints are optional
#--constraint="scratch&work"
#SBATCH --partition=test

#SBATCH --ntasks-per-node=1
#SBATCH --nodes=16
#SBATCH --time=00:30:00
#SBATCH --ear=off

# module load slurm_setup

#Run the program: 
export MP_SINGLE_THREAD=no
unset KMP_AFFINITY

export OMP_NUM_THREADS=92
export OMP_PLACES="cores(46)"
#export I_MPI_SHM_HEAP_VSIZE=24576

export XDMFWRITER_ALIGNMENT=8388608
export XDMFWRITER_BLOCK_SIZE=8388608
export SC_CHECKPOINT_ALIGNMENT=8388608

export SEISSOL_CHECKPOINT_ALIGNMENT=8388608
export SEISSOL_CHECKPOINT_DIRECT=0
export ASYNC_MODE=THREAD
export ASYNC_BUFFER_ALIGNMENT=8388608
export SEISSOL_ASAGI_MPI_MODE=OFF
source /etc/profile.d/modules.sh

echo $SLURM_NTASKS
ulimit -Ss 2097152
#mpiexec -n $SLURM_NTASKS /hppfs/work/pr63qo/di73yeq4/SeisSol/build-release/SeisSol_Release_dskx_4_viscoelastic2 parameters_M6.6_m1.0HzTopo_o4visc.par
#mpiexec -n $SLURM_NTASKS /hppfs/work/pr63qo/di73yeq4/SeisSol/build-release/SeisSol_Release_dskx_4_viscoelastic2 parameters_M7.3_m1.0HzTopo_o4visc.par
# mpiexec -n $SLURM_NTASKS /dss/dsshome1/0F/ra75qeh2/seisNonl/seisDrIS/SeisSol/build_asagi/SeisSol_Release_dskx_4_damaged-elastic parameters_o4CoarseDam34.par
mpiexec -n $SLURM_NTASKS /dss/dsshome1/0F/ra75qeh2/seisNonl/SeisSol/build_asagi/SeisSol_Release_dskx_3_damaged-elastic parameters_0p1Hzo4CoarseDam34.par
#mpiexec -n $SLURM_NTASKS /hppfs/work/pr63qo/di73yeq4/SeisSol/build-release/SeisSol_Release_dskx_4_viscoelastic2 parameters_M7.3_m1.0Hz5kmTopo_o4visc.par
#mpiexec -n $SLURM_NTASKS /hppfs/work/pr63qo/di73yeq4/SeisSol/build-gcc/SeisSol_Debug_dskx_4_viscoelastic2 parameters_M7.3_m1.0HzTopo_o4visc.par
#mpiexec -n $SLURM_NTASKS /hppfs/work/pr63qo/di73yeq4/SeisSol/build-gcc/SeisSol_Release_dskx_4_viscoelastic2 parameters_M7.3_m1.0HzTopo_o4visc.par
