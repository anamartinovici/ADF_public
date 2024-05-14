#> Do NOT write rm(list = ls()) at the start of the file!
#> also, do NOT write setwd(dir = "path-that-only-this-device-can-find")
#> Why not?
#>		See https://www.tidyverse.org/blog/2017/12/workflow-vs-script/
#> to restart the R Session on Windows, use CTRL + SHIFT + F10

library("httr2")
#> you need the tidyverse collection of packages to process data, 
#> we'll be relying on purrr quite a bit
library("tidyverse")
# add more packages ONLY if you need to use them

# load the dataset you've just collected
load(here::here("API_Kiva",
                "loans_filter", 
                "collect_data.RData"))

all_content <- purrr::map(all_response_objects, 
                          httr2::resp_body_json)
# the line above is equivalent to a for loop 
# that applies the function httr2::resp_body_json to each element 
# in the all_response_objects list

# this is how many content objects we have
length(all_content)

# this gives the names of the elements within the all_content list
purrr::map(all_content, names)
# each element in the all_content list contains data
# extract all "data" lists in a separate list
purrr::map(all_content, "loan")

all_data <- purrr::map(all_content, "data")
purrr::map(all_data, names)
all_data <- purrr::map(all_data, "lend")
purrr::map(all_data, names)
all_data <- purrr::map(all_data, "loan")
purrr::map(all_data, names)

# this is how many loans there are in total
length(all_data)

all_data[[1]][["id"]]
all_data[[1]][["loanFundraisingInfo"]][["fundedAmount"]]

# you need to use functions to extract elements that are in nested lists
# the functions used by this script are already included in f_aux_functions.R
# check the examples
source(here::here("API_Kiva",
                  "aux_functions.R"))

# rearrange the data in a tibble
df_loans <- all_data %>% 
    {tibble(loan_id            = map_int(., "id"),
            description        = map_chr(., "description"),
            loanAmount         = map_chr(., "loanAmount"),
            fundraisingDate    = map_chr(., "fundraisingDate"),
            status             = map_chr(., "status"),
            fundedAmount       = map_chr(., f_get_fundedAmount))}
# check ?map for more info
# make other necessary changes (e.g., data transformations)
df_loans <- df_loans %>%
	mutate(loanAmount = as.numeric(loanAmount),
		   fundedAmount = as.numeric(fundedAmount))

save(df_loans, 
     file = here::here("API_Kiva", 
                       "loans_filter", 
                       "process_data.RData"))

