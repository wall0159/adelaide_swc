import py_functions

Tests= [
    ['ACGTGT', {'A':1, 'C':1, 'G':2, 'T':2}, True],
    ['CAGGTT', {'A':1, 'C':1, 'G':2, 'T':2}, True],
    ['cAGGTT', {'A':1, 'C':1, 'G':2, 'T':2}, True]
    ]
    
# Run and report    
passes = 0    
for (i, (seq, expected, boolean)) in enumerate(Tests):    
    if py_functions.nucleotideContent(seq) == expected:    
        passes += 1    
    else:    
        print('test %d failed' % i)    
    
print('%d/%d tests passed' % (passes, len(Tests)))    
