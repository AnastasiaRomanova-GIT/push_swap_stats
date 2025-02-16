#!/bin/bash

##################################################################
## number of random numbers to generate
NUM_COUNT=100

#lower and upper bounds
LOW=0
HIGH=1000

# Initialize an empty array
ARG=()

# Function to check if a number is already in the array
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

# Generate unique random numbers until we have NUM_COUNT of them
while [ ${#ARG[@]} -lt $NUM_COUNT ]; do
   num=$(( RANDOM % (HIGH - LOW + 1) + LOW ))
   if ! contains "$num" "${ARG[@]}"; then
       ARG+=("$num")
   fi
done
# Print the generated numbers
echo "Generated random numbers between $LOW and $HIGH:\n ${ARG[@]}"
echo -e ""
#########################################################################
#100  ARG="29 78 46 24 59 14 2 63 17 73 15 90 58 95 82 91 86 61 13 43 88 83 89 36 49 48 31 19 11 98 74 35 16 33 27 22 76 25 38 81 0 32 10 62 96 65 7 45 21 85 18 26 39 84 47 93 9 77 92 1 79 34 44 37 55 51 28 4 6 64 20 94 99 71 69 97 72 56 3 54 12 75 68 42 70 5 53 23 41 67 50 87 60 8 30 66 100 52 40 80" #numbers go here
# checker freezes  ARG="7 5 52 30 74 75 71 39 80 8"
# ARG="36 2 -67 95 -98 63 -14 -47 -60 -87"
# ARG = "535 458 794 582 819 518 872 579 905 52 407 274 174 43 262"
#ARG = "25 30 113 116 157 244 250 353 389 453 489 497 547 550 646 855 731 881 958 972"
# Print the predefined sets
echo "The predefined set of numbers is:\n ${ARG[@]}"
echo -e ""


make clean
echo -e ""
make w_exec_only
echo -e ""
make exec_only
echo -e ""

./swap_push_deb.out "${ARG[@]}" 
echo -e ""
echo -e "Checker:"
./swap_push.out "${ARG[@]}"| ./checker_linux "${ARG[@]}"
echo -e "Number of operations:"
./swap_push.out "${ARG[@]}"| wc -l
