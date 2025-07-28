#### Prepare gro files, pbc fixed from initial gro files ####
gro=$1
tpr=$2

### Step 1 of PBC fix ###
# The first line can fail if the stored format is not gro, but rather gro.xtc
# In that case, the second line will run just fine.

PBC_INTERMEDIATE=system_step1.gro

echo Protein System | gmx trjconv -f $gro -s $tpr -o $PBC_INTERMEDIATE -pbc cluster
echo Protein System | gmx trjconv -f $gro.xtc -s $tpr -o $PBC_INTERMEDIATE -pbc cluster

### Step 2 of PBC fix ###
echo Protein System | gmx trjconv -f $PBC_INTERMEDIATE -s $tpr -o $SYSTEM_GRO -pbc mol -ur compact -center

### Remove the intermediate file ###
rm $PBC_INTERMEDIATE


