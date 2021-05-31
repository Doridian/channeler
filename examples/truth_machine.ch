cc, T                                # Put "," into RC, transmit to read input into R1
ccX T                                # Put "X" into RC, transmit to swap RC with R1 (so now input is in RC)
T                                    # Transmit, essentially jumping to channel described by user input
R                                    # Return to exit program
H0 c10 cc. T R                       # Handler for 0, put 0 into R1, "." into RC, transmit (prints 0), then return
H1 c11 cc. T cc1 T                   # Handler for 1, put 1 into R1, "."  into RC, transmit (prints 1), then call self
