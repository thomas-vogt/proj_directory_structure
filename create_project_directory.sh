#!/bin/env bash


## Get input from user

read -rp "What is the name of the directory you want to create? > " directory_name

echo "
Where do you want to create the directory?
Specify a path. This could be - for example - /home/yourname/Projects_yourname (no / at the end).
Be careful not to specify the root folder, or someone else's home directory.
"
read -rp "Enter here > " directory_path

echo "This directory will be created if it doesn't already exists:"
echo "$directory_path/$directory_name"
read -rp "Proceed? y/n > " authorization


## Perform checks on user input

if [ "$authorization" != "y" ]; then
    echo "Authorization was not given, so the script did not proceed."
    exit 1
fi

if [ -z "$directory_name" ]; then
    echo "The directory name is empty, so the script did not proceed."
    exit 1
fi

if [[ "$directory_name" =~ .*[^-_[:alnum:]].* ]]; then
    echo "$directory_name seems to be an invalid name (contains unauthorized characters), so the script did not proceed."
    exit 1
fi

if [[ "$directory_name" =~ ^-.* ]]; then
    echo "$directory_name starts with a hyphen (-) and this should be avoided, so the script did not proceed"
    exit 1
fi

if [ -d "$directory_path/$directory_name" ]; then
    echo "This directory already exists, so the script did not proceed."
    exit 1
fi

if [ ! -d "$directory_path" ]; then
    echo "The path specified does not exist, so the script did not proceed."
    exit 1
fi


## Create project directory

cd "$directory_path" || { echo "Failure"; exit 1; }
mkdir -pv "$directory_name"
cd "$directory_name" || { echo "Failure"; exit 1; }


## Define variables (organized in blocks by level: block 1: top level, block 2: one level down)

README="README.txt"
MASTER_R="Master_script.R"
MASTER_SH="Master_script.sh"
DATA_DIR="Processed_data"
SRC_DIR="Scripts"
OUTPUT_DIR="Output"
R_MODULES="Load_R_modules.sh"

FIG_DIR="Figures"
RES_DIR="Results"


## Create and populate top level files

touch $R_MODULES $MASTER_R $MASTER_SH $README

echo "This $README file describes the structure of the project.

The file $MASTER_R can source all R scripts in $SRC_DIR.

The file $MASTER_SH does only one thing: it sends $MASTER_R as a batch job.

The file $R_MODULES can be executed to load R modules and RStudio (but could be changed to load some other modules).

Files in $SRC_DIR are an example of a possible structure following a pipeline model with sequentially numbered scripts.
If several scripts are preferred for data loading, diagnosing, and cleaning, they could be broken down into - for example:
01_load.R 02_explore.R 03_diagnose.R 04_fix.R 05_clean.R.
The general idea is that broad tasks (like data cleaning) are identified by the first number in the script name.
More specialized tasks are identified by the second number in the script name if needed.
And the number also indicate the sequence in which the scripts are supposed to be executed.
If several scripts have the same prefix (e.g., 01_), they can be run in any order or in parallel, because they do not
depend on each other.

Depending on the time it takes to run a script, you might want to have one bash script per R script (to run batch jobs)." > $README

echo "#!/bin/env bash

#SBATCH -A project_identifier
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 240:00:00

module load R_packages/4.1.1

R --no-save --quiet --no-restore < $MASTER_R" > $MASTER_SH

echo "#!/bin/env bash

module load R_packages/4.1.1
module load RStudio/2022.02.0-443
rstudio &" > $R_MODULES


## Create directories, subdirectories, and lower level files

mkdir $DATA_DIR $SRC_DIR $OUTPUT_DIR

cd $OUTPUT_DIR || { echo "Failure"; exit 1; }
mkdir $FIG_DIR $RES_DIR
cd ..

cd $SRC_DIR || { echo "Failure"; exit 1; }
touch functions.R 00_clean.R 10_descr-stats.R 20_analysis.R 30_output-results.R
cd ..
