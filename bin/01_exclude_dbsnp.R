#!/usr/bin/env Rscript

require(tidyverse)

args <- commandArgs(trailingOnly = TRUE)

sample <- args[1]
jacusa_table_fn <- args[2]
dbSNP_loci_fn <- args[3]

jacusa_table <- readRDS(jacusa_table_fn)

dbSNP_loci <- read_tsv(
  dbSNP_loci_fn, 
  col_names = c('region', 'position'),
  col_types = cols(position = col_integer()))

res <- anti_join(jacusa_table, dbSNP_loci, by = c('region', 'position'))

saveRDS(res, str_c(sample, '.jacusa_table.dbSNP_filt.rds'))
