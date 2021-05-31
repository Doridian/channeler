from program import IOHandler, Program
from sys import argv, stdout
from readchar import readchar

fh = open(argv[1], 'rb')
code = fh.read().decode('utf8')
fh.close()

class StdIOHandler(IOHandler):
    def output(self, s: str):
        stdout.write(s)
        stdout.flush()

    def input(self) -> str:
        ch = readchar().decode('utf8')
        if ord(ch) == 3: # End-of-input
            return '\0'
        self.output(ch)
        return ch

program = Program(code, StdIOHandler())
program.run()
