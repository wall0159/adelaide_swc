import sys

args = sys.argv

if int(args[1]) % 2 == 0:
    print args[1] + ' is even.'
else:
    print args[1] + ' is odd.'

if 0 < int(args[1]) < 50:
    print args[1] + ' is minor.'
elif 50 < int(args[1]) < 100:
    print args[1] + ' is major.'
elif int(args[1]) > 100:
    print args[1] + ' is severe.'
