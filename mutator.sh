# For now, $config is likely going to be a .gro or .gro.xtc init config stored in data/topologies
gro_id=$1
chainid=$2
resid=$3
mutant=$4
# mutant=ALA
workdir=$5
# Recommended procedure: create a dummy tpr file with grompp by hand nd pass it here
tpr=$6

raw_output=mutated
# TODO: chain should be able to be found
chain=PRO$chainid

if [ -z "$workdir" ] ; then
    workdir=~/scratch/research/workspace
fi
cd $workdir

# if [ -z "$tpr" ] ; then
#     tpr=~/research/data/topologies/step6.0_minimization_11.tpr
# fi

# Mutator arguments
mutator=~/research/src/modeling/run_mutator.tcl
prot_psf=~/research/data/topologies/1_protein_model.psf


# This line can fail if the stored format is not gro
# But the shell script will run the next line just fine
# TODO: needs full pbc fix
echo Protein System | gmx trjconv -f ~/research/data/topologies/${gro_id}_init.gro -s $tpr -o system.gro -pbc mol -ur compact -center
echo Protein System | gmx trjconv -f ~/research/data/topologies/${gro_id}_init.gro.xtc -s $tpr -o system.gro -pbc mol -ur compact -center

# Separate protein and the rest of the system
# Protein into protein.pdb
# Rest of the system into nonprotein.gro
prot_pdb=protein.pdb
nonprotein_gro=nonprotein.gro

echo Protein | gmx trjconv -f system.gro -s $tpr -o $prot_pdb
echo non-Protein | gmx trjconv -f system.gro -s $tpr -o $nonprotein_gro



### This is the part where we mutate the protein ###
vmd -dispdev none -e $mutator -args $mutator $prot_psf $prot_pdb $raw_output $chain $resid $mutant

output_pdb=rebuilt_mutated.pdb
# replace protein.pdb with the mutated residue; fix the atom numbering
# Alternatively (Not used), send back to CHARMM-GUI to generate a new topology and maybe patch terminal groups
python ~/research/src/modeling/rebuild_mutant.py $resid $prot_pdb ${raw_output}.pdb $output_pdb

# Solvate the mutant protein with all the rest of the system
gmx solvate -cp $output_pdb -cs $nonprotein_gro -o ${gro_id}_init_${resid}${mutant}.gro -scale 0

# TODO: make up for charge change