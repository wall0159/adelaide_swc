import py_functions

class DNAString(object):
    def __init__(self, seq):
        self.seq = seq.upper()
        self.gc_content()
        self.base_count()
        self.reverse_complement()
        
    def gc_content(self):
        '''Help info for the help() function'''
        self.gc_content = py_functions.CG_ratio(self.seq)[0]
    
    def base_count(self, base):
        # return the number of instances of a base in the sequence
        return self.seq.count(base)
    
    def reverse_complement(self):
        self.rev_comp = str(list(self.seq.lower()).reverse())
        self.rev_comp = self.rev_comp.replace('c', 'G')
        self.rev_comp = self.rev_comp.replace('g', 'C')
        self.rev_comp = self.rev_comp.replace('t', 'A')
        self.rev_comp = self.rev_comp.replace('a', 'T')
        
    def print_all(self):
        print 'GS proportion: ' + str(self.gc_content)
        print 'original seq: '  + self.seq
        print 'rev comp seq: '  + self.rev_comp
