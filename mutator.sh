
gro=$1
chain=$2
resid=$3
mutant=$4 # $mutant: 3-letter code for the mutant amino acid, e.g., ALA, GLY, etc.
tpr=$5 # Recommended procedure: create a dummy tpr file with grompp by hand and pass it here
prot_psf=$6
output_name=$7
workdir=$8

# Settings
## default paths
DEFAULT_WORKDIR=~/scratch/research/workspace
SOURCE_DIR=~/mutator

SYSTEM_GRO=system.gro
PROT_PDB=protein.pdb
NONPROTEIN_GRO=nonprotein.gro
RAW_OUTPUT_NAME=mutated
MUTATOR=$SOURCE_DIR/run_mutator.tcl
REBUILDER=$SOURCE_DIR/rebuild_mutant.py

# export setting variables
export TOPOLOGY_DIR
export SOURCE_DIR
export SYSTEM_GRO
export PROT_PDB
export NONPROTEIN_GRO
export RAW_OUTPUT_NAME
export MUTATOR
export REBUILDER

# export arguments


# If workdir is not provided, use the default
if [ -z "$workdir" ] ; then
    workdir=$DEFAULT_WORKDIR
fi
cd $workdir

# Prepare the system gro file
# Currently, this just fixes any PBC
bash $SOURCE_DIR/_prepare_gro.sh $gro $tpr

# Split the system into protein and non-protein components #
bash $SOURCE_DIR/_split_gro.sh $SYSTEM_GRO $tpr $PROT_PDB $NONPROTEIN_GRO

# Run the mutator script
vmd -dispdev none -e $MUTATOR -args $MUTATOR $prot_psf $PROT_PDB $RAW_OUTPUT_NAME $chain $resid $mutant

# Rebuild the mutant protein to fix some issues with the mutator output
bash $SOURCE_DIR/_rebuild_mutant.sh $resid $output_name

# Remove intermediate files
rm $PROT_PDB
rm $NONPROTEIN_GRO
rm $RAW_OUTPUT_NAME.pdb

rm $SYSTEM_GRO