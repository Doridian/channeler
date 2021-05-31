# Game state is: MP012345678
# Grid is:
# 012
# 345
# 678

Cm1000000000 

ccL T

HL ccP T ccM T ccL T R                                                 # Game loop
R

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

    # TODO: Swap active player
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

### PRINT HANDLERS ###

H0 cc. c1  T R                                                         # Print space
H1 cc. c1X T R                                                         # Print X
H2 cc. c1O T R                                                         # Print O
HA cc% C210 T cc+ c20 T ccX T T R                                      # Modulo R1 by 10, add '0', go to that channel
HB ccA T C210 cc/ T ccA T C210 cc/ T ccA T cc. C110 T R     # Prints one line
HC cc. c1PT c1lT c1aT c1yT c1eT c1rT c1:T c1 T R                       # Print "Player: " 
HD cc. C113 T C110 T R                                                        # Print "\r\n"
HE cc. c1MT c1oT c1vT c1eT c1:T c1 T R                                 # Print "Move: "
HF cc. c1IT c1nT c1vT c1aT c1lT c1iT c1dT c1!T ccD T R                 # Print "Invalid!\n"
HP m1 C21000 ccB T                                                     # Print field and current player
    cc/ T ccB T
    cc/ T ccB T
    cc/ T ccC T ccA T ccD T
R
### END PRINT HANDLERS ###

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
