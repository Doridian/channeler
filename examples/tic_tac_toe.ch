# How to play: Press number representing your grid position. Layout is as follows:
# 012
# 345
# 678

# Game state is: ....012345678
Cm1000000000

ccP T ccQ T
ccL T
HL ccM T ccP T ccW T ccQ T ccL T R                        # Game loop
R

### SINGLE MOVE HANDLERS ###
H3  # Here we know we have a valid move
    # Get move position back into R1
    m1
    C210000000000 cc/ T
    ccx T
    C110 cc$ T

    m2
    cc6 T
    m1
    cc+ T
    M1

    # Memory is still in R1 here, as we just stored it
    # Put active player in R1
    C21000000000 cc/ T

    # Modulo 2, then add 1 (1 -> 2, 2 -> 1)
    cc% C22 T
    cc+ C21 T

    # Multiply back to "full scale"
    cc* C21000000000 T

    # Strip active player from M
    cc7 T

    # Load memory into R2, add new active player ontop and write back
    m2 cc+ T
    M1
R

H4 ccF T R     # Invalid move
H5 ccF T R     # Invalid move
H6             # Valid move "position" in R1, memory in R2, called by "3", handles multiplying by current player, and returning it in memory
    M1
    ccx T
    C21000000000 cc/ T
    C210 cc% T
    ccx T
    m1
    cc* T
    M1
R

H7             # Strips active player from game state
    m1
    C21000000000 cc% T
    M1
R
### END SINGLE MOVE HANDLERS ###

### PRINT HANDLERS ###
H0 cc. c1  T R                                                         # Print space
H1 cc. c1X T R                                                         # Print X
H2 cc. c1O T R                                                         # Print O

HA cc% C210 T cc+ c20 T ccX T T R                                      # Modulo R1 by 10, add '0', go to that channel
HB ccA T C210 cc/ T ccA T C210 cc/ T ccA T cc. C110 T R                # Prints one line
HC cc. c1PT c1lT c1aT c1yT c1eT c1rT c1:T c1 T R                       # Print "Player: "
HD cc. C113 T C110 T R                                                 # Print "\r\n"
HE cc. c1MT c1oT c1vT c1eT c1:T c1 T R                                 # Print "Move: "
HF cc. c1IT c1nT c1vT c1aT c1lT c1iT c1dT c1!T ccD T R                 # Print "Invalid!\n"
HP                                                                     # Print field
    m1 C21000
          ccB T
    cc/ T ccB T
    cc/ T ccB T
    cc/ T ccD T
R
HQ                                                                     # Print current player
    m1 C21000000000 cc/ T
    ccC T ccA T ccD T
R
### END PRINT HANDLERS ###

### HANDLE SINGLE GAME LOOP ITERATION ###
HM                                                                     # Move handler
    m1                                                                 # Clear any possibly stale move data
    C210000000000 cc% T
    M1

    ccE T                                                              # Ask for move (R1 = idx of field) and add to end of memory
    cc; T
    C210000000000 cc* T
    m2
    cc+ T
    M1
    ccD T

    C210000000000 cc/ T ccx T                                          # Get move data back into R2

    C110 cc$ T                                                         # R1 = 10^R2, so the "position"
    ccx T                                                              # R2 = "position" now
    cc/ m1 T                                                           # Divide memory by R2
    cc% C210 T                                                         # Modulo by 10
    cc+ c23 T ccX T T                                                  # Jump to channel "3"+fielddata (0 if empty, processing a move, otherwise just no-op)
R

### HANDLE WIN CHECK ###
HW
    # Horizontals
    m1
    ccH T
    cc/ C21000 T ccH T
    cc/ C21000 T ccH T

    # Verticals
    m1
    ccV m2 T M2
    cc/ C210 T ccV m2 T M2
    cc/ C210 T ccV m2 T M2

    # Diagonals
    m1
    ccI T
    M1
    ccO T
    M1

    # Check if entire field is filled (draw)
    ccJ T
    M1
R

HH # Handle horizontal line
    cc% C21000 T # Only handle current line
    cc+ C29000 T # Add 9000 for channel ID
    ccX T T
