#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p normal
#SBATCH -n 1
#SBATCH --mem=30g
#SBATCH -N 1
# ----------------Load Modules--------------------
module load BEDTools/2.28.0-IGB-gcc-8.2.0
#----------------------------------------

bed_dir='/home/labs/kvbortle_lab/lab-tools/LADs/lad_bed'
out_dir='/home/labs/kvbortle_lab/lab-tools/LADs/lad_bed/unique_experiment'

for file in $out_dir/*_filex.txt; do
    experiment=$(basename "$file" _filex.txt)

    # prepare bedtools arguments
    bedtools_args=""
    count=0
    while IFS= read -r line; do
        bedtools_args+="$bed_dir/$line "
        ((count++))
    done < "$file"

    # Run bedtools and save output
    bedtools multiinter -i $bedtools_args > "$out_dir/${experiment}.bed"

    # Filter the output based on the third column
    awk -v count="$count" -v OFS='\t' '$4 >= count {print $1, $2, $3, $4}' "$out_dir/${experiment}.bed" > "$out_dir/${experiment}_filtered.bed"

   # Removing File
   rm "$out_dir/${experiment}.bed"
done

 
 bedtools multiinter -i $out_dir/*_filtered.bed > "$out_dir/LAD_Overlap_Consensus.bed"

 rm $out_dir/*_filtered.bed

awk -v OFS='\t' '{print $1, $2, $3, $4}' "$out_dir/LAD_Overlap_Consensus.bed" > "$out_dir/LAD_Overlap_Consensus1.bed"
