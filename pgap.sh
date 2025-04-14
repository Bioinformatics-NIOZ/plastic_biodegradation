#!/bin/sh
#SBATCH --partition=LMEMX #Valid values: HMEM1 or LMEM1
#SBATCH --nodes=1 #number of nodes
#SBATCH --job-name=PGAP
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out
#SBATCH --mail-user=alejandro.abdala@nioz.nl  # your email
#SBATCH --mail-type=FAIL,BEGIN,END

module load singularity/3.9.5
module load pgap/677.1

for file in to_pgap/*.fna;
 do
  mag=$(echo $file | awk -F'/' '{print $NF}' | cut -f1-4 -d"_");
   sp=$(echo $file | awk -F'/' '{print $NF}' | cut -f5 -d"_" | sed 's/\.fna//');
   pgap.py --no-self-update -r -o output_all/$mag  -g $file -s "${sp}" -D singularity > output_all/${mag}.log
done
