from program import IOHandler, Program
from sys import argv
from sys import stdin, stdout

fh = open(argv[1], 'rb')
code = fh.read().decode('utf8')
fh.close()

class StdIOHandler(IOHandler):
    def output(self, s: str):
        stdout.write(s)
        stdout.flush()

    def input(self) -> str:
        return stdin.read(1)

program = Program(code, StdIOHandler())
program.run()
