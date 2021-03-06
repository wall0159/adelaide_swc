import sys

args = sys.argv

# convert to string, convert all to lower case
base_pairs = ''.join(args[1:]).upper()

filter = 'ACTG'

counts={'A': base_pairs.count('A'),
'C': base_pairs.count('C'),
'G': base_pairs.count('G'),
'T': base_pairs.count('T')}

print counts

# CG content

print 'CG content = ' + str((base_pairs.count('C') + base_pairs.count('G'))/float(len(base_pairs)))

# counts = {'A': len(base_pairs.split('A'))-1,
# 'C': len(base_pairs.split('C'))-1,
# 'G': len(base_pairs.split('G'))-1,
# 'T': len(base_pairs.split('T'))-1}
