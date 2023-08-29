#!/usr/bin/env Rscript
require(JacusaHelper)
require(tidyverse)

# minimum detection filter: read depth for alternate (i.e., edited) allele
altCount_thresh <- 3
# minimum detection filter: total read depth across candidate edited site
DP_thresh <- 10
# remove 'chr' prefix from hg38 coordinates
remove_chr <- TRUE

args <- commandArgs(trailingOnly = TRUE)
sample <- args[1]
jacusa_output <- args[2]
dbSNP_loci_fn <- args[3]

# Based on code written by Simon N Thomas (UROP student)


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
  mutate(region = `if`(remove_chr, str_remove(region, '^chr'), region)) %>%
  mutate(siteID = paste(region, position, sep = "_"))

dbSNP_loci <- read_tsv(
  dbSNP_loci_fn,
  col_names = c("region", "position"),
  col_types = cols(position = col_integer())
)

res <- anti_join(
  res,
  dbSNP_loci,
  by = c("region", "position")
)

saveRDS(res, str_c(sample, '.jacusa_table.rds'))


