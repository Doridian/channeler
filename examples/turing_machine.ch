# Define state handlers as channel handlers by number negative ST, -10 would be "state 1, tape is 0", -21 would be "state 2, tape is 1"
# Operations are:
#   ccET for "set tape 0", ccWT for "set tape 1"
#   ccLT for "move left", ccRT for "move right" and ccHT for "halt"
#   Switch to state using C1S ccST (S being number of state after C1)

# DEFINE INITIAL TAPE BELOW (retain space at line end)
Cm0 

M1 C2100000000 cc* T m1

# DEFINE INITIAL STATE BELOW (make sure to keep the trailing space!)
C10 

cc+ m2 T M1
cc+ m1 C250000000 T M1

ccA T

# DEFINE YOUR HANDLERS HERE
# This example is a 3-state busy beaver
h-00 ccWT ccRT C11 ccST R
h-01 ccWT ccLT C12 ccST R
h-10 ccWT ccLT C10 ccST R
h-11 ccWT ccRT C11 ccST R
h-20 ccWT ccLT C11 ccST R
h-21 ccWT ccHT R
# END DEFINE HANDLERS


# Memory layout is T...TTTTTPPPPSSSS
HA
    m2 ccCT m1 M2
    # cc:T ccNT

    ccxT C10  cc- T
    ccXT T

    ccA T
R
HN cc. C113 T C110 T R
HB # Write tape at current position to M
    # Extract current tape pos to R1
    m1
    C2100000000 cc% T
    C210000 cc/ T

    cc+ C28 T  ccxT cc$  C110 T # 10^(position+8)
    
    ccxT
    cc/ m1 T # Divide memory by number to get it into ones digit
    cc% C210 T # Modulo 10 to extact digit
    M1
R
HC # Write 10*current state + HB to M
    m1
    cc% C210000 T
    cc* C210 T
    ccBT
    m2
    cc+ T
    M1
R

HS # Set state to R1
    ccT T # Clear out old state
    m2 cc+ T # Add new state
    M1
R
HT # Remove last 4 digits to clear out state
    m1
    C210000 cc/ T cc* T
    M1
R

HR # Move tape right (+1)
    m1 C210000 cc+ T M1
R
HL # Move tape left (-1)
    m1 C210000 cc- T M1
R

HW # Write tape (1)
    ccET # Erase tape at current position

    # Extract current tape pos to R1
    m1
    C2100000000 cc% T
    C210000 cc/ T

    cc+ C28 T  ccxT cc$  C110 T # 10^(position+8)
    cc+ m2 T M1 # Add 1 at the position and write to memory
R
HE # Erase tape (0)
    # Extract current tape pos to R1
    m1
    C2100000000 cc% T
    C210000 cc/ T

    cc+ C28 T  ccxT cc$  C110 T # 10^(position+8)
    
    ccxT
    cc/ m1 T # Divide memory by number to get it into ones digit
    cc% C210 T # Modulo 10 to extact digit
    cc+ C2200 T # Add 200 for channel index
    ccXT T # Run channel by index
R
h200 R
h201
    # Extract current tape pos to R1
    m1
    C2100000000 cc% T
    C210000 cc/ T

    cc+ C28 T  ccxT cc$  C110 T # 10^(position+8)
    
    ccxT cc- m1 T M1 # Remove 1 at the position ancl write to memory
R

HH
    m1
    C2100000000 cc/ T
    cc: T
    X
R
