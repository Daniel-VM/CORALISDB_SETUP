#!/usr/bin/env Rscript
#                  db_preprocess.R
#
# Processing of ncRNA-gene target interaction retrieved form web sources .
# The resulting files will be used to set up CORALIS integrated database.

# LOAD DEPENDENDICES
if (!require(dplyr)){
  install.packages("dplyr", dependencies = TRUE, repos = 'http://cloud.r-project.org/')
  library(dplyr)
}

if (!require(openxlsx)){
  install.packages("openxlsx", dependencies = TRUE, repos = 'http://cloud.r-project.org/')
  library(openxlsx)
}

if (!require(stringr)){
  install.packages("stringr", dependencies = TRUE, repos = 'http://cloud.r-project.org/')
  library(stringr)
}

# COMMAND LINE ARGUMENTS
args        <- commandArgs(trailingOnly = TRUE)
mirtarbase  <- as.character(args[1]) %>% read.xlsx()
raid        <- as.character(args[2]) %>%
  read.delim(., header = TRUE, fill = FALSE, sep = "\t", row.names = NULL)


# MIRTARBASE
mirtarbase_proc <- subset(mirtarbase, `Species.(miRNA)` != `Species.(Target.Gene)`) %>% # Select intraspecie miRNA-targe interactions
  setdiff(mirtarbase, .) %>% # Keep rows in which host miRNA interacts with host gene
  select(miRNA, `Target.Gene`, `Species.(Target.Gene)`) %>%
  rename(.,
         I1= miRNA,
         I2= `Target.Gene`,
         Species= `Species.(Target.Gene)`
  ) %>%
  mutate(., type = "miRNA_mRNA", source = "miRTarbase")

# RNAINTER DATABASE (RAID)
# Filter experimentally validated data (strong & weak evidence)
raid_exp <- raid %>%
  select(., -predict) %>%
  subset((strong!="N/A") || (weak!="N/A")) %>%
  rename( Interactor1 = Interactor1.Symbol, Interactor2 = Interactor2.Symbol) %>%
  select(Interactor1,
         Category1,
         Species1,
         Interactor2,
         Category2,
         Species2)

# Keep rows in which host ncRNAs interacts with host gene (mRNA)
raid_expIntra <- subset(raid_exp, Species1 != Species2) %>%
  setdiff(raid_exp, .)

# FILTER RAID data by NCRNA-GENE TARGETs (avoid other type of interactions listed in the database)

n <- c(
  "circRNA",
  "lncRNA",
  "miRNA",
  "ncRNA",
  "rRNA",
  "piRNA",
  "snoRNA",
  "snRNA"
)

raid_proc <- lapply(n, FUN = function(rna){

  raid_rnas1 <- filter(raid_expIntra, (Category1 == rna & Category2 == "mRNA"))
  raid_rnas2 <- filter(raid_expIntra, (Category1 == "mRNA" & Category2 == rna)) %>%
    rename(.,
           Interactor2 = Interactor1,
           Category2   = Category1,
           Species2    = Species1,
           Interactor1 = Interactor2,
           Category1   = Category2,
           Species1    = Species2)

  raid_rnas <- bind_rows(raid_rnas1, raid_rnas2) %>%
    select(., Interactor1, Interactor2, Species1) %>%
    rename(I1 = Interactor1,
           I2 = Interactor2,
           Species = Species1) %>%
    mutate(., type = paste(rna,"mRNA",sep="_"), source = "RAID")
  return(raid_rnas)
}) %>% do.call(rbind,.)

# MERGE miRTarbase and RNAINTER (RAID) data into a single dataframe. Remove duplicated rows.
mirtarbase_raid <- bind_rows(mirtarbase_proc, raid_proc) %>%  distinct()

# Set a minimun of ncRNA-target interaction by specie.
trh <- 30
spl <- mirtarbase_raid %>% group_split(type)

mirtarbase_raid_ok <- lapply(spl, function(i){
  v <- c()
  j <- i %>% group_by(Species) %>% tally()

  for(r in 1:nrow(j)){
    line <- j[r,]
    if(line$n >= trh){
      v<-c(v,line$Species) # Species in 'v' meets condition threshold >= 'thr'
    }
  }
  k<-subset(i, Species %in% v)
  return(k)
  
  }) %>% do.call(rbind, .)

# mirtarbase_raid_ok %>% group_by(Species) %>% tally()

# Save files:--------------
write.csv(mirtarbase_raid_ok, "mirtarbase_raid.csv", row.names = FALSE, quote = FALSE)