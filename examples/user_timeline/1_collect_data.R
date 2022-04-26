# there's no need for rm(list=ls()) at the start of the file
# to restart the R Session on Windows, use CTRL + SHIFT + F10

################################################
################################################
#
# test if you can connect to the API
#
################################################
################################################

# you need httr to GET data from the API
# note that httr can be used also with other APIs, 
#		it this is not specific to the Twitter API
library("httr")
# tictoc provides functions for timing
library("tictoc")
library("tidyverse")
# add more packages ONLY if you need to use them

# f_aux_functions.R contains a function that you can use to test the token
source("f_aux_functions.R")
my_header <- f_test_API(token_type = "elevated")

################################################
# Step 1: collect the user_id for this handle
################################################
handle <- 'Ana_Martinovici'
url_handle <- paste0('https://api.twitter.com/2/users/by?usernames=', handle)
response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["headers"]]))
# always check the HTTP response before doing anything else
httr::status_code(response)
# if 200 (Success), then continue.
# else, fix the issues first

# get the response
obj <- httr::content(response)
# data.id is the user_id I need
user_id <- obj[["data"]][[1]][["id"]]

################################################
# Step 2: get the timeline for this user_id
################################################

# get the first batch
url_handle <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")
n_tweets_per_request <- '100'
req_tweet_fields <- c("author_id",
					  "created_at",
					  "id",
					  "lang",
					  "public_metrics",
					  "source",
					  "text")
req_tweet_fields <- stringr::str_c(req_tweet_fields, collapse = ",")
params <- list(max_results = n_tweets_per_request,
			   tweet.fields = req_tweet_fields)
response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["headers"]]),
					  query = params)
httr::status_code(response)

# create an object where you store all responses
all_response_objects <- NULL
# so far, I've only requested data from the API once
request_number <- 1
# add the response I got from the API
all_response_objects[[request_number]] <- response
# add a name to this list element to know it is the response for the 
#		first iteration / first request
names(all_response_objects)[request_number] <- paste0("request_", request_number)

# as long as there are more tweets to collect, meta.next_token has a value
# otherwise, if meta.next_token is null, this means you've collected all
# tweets from this user
obj <- httr::content(response)
obj[["meta"]][["next_token"]]

# now, use a loop to get the remaining number of requests
# as long as there are more tweets to collect, meta.next_token has a value
# otherwise, if meta.next_token is null, this means you've collected all tweets
#     that meet the query criteria
while(!is.null(obj[["meta"]][["next_token"]])) {
	Sys.sleep("2")
	# use tic toc functions to see how much time it takes per request
	tic("duration for request number: ")
	
	# keep track of the current request number
	request_number <- request_number + 1
	
	# append the pagination token to the other info you have in params  
	# this makes sure that the other elements in the params list remain the same
	#		so the response will contain the same types of data as for the 
	#		first request
	params[["pagination_token"]] <- obj[["meta"]][["next_token"]]
	
	response <- httr::GET(url = url_handle,
						  config = httr::add_headers(.headers = my_header[["headers"]]),
						  query = params)
	httr::status_code(response)
	obj <- httr::content(response)
	
	# you can (and should) print some messages so you know 
	#		how many requests you've already placed
	#		and if these requests were successful
	cat(paste0("Request number: ", request_number, 
			   " has HTTP status: ", httr::status_code(response), "\n"))
	# you could also add a check on the http status code in the while loop
	
	# add the current response to all_response_objects
	all_response_objects[[request_number]] <- response
	names(all_response_objects)[request_number] <- paste0("request_", request_number)
	
	# this stops the "stopwatch" and prints the time it took to execute the 
	#       lines of code between tic and toc
	toc()
}

save(all_response_objects, file = "examples/user_timeline/raw_dataset.RData")
