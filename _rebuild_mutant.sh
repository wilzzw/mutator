#### This script rebuilds a mutated protein structure after mutation has been applied ####
resid=$1
output_name=$2

REBUILT_MUTATED_PDB=rebuilt_mutated.pdb

# replace protein.pdb with the mutated residue and fix the atom numbering, as well as the terminal groups that mutator does not recognize
# Alternatively (Not used), send back to CHARMM-GUI to generate a new topology and maybe patch terminal groups
python $REBUILDER $resid $PROT_PDB ${RAW_OUTPUT_NAME}.pdb $REBUILT_MUTATED_PDB

# Solvate the mutant protein with all the rest of the system
gmx solvate -cp $REBUILT_MUTATED_PDB -cs $NONPROTEIN_GRO -o $output_name -scale 0

# Remove the intermediate file
rm $REBUILT_MUTATED_PDB

echo "Make sure to correct for charge changes if any, as a result of the mutation."
echo "How this is done depends on the specific system."