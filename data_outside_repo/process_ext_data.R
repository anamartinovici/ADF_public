# this script uses as input a datafile that contains private info
# therefore, this file is not added to the repo
# the file is saved on my local device (in Dropbox)

# this script takes the private file as input, removes private information, and
#	saves a version that is ok to be shared in the repo

library("tidyverse")

# read data from external location
df_rawdata <- read_csv(file = here::here(Sys.getenv("PATH_TO_DROPBOX"), 
										 "Teaching",
										 "RSM",
										 "BAM_programme",
										 "ADF",
										 "ADF_2023_2024",
										 "IA_data",
										 "rawdata.csv"))

# if you want to remove all values from a variable, but keep the variable name:
df_procdata <- df_rawdata %>%
	mutate(var_3 = "values_manually_removed")
# if there are variables you want to exclude alltogether, then use `select`
df_procdata <- df_procdata %>%
	select(-var_3)

# if there are variables you want to mask, then use `mutate`
# here, I replace all characters but the last one with 0
df_procdata <- df_procdata %>%
	mutate(masked_var_1 = str_c(str_dup("0", str_length(var_1) - 1),
								str_sub(var_1, start = str_length(var_1)))) %>%
	select(-var_1)

# if you want to keep info about whether values in a specific column meet 
#	a criteria, then add a helper variable
df_procdata <- df_procdata %>%
	mutate(var_2_has_xy = str_detect(var_2, "xy")) %>%
	select(-var_2)

# after you've made the transformations you need, save the processed dataset 
#	and add to repo
save(df_procdata,
	 file = here::here("data_outside_repo",
	 				  "processed_data.RData"))


