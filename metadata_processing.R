#### LADS DF
### Downloaded metadata from data.4dnucleome.org
metadata =read.delim("metadata_2023-10-04-17h-48m.tsv", comment.char="#") 

### We are removing Histone markers present in the experiments
histone = c('H3K27me3', 'H3K9me3', 'N/A')

metadata = metadata |> filter(!Assay.Details %in% histone)

### Selecting only the unique identifiers for each data set
metadata$Experiment.Accession = ifelse(metadata$Experiment.Accession == 'N/A', metadata$Experiment.Set.Accession, metadata$Experiment.Accession)

## Selecting Columns of interest
metadata = metadata[,c(1,3,4,14,15,17,19,20)]


metadata$Assay.Details = gsub('Lmnb1 mouse protein', 'LMNB1 protein', metadata$Assay.Details)


metadata = metadata |> group_by(Experiment.Accession) |> select(Experiment.Accession, File.Accession, Assay.Details) |>
  summarize(File.Accession = list(File.Accession), Assay.Details = Assay.Details, .groups = 'drop') |> distinct()

### This creates a list of files for all the unique experiments.
for(i in 1:nrow(metadata)) {
  experiment = metadata$Experiment.Accession[i]
  files = metadata$File.Accession[[i]]
  files = paste(files, '.bed', sep = '')
  
  write_lines(files, paste0(experiment, '_filex.txt'))
}