library(dplyr, quietly = T, warn.conflicts = F)
library(tidyr, quietly = T, warn.conflicts = F)
library(tibble, quietly = T ,warn.conflicts = F)
library(here, quietly = T ,warn.conflicts = F)
library(readxl, quietly = T ,warn.conflicts = F)
library(janitor, quietly = T ,warn.conflicts = F)
library(forcats, quietly = T ,warn.conflicts = F)

yssup <- read_excel(here("04_yssup_trackings", "data_prep", "provided","yssup_data.xlsx")) %>%
  clean_names() %>%
  rename(tipette = x1) %>%
  mutate(
    across(everything(), ~ replace_na(.x, "niente")),
    across(everything(), ~ as_factor(x = .x)),
    across(everything(), ~ fct_recode(.x, scopata = "s")),
    across(everything(), ~ fct_recode(.x, baciata = "b"))
  )


saveRDS(yssup, file = '04_yssup_crud/data_prep/prepped/yssup.RDS')
