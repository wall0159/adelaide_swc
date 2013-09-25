import sys

args = sys.argv
args = args[1:] # get rid of the program name from the arguments

args.sort()
## capitalise the first letter of the first in the list
args[0]=args[0].title() # this is a better way to capitalise the first letter
# first_arg=list(args[0])
# first_arg[0]=first_arg[0].upper()
# first_arg=''.join(first_arg)
# replace the first in list with capitalised version
#args[0]=first_arg

# join and print
joined = ', '.join(args[:-1]) + ', and ' + args[-1] + '.'
print joined
