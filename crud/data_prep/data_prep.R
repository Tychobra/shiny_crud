library(dplyr)
library(tidyr)
library(tibble)

# Create dataframe from 'mtcars' built-in dataset
mtcars <- mtcars

mtcars <- rownames_to_column(mtcars, var = 'model')

# Converting Weight (i.e. 'wt') from 1000's of lbs to lbs
mtcars$wt <- mtcars$wt * 1000
  

# Converting binary values to intended, character values
mtcars <- mtcars %>%
  mutate(vs = ifelse(vs == 0, 'V-shaped', 'Straight'),
         am = ifelse(am == 0, 'Automatic', 'Manual'),
         is_deleted = FALSE)

saveRDS(mtcars, file = 'data_prep/prepped/mtcars.RDS')
