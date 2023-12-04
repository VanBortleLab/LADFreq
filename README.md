# LaminAsociatedDomains

Lamin Associated Domains Frequency.

Data source: https://data.4dnucleome.org/
Metadata `original_metadata.tsv` used for LAD calls were retrieved with the following steps:
1. Search for LADs (Files)
2. Select File Properties: File Type: LADs
3. Select File Properties: File Format: BED
4. Select Assay Details: LMNB1 | LMNB2 | Lmnb1 (mouse) | Lamin A/C

# Data Processing
The list of BED files described in `original_metadata.tsv` include multiple entries for the same biological experiment (e.g. BED files defining LADs at varied bin resolutions). 

Experiment ID: 4DNES19V4V3C, for example, has two bed files associated with it:
   - 4DNFIJYW6AJ8
   - 4DNFILJ3UQ5X

We consolidate entries by unique experiment ID, taking into account the frequency of LAD calls across bin resolution (see `metadata_processing.R` and `LAD_Experiment.sh`)

Specifically, we annotated the frequency of intra-experimental LAD calls using BEDTools multiintersect: 
```
bedtools multiinter -i *.bed  > combined_LAD_4DNES19V4V3C_.bed
```
For each experiment, we restricted LAD calls to coordinates with the highest LAD frequency (overlap equal to the total number of associated files, see `LAD_Experiment.sh` summary file `LAD_Overlap_Consensus1.bed.gz`

The global distribution of LADs as a function of inter-experimental LAD frequency (110 unique experiments):
![image](https://github.com/VanBortleLab/LaminAsociatedDomains/assets/124115449/677ab9fc-6f8d-430e-bf1c-ed00b68f2bf9)

# Determining Overlap and Enrichment of Specific Genes in Lamin Associated Domains:

Our motivation for defining LAD frequencies is to explore the enrichment of specific gene sets (encoding small noncoding RNAs) within these genomic windows.

To determine overall LAD frequencies, annotations corresponding to ncRNA genes were obtained from RNAcentral (https://rnacentral.org/). 
LAD frequencies were subsequently extracted using BEDTools intersect (see `overlap_by_genes.bed.gz`):
```
# Names for illustration purposes
bedtools intersect -a gene_coordinates_of_interest.bed -b LAD_Overlap_Consensus.bed -wao > overlap_by_genes.bed 
```

First, we considered the LAD frequencies for different groups for the genes. In the example below, we compare the LAD frequencies across distinct groups of Pol III-transcribed genes:

![image](https://github.com/VanBortleLab/LaminAsociatedDomains/assets/124115449/50096e44-ac4e-4d8d-8685-c8796590e045)

Second, we assessed the overall significance of LAD overlap for each subgroup using a permutation test (see `lamin_domains_groups_overlap.R`). In example below, observe significant enrichment of "Tissue-specific" Pol III-transcribed genes in Lamin Associated Domains:

![image](https://github.com/VanBortleLab/LaminAsociatedDomains/assets/124115449/b5473a81-7ef5-4c73-a6ae-d75e85acb25c)






