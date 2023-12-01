library(tidyverse)

lad = read.delim('LAD_Overlap_Consensus.bed', sep = '\t', header = F)
lad = lad[,1:4]
lad$V5 = lad$V4/max(lad$V4)

plot = lad |> ggplot(aes(x = V3)) + theme_classic() +
  geom_line(aes(x=V3, y = V4, col = V1), linewidth = 0.5, show.legend = F) +
  theme(axis.text.x = element_text(size = 3),
        strip.background = element_rect(
          color="black", fill="lightgray", size=1.5, linetype="solid"),
        panel.border = element_rect(color = "black", fill = NA, size = 1)) +
  facet_wrap(~V1, scales = 'free') + 
  ylab('Overlaps') + xlab('Chromosome')

#### Reading the overlap by gene
overlap2 = read.delim('overlap_by_genes.bed', header = F)
## Colnames for the original file
colnames(overlap2) = c('Chr', 'Start', 'End', 'Index', 'Chr-Lad', 'Start_Lad', 'End_Lad', 'Lad_Overlap', 'BP_Coverage')

### Creating a score (Optional, can be used for other purposes)
overlap2$gene_size = overlap2$End - overlap2$Start
overlap2$prop_overlap = overlap2$BP_Coverage/overlap2$gene_size
overlap2 = overlap2 |> filter(Chr != 'chrM')
overlap2$Lad_Overlap = gsub('\\.', 0, overlap2$Lad_Overlap)
overlap2$Lad_Overlap = as.integer(overlap2$Lad_Overlap)
overlap2$prop_ladsign = (overlap2$Lad_Overlap)/(max(overlap2$Lad_Overlap))
overlap2$score = overlap2$prop_overlap * overlap2$prop_ladsign

### Previous classes defined for a specific gene
classes = read.delim('entropy_pol3_tissues_ALL_normalized_by_global_tissue.txt', sep = ',')
classes$V7 = as.character(classes$V7)


for_test = overlap2 |> dplyr::select(4, 5,6,7,8) |> unite('LAD', Index, `Chr-Lad`, Start_Lad, End_Lad, sep = '$$')
permutation2 = for_test |> separate(LAD, into = c('V1', 'V2', 'V3', 'V4'), sep = '\\$\\$')
permutation2 = permutation2 |> left_join(classes[,c(2,6)], join_by('V1' == 'V7'))
permutation2 = permutation2 |> dplyr::mutate(core_type = replace_na(core_type, 'Other'))
permutation2$core_type = factor(permutation2$core_type, levels = c('Other', '75% Tissues', '50% Tissues', '25% Tissues', 'Specific', 'Innactive'))

plot = permutation2  |> filter(core_type != 'Other') |> ggplot() + geom_boxplot(aes(x = core_type, y = Lad_Overlap, fill = core_type), show.legend = F)+ 
  theme_classic() + 
  theme(axis.text.x = element_text(size = 10),
        strip.background = element_rect(
          color="black", fill="lightgray", size=1.5, linetype="solid"),
        panel.border = element_rect(color = "black", fill = NA, size = 1)) +
  xlab('Group') + ylab('LAD Overlaps')
                                                                                                                              
#### Permutation test
perm_test2 = function(data, permutations = 50000 ){
  P = permutations
  data2 = NULL
  a = unique(data$core_type)
  a = a[a != 'Other']
  final_perm = NULL
  for(i in a){
    n = data |> dplyr::select(5,6) |> filter(core_type == i)
    dim = nrow(n)
    colnames(n) = c('name', 'observed')
    data1 = data.frame(name = i, observed = median(n[,1]))
    
    distrib = NULL
    for(k in 1:P){
      n2 = sample(data$Lad_Overlap, size = dim, replace = F)
      n2 = median(n2)
      
      distrib = append(distrib, n2)
    }
    
    pval = sum(distrib > data1[,2])/P
    mean = median(distrib)
    data3 = data.frame(name = i,observed = data1$observed, median = mean,  pval = pval)
    
    list = list(name = list(distrib, data3))
    names(list) = i
    final_perm = append(final_perm, list)
    data2 = rbind(data2,data3)
  }
  list = list(summary = data2)
  final_perm = append(final_perm, list)
  return(final_perm)
  
}

group_permutation = perm_test2(permutation2, permutations = 1000)

data_perm = tibble(Core = group_permutation[[1]][1] |> unlist() , 
                   Innactive =  group_permutation[[2]][1] |> unlist(),
                   Specific = group_permutation[[3]][1] |> unlist() , 
                   Core50 = group_permutation[[4]][1] |> unlist() , 
                   Core25 = group_permutation[[5]][1] |> unlist() )

colnames(data_perm) = c('75% Tissues', 'Innactive',  'Specific', '50% Tissues', '25% Tissues' )

data_perm = data_perm |> pivot_longer(cols = `75% Tissues`:`25% Tissues`, names_to = 'name', values_to = 'value')
data_perm$name= factor(data_perm$name, levels = c('75% Tissues', '50% Tissues', '25% Tissues', 'Specific', 'Innactive'))

data_perm2 = group_permutation$summary
data_perm2$name= factor(data_perm2$name, levels = c('75% Tissues', '50% Tissues', '25% Tissues', 'Specific', 'Innactive'))
data_perm |> ggplot(aes(x = value)) + theme_classic() + geom_density(aes(fill = name), show.legend = F) + geom_vline(data = data_perm2, aes(xintercept = observed),linetype = 'dashed')  +
  facet_wrap(~name, scales = 'free', nrow = 1) + 
  theme(axis.text.x = element_text(size = 10),
        strip.background = element_rect(
          color="black", fill="lightgray", size=1.5, linetype="solid"),
        panel.border = element_rect(color = "black", fill = NA, size = 1)) + ylab('Density') + xlab('LAD Frequency') + ggtitle('Median LAD Localization - Permutation Test')
