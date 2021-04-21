library("httr")
library("jsonlite")
library("tidyverse")
# add any other packages you might need to use

# test if you can connect to the API
# source("f_aux_functions.R")
# use_header <- f_test_token_API()
# if you want to use the test functions, you need to uncomment the two lines above
# you can also take a look at examples/example_collect_all_tweets_from_one_user.R 
#		for another way of testing if you can connect to the API

################################################
################################################
#
# Does the bearer token allow you to collect data?
# if "Yes" -> continue
# else -> fix the error(s)
#
################################################
################################################

# here you add all the code you use to collect data
#		and nothing but the code you use to collect data

# save the "raw" dataset -> commit -> push to your assignment repository 
# if the dataset is too large to be pushed to GitHub:
#			1. split it in smaller files that you commit -> push to GitHub OR
#			2. let me know and I’ll set up another way for you to share data