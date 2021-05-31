from program import Program
from sys import argv

fh = open(argv[1], 'rb')
prog = Program(fh.read().decode('utf8'))
fh.close()
prog.run()
