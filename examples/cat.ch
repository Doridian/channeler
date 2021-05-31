ccC T     # Jump to channel C (loop)

HC        # Put "," into RC, transmit to read char, then put "." into RC, transmit to write it out. Then jump back to the start (">" in RC, -29 in R1, transmit)
    cc, T
    ccY T
    cc. T
    ccC T
R

HY        # Check for 0 in R1
    cc# T # sign operation
    ccX T # swap R1 to RC
    T     # call channel by sign
R

h0 X R
h1 R
