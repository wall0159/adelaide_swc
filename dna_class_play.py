import dna_string
x = dna_string.DNAString('AAGGttcc')
y = dna_string.DNAString('AAGGttccnnn')



samples = {'tiller': x, 'seed': y}

samples['tiller'].print_all()
samples['seed'].print_all()
