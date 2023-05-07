# do NOT write rm(list = ls()) at the start of the file
# to restart the R Session on Windows, use CTRL + SHIFT + F10
# also, do NOT write setwd(dir = "path-that-only-this-device-can-find")

# add packages you need to use
# do NOT add any packages that are not needed

# step 1 ----
# test if you can connect to the API
# Does the bearer token allow you to collect data?
# if "Yes" -> you can collect data
# else -> fix the error(s)

# step 2 ----
# Collect the data you need for your project
# here you add all the code you use to collect data
#		and nothing but the code you use to collect data
# first, collect only small number of observations (max 100)
# this way, you first check what data you get, 
#				figure out how to process the API result
# after you are sure you get all the types of data you need, and you know how 
# to process the results from the API, you can collect more observations

# step 3 ----
# Save the data in the assignment repository
#
# save the "raw" dataset -> commit -> push to your assignment repository 
# if the dataset is too large to be pushed to GitHub:
#			1. split it in smaller files that you commit -> push to GitHub OR
#			2. let me know and I’ll set up another way for you to share data