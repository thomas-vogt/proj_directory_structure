#!/bin/env bash


# Set up variables for testing

dir_name=( "Study1" "dat1" "" " " "dat:1" "-dat1" "parallel_playground" "dat" "dat\jn")
dir="/home/thomas/directory_structures"
dir_path=( "$dir" "$dir" "$dir" "$dir" "$dir" "$dir" "/home/thomas" "/home/thoma" "$dir")
authorized=( "n" "q" "y" "y" "y" "y" "y" "y" "y")

length_loop=$((${#dir_name[@]} - 1))


# Output

[ ! -e test_output.txt ] && touch test_output.txt
echo -e "$(date)\n\n" >> test_output.txt


# Run tests

for i in $(seq 0 1 "$length_loop"); do
echo "Test n° $((i +1))" >> test_output.txt
{
bash create_project_directory.sh << _EOF_
${dir_name[$i]}
${dir_path[$i]}
${authorized[$i]}
_EOF_
} >> test_output.txt
echo -e "\n\n" >> test_output.txt
done
