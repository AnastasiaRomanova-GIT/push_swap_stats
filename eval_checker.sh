#!/bin/bash

#######################
# 1) Variable initialization
#######################
SUM=0
ITER=100        # Number of times we run the checker
AVG=0
MIN=99999999
MAX=0
ITER_ORIG=$ITER
declare -a results

LOW=0
HIGH=1000

# Set how many unique random numbers to generate:
NUM_COUNT=100

#######################
# 2) Validate NUM_COUNT vs. [LOW..HIGH]
#######################
RANGE_SIZE=$((HIGH - LOW + 1))
if [ "$NUM_COUNT" -gt "$RANGE_SIZE" ]; then
  echo "Error: Cannot generate $NUM_COUNT unique numbers in the range [$LOW..$HIGH]."
  exit 1
fi

#######################
# 3) Check if ITER is valid
#######################
if [ -z "$ITER" ] || [ "$ITER" -le 0 ]; then
    echo "Error: ITER is not set or is non-positive."
    exit 1
fi

#######################
# 4) Loop ITER times to collect stats
#######################
while [ "$ITER" -gt 0 ]; do


	# Generate unique random numbers in ARG
	declare -a ARG=()

	# Function to check if a number is already in an array
	contains() {
	   local num=$1
	   shift
	   for element in "$@"; do
	       if [ "$element" -eq "$num" ]; then
	           return 0  # Found
	       fi
	   done
	   return 1  # Not found
	}

	# Keep generating random numbers until ARG has NUM_COUNT unique values
	while [ "${#ARG[@]}" -lt "$NUM_COUNT" ]; do
	   num=$(( RANDOM % RANGE_SIZE + LOW ))
	   if ! contains "$num" "${ARG[@]}"; then
	       ARG+=("$num")
	   fi
	done


    # Run your programs and pipe to checker
    OUTPUT=$(./swap_push.out "${ARG[@]}" | ./checker_linux "${ARG[@]}")

    # If checker is not OK, bail out
    if [ "$OUTPUT" != "OK" ]; then
        echo "KO according to the checker with the following set: '${ARG[@]}'"
        exit 1
    fi

    # Count the number of operations
    NUM_OPS=$(./swap_push.out "${ARG[@]}" | wc -l)

    # Validate NUM_OPS is numeric
    if ! [[ "$NUM_OPS" =~ ^[0-9]+$ ]]; then
        echo "Error: NUM_OPS is not a valid number: $NUM_OPS"
        exit 1
    fi

    # Record stats
    results+=("$NUM_OPS")
    ((SUM += NUM_OPS))
    
    if [ "$NUM_OPS" -lt "$MIN" ]; then
        MIN=$NUM_OPS
    fi
    if [ "$NUM_OPS" -gt "$MAX" ]; then
        MAX=$NUM_OPS
    fi

    echo "Iteration $ITER: $NUM_OPS"
    ((ITER--))
done

#######################
# 7) Final calculations
#######################
if [ "$ITER_ORIG" -eq 0 ]; then
    echo "Error: ITER_ORIG is zero, cannot compute AVG or DISPERSION."
    exit 1
fi

# Average
AVG=$(( SUM / ITER_ORIG ))

# Variance (Dispersion)
SUM_SQUARE_DIFF=0
for num in "${results[@]}"; do
    DIFF=$((num - AVG))
    SQUARE_DIFF=$((DIFF * DIFF))
    ((SUM_SQUARE_DIFF += SQUARE_DIFF))
done
DISPERSION=$(( SUM_SQUARE_DIFF / (ITER_ORIG) ))
STD_DEV=$(echo "scale=0; sqrt($DISPERSION)" | bc)

#######################
# 8) Print the results
#######################
echo "AVG: $AVG"
echo "MIN: $MIN"
echo "MAX: $MAX"
echo "STD DEVIATION: $STD_DEV"
