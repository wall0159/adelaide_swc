import sys

args = sys.argv
# convert to string, convert all to lower case
words = ''.join(args[1:]).lower()

# create a set and find its length, print it
letters = set(words)
letters = letters.intersection(set('abcdefghijklmnopqrstuvwxyz'))
print 'number of unique letters: ' + str(len(letters))

# split based on sull-stop delimited sentences (assume just two sentences)
sentences=words.split('.')
set1=set(sentences[0]).intersection(set('abcdefghijklmnopqrstuvwxyz'))
set2=set(sentences[1]).intersection(set('abcdefghijklmnopqrstuvwxyz'))

print 'num letters in common (between full-stop delimited sentences): ' + str(len(set1.intersection(set2)))



