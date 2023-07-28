#!/usr/bin/env Rscript

require(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
name <- args[1]
jacusa_tables <- args[2:length(args)]

sample_thresh <- 10  #minimum detection filter: n. samples (donors) in which edited site must be detected

res_other <-
    map_df(jacusa_tables, read_tsv, col_types = cols())
# moved to jacusa_helper
# filter(nchar(basechange) == 4) %>% 
# filter(flagINFO == "*") %>%
# filter(altcount >= altCount_thresh) %>%
# mutate(siteID = paste(region, position, sep = "_")) %>%
# mutate(totalDP = altcount * (1 / altprop)) %>%
# filter(totalDP >= DP_thresh)

nSamp_site_counts <-
    res_other %>%
    filter(basechange %in% c("A->G", "T->C")) %>%
    count(siteID)

forSamDepth <-
    nSamp_site_counts %>%
    filter(n >= sample_thresh) %>% # filter siteID by prevalence in at least 10 of N samples
    select(siteID) %>%
    distinct() %>%
    separate(siteID, into = c("chr", "pos"), convert = TRUE, sep = "_") %>%
    mutate(pos = as.numeric(pos), start = pos - 1) %>%
    select(chr, start, pos)

write_tsv(
    forSamDepth,
    col_names = FALSE,
    file = paste0(name, ".stranded_edSites.bed")
)

saveRDS(
    res_other,
    str_c(name, ".res_other.rds")
)

saveRDS(
    nSamp_site_counts,
    str_c(name, ".nSamp_site_counts.rds")
)

