import numpy as np
import pandas as pd

from biopandas.pdb import PandasPdb

from sys import argv

resid_mutate = argv[1]
original_protpdb = argv[2] #'protein.pdb'
mutated_protpdb = argv[3] #'MUTATED.pdb'
output_pdb = argv[4] #'rebuilt_mutated.pdb'

original_read = PandasPdb().read_pdb(original_protpdb)
core_df = original_read.df['ATOM']

mutprot_db = PandasPdb().read_pdb(mutated_protpdb)
mutant_df = mutprot_db.df['ATOM']


# Subset of PDB dataframe before the residue to be mutated
pre_mutation = core_df.query(f"residue_number < {resid_mutate}")

# Get the last atom number and line index of the pre_mutation subset
last_atom_number = pre_mutation['atom_number'].values[-1]
last_line_index = pre_mutation['line_idx'].values[-1]

mutation = mutant_df.query(f"residue_number == {resid_mutate}")
mutation['atom_number'] = np.arange(last_atom_number+1, last_atom_number+1+len(mutation))
mutation['line_idx'] = np.arange(last_line_index+1, last_line_index+1+len(mutation))


last_atom_number = mutation['atom_number'].values[-1]
last_line_index = mutation['line_idx'].values[-1]

post_mutation = core_df.query(f"residue_number > {resid_mutate}")
post_mutation['atom_number'] = np.arange(last_atom_number+1, last_atom_number+1+len(post_mutation))
post_mutation['line_idx'] = np.arange(last_line_index+1, last_line_index+1+len(post_mutation))


rebuilt_df = pd.concat([pre_mutation, mutation, post_mutation])
original_read.df['ATOM'] = rebuilt_df

# Bug fix: incorrect insertion of TER and ENDMDL lines in the 'OTHERS' dataframe
new_num_atoms = len(rebuilt_df)
others = original_read.df['OTHERS']
num_others_lines = len(others)

# Set value where record_name is 'TER'
others.loc[others.query("record_name == 'TER'").index, 'line_idx'] = new_num_atoms + num_others_lines - 1
others.loc[others.query("record_name == 'ENDMDL'").index, 'line_idx'] = new_num_atoms + num_others_lines
original_read.df['OTHERS'] = others

# A bit sketchy because I did not correct the line indices for TER and ENDMDL in OTHERS df
# It appears that biopandas does handle this properly though
original_read.to_pdb(output_pdb, records=['ATOM', 'OTHERS'])