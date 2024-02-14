#!/bin/bash

# Set some environment variables 
CWD=`pwd`
echo "Current directory set to $CWD"
#cp -r $HOME/GROMACS-scripts/{MDP,charmm36.ff} .
#cp $HOME/GROMACS-scripts/{job.sh,run_md.sh,anal-run.sh} .
MDP=$CWD/MDP
echo ".mdp files are stored in $MDP"
PDB_NAME=mol
echo "pdb name is $pdb_name"

# create eceptor gro
#gmx pdb2gmx -f $PDB_NAME.pdb -o pdb.gro -ignh << EOF
#1
#1
#EOF
echo 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 1 0 1 0 2 0 0 1 1 | gmx pdb2gmx -f $PDB_NAME.pdb -asp -glu -his -o pdb.gro -ignh -ff charmm36 -water tip3
#gmx pdb2gmx -f $PDB_NAME.pdb -o pdb.gro -ignh -ff charmm36 -water tip3 &> prepare.out


#solvate
#gmx make_ndx -f $PDB_NAME.pdb -o index.ndx << EOF
#12
#q
#EOF
gmx editconf -f pdb.gro -o newbox.gro -bt cubic -d 1.5 &> box.out
gmx solvate -cp newbox.gro -cs spc216.gro -p topol.top -o solv.gro &> solvated.out

# get tpr file
gmx grompp -f $MDP/ions.mdp -c solv.gro -p topol.top -o ions.tpr >& grompo.out

#add ions
gmx genion -s ions.tpr -o solv_ions.gro -p topol.top -pname SOD -nname CL -neutral << EOF
SOL
EOF

gmx make_ndx -f solv_ions.gro -o index.ndx << EOF
q
EOF
