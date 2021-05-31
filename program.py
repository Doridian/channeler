from dataclasses import dataclass
from typing import Callable
from sys import stdin, stdout, stderr

@dataclass
class StackFrame:
    pos: int
    r1: int
    r2: int
    rc: int

SPECIAL_CHANNELS: dict[str, Callable[[StackFrame], None]] = {}

def op_add(state: StackFrame):
    state.r1 = state.r1 + state.r2
SPECIAL_CHANNELS['+'] = op_add
def op_sub(state: StackFrame):
    state.r1 = state.r1 - state.r2
SPECIAL_CHANNELS['-'] = op_sub
def op_mul(state: StackFrame):
    state.r1 = state.r1 * state.r2
SPECIAL_CHANNELS['*'] = op_mul
def op_div(state: StackFrame):
    state.r1 = state.r1 // state.r2
SPECIAL_CHANNELS['/'] = op_div
def op_mod(state: StackFrame):
    state.r1 = state.r1 % state.r2
SPECIAL_CHANNELS['%'] = op_mod

def op_sign(state: StackFrame):
    if state.r1 > 0:
        state.r1 = 1
    elif state.r1 < 0:
        state.r1 = -1
    else:
        state.r1 = 0
SPECIAL_CHANNELS['#'] = op_sign

def op_outc(state: StackFrame):
    stdout.write(chr(state.r1))
    stdout.flush()
SPECIAL_CHANNELS['.'] = op_outc
def op_outn(state: StackFrame):
    stdout.write(str(state.r1))
    stdout.flush()
SPECIAL_CHANNELS[':'] = op_outn
def op_inc(state: StackFrame):
    state.r1 = ord(stdin.read(1))
SPECIAL_CHANNELS[','] = op_inc
def op_inn(state: StackFrame):
    state.r1 = int(stdin.read(1))
SPECIAL_CHANNELS[';'] = op_inn

def op_jump(state: StackFrame):
    state.pos += state.r1
SPECIAL_CHANNELS['>'] = op_jump

def op_swap12(state: StackFrame):
    r1 = state.r1
    state.r1 = state.r2
    state.r2 = r1
SPECIAL_CHANNELS['x'] = op_swap12
def op_swap1c(state: StackFrame):
    r1 = state.r1
    state.r1 = state.rc
    state.rc = r1
SPECIAL_CHANNELS['X'] = op_swap1c

def op_inc(state: StackFrame):
    state.r1 += 1
SPECIAL_CHANNELS['^'] = op_inc
def op_dec(state: StackFrame):
    state.r1 -= 1
SPECIAL_CHANNELS['v'] = op_dec

class Program:
    channels: dict[str, int]

    state: StackFrame

    code: str
    call_stack: list[StackFrame]

    def __init__(self, code):
        self.channels = {}

        self.state = StackFrame(0, 0, 0, 0)

        self.code = code

        can_see_h = False
        for i, c in enumerate(code):
            if can_see_h and c == 'H':
                self.channels[code[i + 1]] = i + 2
            can_see_h = (c == '\r' or c == '\n')

        self.call_stack = [StackFrame(len(code) + 1, 0, 0, 0)]

    def call(self, state):
        self.call_stack.append(self.state)
        self.state = state

    def retn(self):
        self.state = self.call_stack.pop()

    def send(self):
        channel = chr(self.state.rc)
        if channel in SPECIAL_CHANNELS:
            SPECIAL_CHANNELS[channel](self.state)
            return

        if channel not in self.channels:
            raise ValueError('Channel "%d" does not exist' % channel)
        self.call(StackFrame(self.channels[channel], self.state.r1, self.state.r2, channel))

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
            elif reg == 'c':
                self.state.rc = val
            else:
                raise ValueError('Invalid register code "%s"!' % reg)
        elif cmd == 'R': # Return
            self.retn()
        elif cmd == '#':
            self.readcode_until('\n')
