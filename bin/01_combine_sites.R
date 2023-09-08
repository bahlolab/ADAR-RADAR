#!/usr/bin/env Rscript

require(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
name <- args[1]
redi_counts <- args[2]
jacusa_tables <- args[3:length(args)]
# TODO - update to frequency + count for applicability to small batches
sample_thresh <- as.integer(args[4])

res_other <- map_df(jacusa_tables, readRDS)
# moved to jacusa_helper
# filter(nchar(basechange) == 4) %>%
# filter(flagINFO == "*") %>%
# filter(altcount >= altCount_thresh) %>%
# mutate(siteID = paste(region, position, sep = "_")) %>%
# mutate(totalDP = altcount * (1 / altprop)) %>%
# filter(totalDP >= DP_thresh)

saveRDS(
  res_other,
  str_c(name, ".res_other.rds")
)

all_siteStats <-
  res_other %>%
  # filter(siteID %in% (nSamp_site_counts %>% filter(n>=3) %>% pull(siteID))) %>%
  filter(basechange %in% c("A->G")) %>% # stranded data
  # filter(basechange %in% c('A->G','T->C')) %>%  #unstranded data
  group_by(siteID, basechange, strand) %>% # stranded
  # group_by(siteID,basechange) %>%  #unstranded
  summarize(
    meanAP = mean(altprop), medianAP = median(altprop), sdAP = sd(altprop),
    meanAD = mean(altcount), medianAD = median(altcount), sdAD = sd(altcount),
    nSamples = n()
  ) %>% ungroup()

saveRDS(
  all_siteStats,
  str_c(name, ".all_siteStats.rds")
)



nSamp_site_counts <-
  res_other %>%
  filter(basechange %in% c("A->G", "T->C")) %>%
  count(siteID)

saveRDS(
  nSamp_site_counts,
  str_c(name, ".nSamp_site_counts.rds")
)

forSamDepth <-
  nSamp_site_counts %>%
  filter(n >= sample_thresh) %>% # filter siteID by prevalence in at least 10 of N samples
  select(siteID) %>%
  distinct() %>%
  separate(siteID, into = c("chr", "pos"), convert = TRUE, sep = "_") %>%
  mutate(pos = as.numeric(pos), start = pos - 1) %>%
  select(chr, start, pos) %>%
  na.omit()

write_tsv(
  forSamDepth,
  col_names = FALSE,
  file = paste0(name, ".stranded_edSites.bed.gz")
)

siteStats_rediJOIN <-
  res_other %>%
  semi_join(
    filter(nSamp_site_counts, n >= sample_thresh),
    by = "siteID"
  ) %>%
  filter(
    basechange %in% c("A->G")
  ) %>% # stranded data
  # filter(basechange %in% c('A->G','T->C')) %>%  #unstranded data
  group_by(
    siteID,
    basechange,
    strand
  ) %>% # stranded data
  # group_by(siteID,basechange) %>%  #unstranded data
  summarize(
    meanAP = mean(altprop), medianAP = median(altprop), sdAP = sd(altprop),
    meanAD = mean(altcount), medianAD = median(altcount), sdAD = sd(altcount),
    nSamples = n()
  ) %>%
  ungroup() %>%
  distinct() %>%
  left_join(
    readRDS(redi_counts),
    by = "siteID"
  ) %>%
  group_by(
    siteID
  ) %>%
  filter(
    !(n() > 1 & is.na(chromosome))
  ) %>%
  ungroup()

saveRDS(
  siteStats_rediJOIN,
  str_c(name, ".siteStats_rediJOIN.rds")
)
