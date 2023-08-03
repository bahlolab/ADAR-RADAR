#!/usr/bin/env Rscript

require(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
name         <- args[1]
gene_isec    <- args[2]
pc_gene_isec <- args[3]
repeat_isec  <- args[4]

boundingENSG <-
  read_tsv(
    gene_isec,
    col_names = FALSE
  ) %>%
  mutate(
    siteID = paste(X1, X3, sep = "_")
  ) %>%
  select(
    -c(X2, X6, X8)
  ) %>%
  spread(
    X9,
    X10
  ) %>%
  spread(
    X11,
    X12
  ) %>%
  spread(
    X13,
    X14
  ) %>%
  spread(
    X15,
    X16
  ) %>%
  spread(
    X17,
    X18
  ) %>%
  select(
    siteID,
    everything()
  ) %>%
  dplyr::rename(
    region = X1,
    position = X3,
    source = X4,
    gene = X5,
    strand = X7
  )

saveRDS(
  boundingENSG,
  str_c(name, ".boundingENSG.rds")
)

genFeatures_intersect <-
  read_tsv(
    pc_gene_isec,
    col_names = c("region", "siteStart", "siteEnd", "feature", "sense", "strand", "ENSGID"),
    col_types = cols(region = col_character())
  ) %>%
  distinct() %>%
  mutate(
    siteID = paste(region, siteEnd, sep = "_")
  )

saveRDS(
  boundingENSG,
  str_c(name, ".genFeatures_intersect.rds")
)


RM_Repeats_intersect <-
  read_tsv(
    repeat_isec,
    col_names = FALSE,
    col_types = cols("X1" = col_character())
  ) %>%
  mutate(
    siteID = paste(X1, X3, sep = "_")
  ) %>%
  select(
    -X2,
    -X5,
    -X6
  ) %>%
  dplyr::rename(
    region = X1,
    position = X3,
    Repeat_name = X4,
    RM_strand = X7,
    Repeat_id = X8
  ) %>%
  mutate(
    Repeat_id = paste(Repeat_name, Repeat_id, sep = "_")
  ) %>%
  select(
    siteID,
    Repeat_id,
    everything()
  ) %>%
  mutate(
    RM_repType = ifelse(str_detect(Repeat_name, "Alu"), "Alu", "rep_nonAlu")
  )

saveRDS(
  RM_Repeats_intersect,
  str_c(name, ".RM_Repeats_intersect.rds")
)



