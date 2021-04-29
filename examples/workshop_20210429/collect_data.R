# remove all objects from the workspace before running the lines of code below
rm(list=ls())

# you need httr to GET data from the API
# note that httr can be used also with other APIs, 
#		it this is not specific to the Twitter API
library("httr")

# you need the tidyverse to process data, we'll be relying on purrr quite a bit
library("tidyverse")

# tictoc provides functions for timing
library("tictoc")

# add any other packages you might need to use

################################################
################################################
#
# test if you can connect to the API
#
################################################
################################################

# if you have correctly set your bearer token as an environment variable, 
# this retrieves the value of the token and assigns it to "bearer_token"
bearer_token <- Sys.getenv("BEARER_TOKEN")
# if you didn't manage to create the environment variable, then copy paste the 
# token below and comment out the line
# bearer_token <- "CopyPasteYourTokenHere"

# the authorization header is composed of the text Bearer + space + the token
headers <- c(Authorization = paste0('Bearer ', bearer_token))

# f_aux_functions.R needs to be in the working directory
# f_aux_functions.R contains two functions that you can use to test the token
# source("f_aux_functions.R") brings these in the current workspace 
source("f_aux_functions.R")
# you should now see f_test_API and f_test_token_API in the Environment pane
#		under "Functions"
# type ?source in the console to learn more

f_test_API(use_header = headers)

# save the headers in a list (prevents the bearer_token from being visible on screen)
my_header <- NULL
my_header[["header"]] <- headers
# remove objects you no longer need
# keeping the workspace clean and well organized reduces the probability of
#		errors and issues
remove(headers, bearer_token)

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
# get account id
################################################

# collect the user_id for this handle
handle <- 'Ana_Martinovici'
url_handle <- paste0('https://api.twitter.com/2/users/by?usernames=', handle)
response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["header"]]))
# always check the HTTP response before doing anything else
httr::status_code(response)
# if 200 (Success), then continue.
# else, fix the issues first

# convert the output
obj <- httr::content(response)
# check obj - it is a list
# obj[["data"][[1][["id"]] is the user_id I need
user_id <- obj[["data"]][[1]][["id"]]

################################################
# get tweets for this user id
################################################

url_handle <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")
# by default, the number of tweets retrieved per request is 10
# you can ask for more tweets (check the documentation for exact info)
# add the fields and expansions you need
params <- list(max_results = '20',
			   tweet.fields = "author_id,in_reply_to_user_id",
			   expansions = "referenced_tweets.id")
response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["header"]]),
					  query = params)
httr::status_code(response)
obj <- httr::content(response)

# create a list called "raw_dataset" and add "response" in it
raw_dataset <- NULL
# req_number stands for request number
# so far, I've only requested data from the API once
req_number <- 1
# add the response I got from the API
raw_dataset[[req_number]] <- response
# add a name to this list element to know it is the response for the 
#		first iteration / first request
names(raw_dataset)[req_number] <- paste0("iter_", req_number)

# as long as there are more tweets to collect, meta.next_token has a value
# otherwise, if meta.next_token is null, this means you've collected all
# tweets from this user

# decide what's your stopping rule and implement it using "while" or "for"
# here I decide to collect all tweets from this user
while(!is.null(obj[["meta"]][["next_token"]])) {
	# keep track the current request number
	req_number <- req_number + 1
	
	# this makes sure that the other elements in the params list remain the same
	#		so the response will contain the same types of data as for the 
	#		first request
	params[["pagination_token"]] <- obj[["meta"]][["next_token"]]
	
	# ask data from the API
	response <-	httr::GET(url = url_handle,
						  config = httr::add_headers(.headers = my_header[["header"]]),
						  query = params)
	obj <- httr::content(response)
	
	# you can (and should) print some messages so you know 
	#		how many requests you've already placed
	#		and if these requests were successful
	cat(paste0("Request number: ", req_number, 
			   " has HTTP status: ", httr::status_code(response), "\n"))
	# you could also add a check on the http status code in the while loop
	
	# add the current response to the raw_dataset
	raw_dataset[[req_number]] <- response
	names(raw_dataset)[req_number] <- paste0("iter_", req_number)
}

# if you run into rate limits, you can use Sys.sleep("seconds")
# try out the lines below to see what it does:
tic("Your device took a nap paused for this many seconds")
Sys.sleep("2")
toc()

# make sure to save the raw_dataset and then commit & push to GitHub
# this makes sure that you have the data you need 
#		and no longer have to ask data from the API
# this means you can process and analyze data even if your internet stops working
# (you'll need to have internet again to be able to commit and push to GitHub)
save(raw_dataset, file = "raw_dataset.RData")
# to check if your code works without any errors, select all (on Windows: CTRL + A)
#		and then run all (on Windows: CTRL + Enter)