from dataclasses import dataclass
from typing import Callable

@dataclass
class StackFrame:
    pos: int
    r1: int
    r2: int
    rc: int

SPECIAL_CHANNELS: dict[str, Callable[['Program'], None]] = {}

def op_add(program: 'Program'):
    program.state.r1 = program.state.r1 + program.state.r2
SPECIAL_CHANNELS['+'] = op_add
def op_sub(program: 'Program'):
    program.state.r1 = program.state.r1 - program.state.r2
SPECIAL_CHANNELS['-'] = op_sub
def op_mul(program: 'Program'):
    program.state.r1 = program.state.r1 * program.state.r2
SPECIAL_CHANNELS['*'] = op_mul
def op_div(program: 'Program'):
    program.state.r1 = program.state.r1 // program.state.r2
SPECIAL_CHANNELS['/'] = op_div
def op_mod(program: 'Program'):
    program.state.r1 = program.state.r1 % program.state.r2
SPECIAL_CHANNELS['%'] = op_mod
def op_pow(program: 'Program'):
    program.state.r1 = pow(program.state.r1, program.state.r2)
SPECIAL_CHANNELS['$'] = op_pow

def op_sign(program: 'Program'):
    if program.state.r1 > 0:
        program.state.r1 = 1
    elif program.state.r1 < 0:
        program.state.r1 = -1
    else:
        program.state.r1 = 0
SPECIAL_CHANNELS['#'] = op_sign

def op_outc(program: 'Program'):
    program.io.output(chr(program.state.r1))
SPECIAL_CHANNELS['.'] = op_outc
def op_outn(program: 'Program'):
    program.io.output(str(program.state.r1))
SPECIAL_CHANNELS[':'] = op_outn
def op_inc(program: 'Program'):
    program.state.r1 = ord(program.io.input())
SPECIAL_CHANNELS[','] = op_inc
def op_inn(program: 'Program'):
    program.state.r1 = int(program.io.input())
SPECIAL_CHANNELS[';'] = op_inn

def op_jump(program: 'Program'):
    program.state.pos += program.state.r1
SPECIAL_CHANNELS['>'] = op_jump

def op_swap12(program: 'Program'):
    r1 = program.state.r1
    program.state.r1 = program.state.r2
    program.state.r2 = r1
SPECIAL_CHANNELS['x'] = op_swap12
def op_swap1c(program: 'Program'):
    r1 = program.state.r1
    program.state.r1 = program.state.rc
    program.state.rc = r1
SPECIAL_CHANNELS['X'] = op_swap1c

def op_inc(program: 'Program'):
    program.state.r1 += 1
SPECIAL_CHANNELS['^'] = op_inc
def op_dec(program: 'Program'):
    program.state.r1 -= 1
SPECIAL_CHANNELS['v'] = op_dec

def find_special_channel(channel: int):
    channel_char = chr(channel)
    if channel_char in SPECIAL_CHANNELS:
        return SPECIAL_CHANNELS[channel_char]
    return None

class IOHandler:
    def output(self, s: str):
        """Output string specified by s."""
        pass

    def input(self) -> str:
        """Input a single character and return it."""
        pass

class Program:
    channels: dict[str, int]

    state: StackFrame
    memory: int

    io: IOHandler
    code: str
    call_stack: list[StackFrame]

    def __init__(self, code, io):
        self.channels = {}

        self.state = StackFrame(0, 0, 0, 0)
        self.memory = 0

        self.code = code
        self.io = io

        can_see_h = False
        for i, c in enumerate(code):
            if can_see_h:
                if c == 'H':
                    self.channels[ord(code[i + 1])] = i + 2
                elif c == 'h':
                    v = ''
                    j = i
                    while True:
                        j += 1
                        x = code[j]
                        if x == ' ':
                            break
                        v += x
                    self.channels[int(v)] = i + len(v) + 2
            can_see_h = (c == '\r' or c == '\n')

        self.call_stack = [StackFrame(len(code) + 1, 0, 0, 0)]

    def call(self, state):
        self.call_stack.append(self.state)
        self.state = state

    def retn(self):
        self.state = self.call_stack.pop()

    def send(self):
        channel = self.state.rc
        special_channel = find_special_channel(channel)
        if special_channel is not None:
            special_channel(self)
            return

        if channel not in self.channels:
            raise ValueError('Channel "%s" does not exist' % channel)
        self.call(StackFrame(self.channels[channel], self.state.r1, self.state.r2, self.state.rc))

    def run(self):
        self.state = StackFrame(0, 0, 0, 0)
        while self.state.pos < len(self.code):
            self.step()

    def readcode_char(self):
        res = self.code[self.state.pos]
        self.state.pos += 1
        return res

    def readcode_until(self, delim):
        val = ''
        while True:
            nexthcar = self.readcode_char()
            if nexthcar == delim:
                break
            val += nexthcar
        return val

    def readcode_int(self):
        return int(self.readcode_until(' '))

    def step(self):
        cmd = self.readcode_char()
        #stderr.write('Processing at %d\r\n' % (self.state.pos - 1))
        #stderr.flush()
        if cmd == 'T': # Send to channel
            self.send()
        elif cmd == 'C' or cmd == 'c': # Load immediate constant numeric (C) or ASCII (c)
            reg = self.readcode_char()
            val = self.readcode_int() if cmd == 'C' else ord(self.readcode_char())
            if reg == '1':
                self.state.r1 = val
            elif reg == '2':
                self.state.r2 = val
            elif reg == 'c' or reg == 'C':
                self.state.rc = val
            elif reg == 'm' or reg == 'M':
                self.memory = val
            else:
                raise ValueError('Invalid register code "%s"!' % reg)
        elif cmd == 'M': # Memory write
            reg = self.readcode_char()
            if reg == '1':
                self.memory = self.state.r1
            elif reg == '2':
                self.memory = self.state.r2
            elif reg == 'c' or reg == 'C':
                self.memory = self.state.rc
        elif cmd == 'm': # Memory read
            reg = self.readcode_char()
            if reg == '1':
                self.state.r1 = self.memory
            elif reg == '2':
                self.state.r2 = self.memory
            elif reg == 'c' or reg == 'C':
                self.state.rc = self.memory
        elif cmd == 'R': # Return
            self.retn()
        elif cmd == '#': # Comment
            self.readcode_until('\n')
        elif cmd == 'D':
            print('R1 = %d, R2 = %d, RC = %s, M = %d' % (self.state.r1, self.state.r2, self.state.rc, self.memory))
