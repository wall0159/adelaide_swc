
reader = open('pg76.txt', 'r')
line = reader.readline()
tot_len=0
line_count=0
while line != '':
    tot_len += len(line)
    line_count += 1
    line = reader.readline()

print 'sum of length of lines = ', tot_len
print 'number of lines = ', line_count

print 'total length: %d, line count: %d' % (tot_len, line_count)
