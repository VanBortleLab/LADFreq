# LaminAsociatedDomains
Lamin Associated Domains Frequency.

Data source: https://data.4dnucleome.org/

1. Look for DamID-Seq and pA-DamID
2. Download only bed files. These bed files have the coordinates for the LAD domains.
3. Metadata is available in this code - Look for `original_metadata.tsv`

# Data Processing
Before accounting for LAD frequencies, for each unique experiment present in the original metadata we performed some mild processing for defining unique LAD domains for each unique experiment accounting for different bin sizes. An R code is available for this preprocessing - Look for `metadata_processing.R` and `LAD_Experiment.sh`

For example.
- Experiment ID: 4DNES19V4V3C has two bed files associated with it:
   - 4DNFIJYW6AJ8
   - 4DNFILJ3UQ5X

We performed the following command on bedTools:
https://bedtools.readthedocs.io/en/latest/content/tools/multiinter.html

```
bedtools multiinter -i *.bed  > combined_LAD_4DNES19V4V3C_.bed
```
  
