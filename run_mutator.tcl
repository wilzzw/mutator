set psf [lindex $argv 1]
set pdb [lindex $argv 2]
set output [lindex $argv 3]
set chain [lindex $argv 4]
set resid [lindex $argv 5]
set mut [lindex $argv 6]

set loc_mutator "/usr/local/lib/vmd/plugins/mutator/mutator.tcl"
source $loc_mutator

mutator -psf $psf -pdb $pdb -o $output -ressegname $chain -resid $resid -mut $mut

exit