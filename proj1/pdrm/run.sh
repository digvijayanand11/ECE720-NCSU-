#!/bin/bash

# Define arrays for each parameter
CLK_PER_VALUES=(3.0)
UTIL_VALUES=(0.65 0.6 0.55 0.5)       
MAXTRANS_VALUES=(0.3)
CLKUNCERT_VALUES=(0.15 0.2 0.25 0.3)

# Iterate over all combinations of the parameters
for CLK_PER in "${CLK_PER_VALUES[@]}"
do
	for UTIL in "${UTIL_VALUES[@]}"    
	do	    
		for MAXTRANS in "${MAXTRANS_VALUES[@]}"
		do 
			for CLKUNCERT in "${CLKUNCERT_VALUES[@]}"
			do
				echo -e "Running make clean and make with the following configuration:\nCLK_PER=$CLK_PER \nUTIL=$UTIL \nMAXLYR=met5 \nMAXTRANS=$MAXTRANS \nCLKUNCERT=$CLKUNCERT\n\n"
				make clean
				make CLK_PER=$CLK_PER UTIL=$UTIL MAXTRANS=$MAXTRANS CLKUNCERT=$CLKUNCERT
            done
        done
    done
done
