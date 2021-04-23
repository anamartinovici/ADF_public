library("httr")
library("jsonlite")
library("tidyverse")
# add any other packages you might need to use

################################################
################################################
#
# test if you can connect to the API
#
################################################
################################################

# if you have correctly set your bearer token as an environment variable, 
# this retrieved the value of the token and assigns it to "bearer_token"
bearer_token <- Sys.getenv("BEARER_TOKEN")
# if you didn't manage to create the environment variable, then copy paste the 
# token below and comment out the line
# bearer_token <- "CopyPasteYourTokenHere"

# the authorization header is composed of the text Bearer + space + the token
headers <- c(Authorization = paste0('Bearer ', bearer_token))

# f_aux_functions.R is in the same directory as collect_data.R, which is the
# same as the working directory
# f_aux_functions.R contains two functions that you can use to test the token
# source("f_aux_functions.R") brings these in the current workspace 
source("f_aux_functions.R")
# you should now see f_test_API and f_test_token_API in the Environment pane
# type ?source in the console to learn more

f_test_API(use_header = headers)

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

################################################
################################################
#
# Collect the data you need for your project
#
################################################
################################################

# here you add all the code you use to collect data
#		and nothing but the code you use to collect data
# I recommend that at first, you collect a small number of observations (max 100)
# this way, you first check what data you get, 
#				figure out how to process the API result
# after you are sure you get all the types of data you need, and you know how 
# to process the results from the API, you can collect more observations

################################################
################################################
#
# Save the data in the assignment repository
#
################################################
################################################

# save the "raw" dataset -> commit -> push to your assignment repository 
# if the dataset is too large to be pushed to GitHub:
#			1. split it in smaller files that you commit -> push to GitHub OR
#			2. let me know and I’ll set up another way for you to share data