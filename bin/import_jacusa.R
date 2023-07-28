#!/usr/bin/env Rscript
require(JacusaHelper)
require(tidyverse)

altCount_thresh <- 3 #minimum detection filter: read depth for alternate (i.e., edited) allele
DP_thresh     <- 10  #minimum detection filter: total read depth across candidate edited site
# Based on code written by Simon N Thomas (UROP student)

args <- commandArgs(trailingOnly = TRUE)
sample <- args[1]
jacusa_output <- args[2]

res <-
  JacusaHelper::Read(jacusa_output, stat = 1.56, cov = 5) %>%
  JacusaHelper::AddEditingFreqInfo()

altcount <- sapply(
  1:dim(res$matrix2)[1],
  function(x) {
    max(res$matrix2[x, -which.max(res$matrix1[x, ])])
  }
)

## NB stranding here may be flipped. resulting stats are identical, but not order.
altbase <- sapply(
  1:dim(res$matrix2)[1],
  function(x) {
    names(which.max(res$matrix2[x, -which.max(res$matrix1[x, ])]))
  }
)

altprop <- sapply(
  1:dim(res$matrix2)[1],
  function(x) {
    altcount[x] / max(res$matrix1[x, ])
  }
)

res <-
  res %>%
  with(
    tibble(
      region = contig,
      position = end,
      stat = stat,
      strand = strand,
      sample = sample,
      altcount = altcount,
      altbase = altbase,
      altprop = altprop,
      basechange = baseChange,
      flagINFO = filter_info,
    )
  )  %>% 
  filter(nchar(basechange) == 4) %>% 
  filter(flagINFO == "*") %>%
  filter(altcount >= altCount_thresh) %>%
  mutate(totalDP = altcount * (1 / altprop)) %>%
  filter(totalDP >= DP_thresh) %>%
  mutate(siteID = paste(region, position, sep = "_"))

write_tsv(res, str_c(sample, '.jacusa_table.tsv.gz'))


