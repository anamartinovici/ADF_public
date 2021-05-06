# this example shows you how to manage rate limits for the full archive search
# for other endpoints, you need to check the rate limits and then adjust 
#		Sys.sleep accordingly

rm(list = ls())

library("httr")
library("tidyverse")
library("tictoc")

source("f_aux_functions.R")

##################
# I have added a new function in the f_aux_functions file that takes as input
#		the type of token: standard or academic
# if you only use one type of token, you can use the f_test_token_API() function
my_header <- f_test_API_standard_academic(token_type = "academic")
##################

API_endpoint_fullsearch <- "https://api.twitter.com/2/tweets/search/all?query="

params <- list(query = "#CatsOfTwitter",
			   tweet.fields = "created_at,author_id",
			   max_results = "20")

# request data from the API N_request times
N_requests <- 5

# this creates the list where I store all the response objects
raw_dataset <- NULL

# make the first request
request_number <- 1
# use tic toc functions to see how much time it takes per request
tic("duration of the first request: ")
response <- httr::GET(url = API_endpoint_fullsearch,
					  config = httr::add_headers(.headers = my_header[["headers"]]),
					  query = params)
httr::status_code(response)
obj <- httr::content(response)
# the next_token tells the API where to continue retrieving tweets from
obj[["meta"]][["next_token"]]

# add the response I got from the API
raw_dataset[[request_number]] <- response
# add a name to this list element to know it is the response for the 
#		first iteration / first request
names(raw_dataset)[request_number] <- paste0("iter_", request_number)
toc()

Sys.sleep("2")

# now, use a loop to get the remaining number of requests
# as long as there are more tweets to collect, meta.next_token has a value
# otherwise, if meta.next_token is null, this means you've collected all tweets
#     that meet the query criteria
while(request_number < N_requests && !is.null(obj[["meta"]][["next_token"]])) {
	# use tic toc functions to see how much time it takes per request
	tic("duration for request number: ")
	
	# keep track of the current request number
	request_number <- request_number + 1
	
	# append the pagination token to the other info you have in params  
	# this makes sure that the other elements in the params list remain the same
	#		so the response will contain the same types of data as for the 
	#		first request
	params[["next_token"]] <- obj[["meta"]][["next_token"]]
	
	response <- httr::GET(url = API_endpoint_fullsearch,
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
	
	# add the current response to the raw_dataset
	raw_dataset[[request_number]] <- response
	names(raw_dataset)[request_number] <- paste0("iter_", request_number)
	
	Sys.sleep("2")
	
	# this stops the "stopwatch" and prints the time it took to execute the 
	#       lines of code between tic and toc
	toc()
}


