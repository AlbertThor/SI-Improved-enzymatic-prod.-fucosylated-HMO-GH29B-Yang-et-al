#!/bin/bash

# Set some environment variables 
CWD=`pwd`
echo "Current directory set to $CWD"
#MDP=$HOME/GROMACS-scripts/MDP
MDP=$CWD/MDP
echo ".mdp files are stored in $MDP"
export GMXLIB=$CWD

N=1 #ntmpi MPI threads
M=4 #ntomp OpenMP

mkdir Out
cd Out

##############################
# ENERGY MINIMIZATION STEEP  #
##############################
echo "Starting minimization" 

mkdir hmin
cd hmin

#minimize force between H that are adjacent
gmx grompp -f $MDP/minim.mdp -c $CWD/solv_ions.gro -p $CWD/topol.top -n $CWD/index.ndx -o hmin.tpr 

gmx mdrun -v -deffnm hmin -ntomp $M -ntmpi $N >& hmin.out

wait

sleep 10

cd ../
mkdir EM
cd EM

# Iterative calls to grompp and mdrun to run the simulations
gmx grompp -f $MDP/em.mdp -c ../hmin/hmin.gro -p $CWD/topol.top -n $CWD/index.ndx -o min.tpr 

gmx mdrun -v -deffnm min -ntmpi $N -ntomp $M >& emmin.out

wait

sleep 10

#gmx make_ndx -f min.gro -o index.ndx << EOF
#q
#EOF

#####################
# NVT EQUILIBRATION #
#####################
echo "Starting constant volume equilibration..."
#
cd ../
mkdir NVT
cd NVT

gmx grompp -f $MDP/nvt.mdp -c ../EM/min.gro -r ../EM/min.gro -p $CWD/topol.top -o nvt.tpr -n $CWD/index.ndx

gmx mdrun -v -deffnm nvt -ntmpi $N -ntomp $M >& nvtrun.out

wait

echo "Constant volume equilibration complete."

sleep 10

#####################
# NPT EQUILIBRATION #
#####################
echo "Starting constant pressure equilibration..."

cd ../
mkdir NPT
cd NPT

gmx grompp -maxwarn 1 -f $MDP/npt.mdp -c ../NVT/nvt.gro -r ../NVT/nvt.gro -p $CWD/topol.top -t ../NVT/nvt.cpt -o npt.tpr -n $CWD/index.ndx

gmx mdrun -v -deffnm npt -ntmpi $N -ntomp $M >& nptrun.out

wait

echo "Constant pressure equilibration complete."

sleep 10

#################
# PRODUCTION MD #
#################
echo "Starting production MD simulation..."

cd ../
mkdir Production_MD
cd Production_MD

gmx grompp -f $MDP/md.mdp -c ../NPT/npt.gro -p $CWD/topol.top -t ../NPT/npt.cpt -o md.tpr -n $CWD/index.ndx

gmx mdrun -v -deffnm md -ntmpi $N -ntomp $M >& mdprop.out 

wait

echo "Production MD complete."

# End
echo "Ending. Job completed"

cd $CWD
exit;

