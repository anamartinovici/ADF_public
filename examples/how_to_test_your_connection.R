# there's no need for rm(list=ls()) at the start of the file
# to restart the R Session on Windows, use CTRL + SHIFT + F10

################################################
################################################
#
# test if you can connect to the API
#
################################################
################################################

# if you have correctly set your bearer token as an environment variable, 
# this retrieved the value of the token and assigns it to "bearer_token"
source("f_aux_functions.R")
bearer_token <- f_test_API(token_type = "elevated")

################################################
################################################
#
# Does the bearer token allow you to collect data?
# if "Yes" -> you can collect data
# else -> fix the error(s)
#
################################################
################################################