R
HV # Handle vertical line
    M1                      # Put shifted state into memory

    cc% C210 T              # Modulo 10 to strip off other rows
    cc* C2100000000000 T    # Shift way out of game state to avoid clobbering
    cc+ m2 T M1             # Add current state to it

    cc/ C21000 T            # Divide by one row
    cc% C210 T              # Modulo 10 to strip off other rows
    cc* C21000000000000 T   # Shift way out of game state to avoid clobbering
    cc+ m2 T M1             # Add current state to it

    cc/ C21000000 T         # Divide by two rows
    cc% C210 T              # Modulo 10 to strip off other rows
    cc* C210000000000000 T  # Shift way out of game state to avoid clobbering
    cc+ m2 T M1             # Add current state to it

    cc/ C2100000000000 T    # Divide by the shift-out to get plain result
    cc+ C29000 T            # Add 9000 for channel ID
    ccX T T
R
HI # Handle diagonal 1
    cc% C210 T              # Modulo 10 to strip off other rows (top left)
    cc* C2100000000000 T    # Shift way out of game state to avoid clobbering
    cc+ m2 T M1             # Add current state to it

    cc/ C210000 T           # Go to middle cell
    cc% C210 T              # Modulo 10 to strip off other rows
    cc* C21000000000000 T   # Shift way out of game state to avoid clobbering
    cc+ m2 T M1             # Add current state to it

    cc/ C2100000000 T       # Bottom right
    cc% C210 T              # Modulo 10 to strip off other rows
    cc* C210000000000000 T  # Shift way out of game state to avoid clobbering
    cc+ m2 T M1             # Add current state to it

    cc/ C2100000000000 T    # Divide by the shift-out to get plain result
    cc+ C29000 T            # Add 9000 for channel ID
    ccX T T
R
HO # Handle diagonal 2
    cc/ C2100 T             # Top right cell
    cc% C210 T              # Modulo 10 to strip off other rows
    cc* C2100000000000 T    # Shift way out of game state to avoid clobbering
    cc+ m2 T M1             # Add current state to it

    cc/ C210000 T           # Go to middle cell
    cc% C210 T              # Modulo 10 to strip off other rows
    cc* C21000000000000 T   # Shift way out of game state to avoid clobbering
    cc+ m2 T M1             # Add current state to it

    cc/ C21000000 T         # Bottom left
    cc% C210 T              # Modulo 10 to strip off other rows
    cc* C210000000000000 T  # Shift way out of game state to avoid clobbering
    cc+ m2 T M1             # Add current state to it

    cc/ C2100000000000 T    # Divide by the shift-out to get plain result
    cc+ C29000 T            # Add 9000 for channel ID
    ccX T T
R

HJ # Draw check
    m1 cc% C21000000000 T M1    # Strip of all but the field from game state

    ccK T
    cc/ C210 T ccK T
    cc/ C210 T ccK T
    cc/ C210 T ccK T
    cc/ C210 T ccK T
    cc/ C210 T ccK T
    cc/ C210 T ccK T
    cc/ C210 T ccK T
    cc/ C210 T ccK T

    m1 cc/ C210000000000 T     # Read flag into R1 ones-digit
    cc# T                      # Determine sign of flag (0 = no free fields, 1 = free fields)
    cc+ C28000 T               # Add 8000 for channel
    ccX T T
R
HK # Add 1 to the after-game-state field if field blank
    cc% C210 T
    cc# T # Will be 1 if field not blank
    ccx T # This and the next "invert" the flag
    cc- C11 T
    cc* C210000000000 T # Multiply and write to memory cell
    cc+ m2 T
    M1
R

h8000
    cc. c1DT c1rT c1aT c1wT c1!T
    ccD T
    X
R
h8001 R

# Non-winning lines
h9000 R
h9001 R
h9002 R
h9010 R
h9011 R
h9012 R
h9020 R
h9021 R
h9022 R
h9100 R
h9101 R
h9102 R
h9110 R
h9112 R
h9120 R
h9121 R
h9122 R
h9200 R
h9201 R
h9202 R
h9210 R
h9211 R
h9212 R
h9220 R
h9221 R

h9111 # Win for X
    cc. c1XT c1 T c1wT c1iT c1nT c1sT c1!T
    ccD T
    X
R
h9222 # Win for O
    cc. c1OT c1 T c1wT c1iT c1nT c1sT c1!T
    ccD T
    X
R

### END HANDLE WIN CHECK ###
