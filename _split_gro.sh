### Split the system into protein and non-protein components ###

system_gro=$1
tpr=$2
prot_pdb=$3
nonprotein_gro=$4

if [ -z "$prot_pdb" ]; then
    prot_pdb=protein.pdb
fi

if [ -z "$nonprotein_gro" ]; then
    nonprotein_gro=nonprotein.gro
fi

# Separate protein and the rest of the system
# Protein into protein.pdb
# Rest of the system into nonprotein.gro
echo Protein | gmx trjconv -f $system_gro -s $tpr -o $prot_pdb
echo non-Protein | gmx trjconv -f $system_gro -s $tpr -o $nonprotein_gro