

def removeN(dna):
    dna=str(dna).upper().replace('N','')
    return dna

def CG_ratio(dna):
    dna=removeN(dna)
    return (dna.count('C') + dna.count('G')) / float(len(dna)), len(dna)

def dna_starts_with(dna, string):
    # make sure DNA and string is clean and a string (remove leading whitespace), and convert to upper-case
    dna=str(''.join(dna)).strip().upper()
    string=str(''.join(string)).strip().upper()
    # do the test 
    return (dna.find(string) == 0)
    
def nucleotideContent(dnaString):
    '''Return the factorial of n, an integer >=0, eg.
    >>> nucleotideContent('ACG')
    {'A': 1, 'C': 1, 'G': 1}
    '''
    dnaDict = {}
    uniques = set(dnaString)
    for nucleotide in uniques:
        dnaDict[nucleotide]=dnaString.count(nucleotide)    
    return dnaDict
    
def factorial(n):
    '''Return the factorial of n, an integer >=0, eg.
    
    Test basic factorial
    >>> factorial(4)
    24
    
    Test non-integer
    >>> factorial(4.1)
    Traceback (most recent call last):
    ...
    ValueError: n must be an integer
    '''
    import math
    # check input
    if not n >= 0:
        raise ValueError('n must be greater than 0')
    if math.floor(n) != n:
        raise ValueError('n must be an integer')
    result = 1
    factor = 2
    # algorithm example: 4! = 1*2*3*4
    while factor <= n:
        result *= factor
        factor += 1
    return result    
    
if __name__ == '__main__':
    import doctest
    doctest.testmod()
