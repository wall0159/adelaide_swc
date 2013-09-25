import sys

# functions #
def removeN(dna):
    dna=str(dna).upper().replace('N','')
    return dna

def stats(dna):
    dna    = dna.upper()
    N_cnt  = dna.count('N')
    dna    = removeN(dna)
    length = len(dna)
    CG_cnt = (int(dna.count('C')) + int(dna.count('G'))) / float(len(dna))
    return N_cnt, CG_cnt, length

def give_dna_stats(filename):
    reader = open(filename, 'r')
    line = reader.readline()
    while line != '':
        if line.startswith('>'):
            print line.rstrip()
        else:
            N_cnt, CG_cnt, length = stats(line)
            print 'Ns: %d, CG_perc: %0.2f, length: %d' % (N_cnt, CG_cnt*100, length)
        line = reader.readline()

filename = sys.argv[1]
give_dna_stats(filename)
