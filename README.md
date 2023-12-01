# LaminAsociatedDomains
Lamin Associated Domains Frequency.

Data source: https://data.4dnucleome.org/

1. Look for DamID-Seq and pA-DamID
2. Download only bed files. These bed files have the coordinates for the LAD domains.
3. Metadata is available in this code - Look for `original_metadata.tsv`

# Data Processing
Before accounting for LAD frequencies, for each unique experiment present in the original metadata we performed some mild processing for defining unique LAD domains for each experiment accounting for different bin sizes. An R code is available for this preprocessing - Look for `metadata_processing.R` and `LAD_Experiment.sh`

For example.
- Experiment ID: 4DNES19V4V3C has two bed files associated with it:
   - 4DNFIJYW6AJ8
   - 4DNFILJ3UQ5X

We performed the following command on bedTools:
https://bedtools.readthedocs.io/en/latest/content/tools/multiinter.html

```
bedtools multiinter -i *.bed  > combined_LAD_4DNES19V4V3C_.bed
```

Therefore for each experiment, we selected the coordinates that have an overlap equal to the total number of files associated with it. The shell script `LAD_Experiment.sh` has a code containing a loop for performing this on each experiment file. The output of this shell script is a data frame that contains the LAD frequencies for each coordinate. Therefore high frequency coordinates are very likely to be LADs. This summary file is also present in this repository - Look for `LAD_Overlap_Consensus.bed`

**Note: If you are going to use any of these codes make sure to adjust your directories and so on**

The distribution of LADs in the whole genome would look something like this. The maximum number of overlaps is 110 (Total # of experiments)
![image](https://github.com/VanBortleLab/LaminAsociatedDomains/assets/124115449/677ab9fc-6f8d-430e-bf1c-ed00b68f2bf9)

  
