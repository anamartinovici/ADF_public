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
# add more packages ONLY if you need to use them

# f_aux_functions.R contains a function that you can use to test the token
source("f_aux_functions.R")
my_header <- f_test_API(token_type = "elevated")

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
# collect tweets that contain a target keyword
#
################################################
################################################

# you should only collect the data you need
# you can first check what tweet fields you can add
req_tweet_fields <- c("author_id",
					  "conversation_id",
					  "created_at",
					  "geo",
					  "id",
					  "in_reply_to_user_id",
					  "lang",
					  "possibly_sensitive",
					  "public_metrics",
					  "referenced_tweets",
					  "reply_settings",
					  "source",
					  "text",
					  "withheld")
req_tweet_fields <- stringr::str_c(req_tweet_fields, collapse = ",")

req_place_fields <- c("contained_within",
					  "country",
					  "country_code",
					  "full_name",
					  "geo",
					  "id",
					  "name",
					  "place_type")
req_place_fields <- stringr::str_c(req_place_fields, collapse = ",")

req_user_fields <- c("created_at",
					 "description",
					 "id",
					 "location",
					 "name",
					 "pinned_tweet_id",
					 "profile_image_url",
					 "protected",
					 "public_metrics",
					 "url",
					 "username",
					 "verified",
					 "withheld")
req_user_fields <- stringr::str_c(req_user_fields, collapse = ",")

req_expansions <- c("author_id",
					"geo.place_id",
					"in_reply_to_user_id",
					"referenced_tweets.id",
					"referenced_tweets.id.author_id")
req_expansions <- stringr::str_c(req_expansions, collapse = ",")

params <- list(query = "#CatsofTwitter OR #Caturday from:Number10cat",
			   #start_time = "2021-06-05T05:00:00Z",
			   #end_time = "2021-06-06T05:00:00Z",
			   max_results = 100,
			   tweet.fields = req_tweet_fields,
			   expansions = req_expansions,
			   place.fields = req_place_fields,
			   user.fields = req_user_fields)

EP_recent_search   <- "https://api.twitter.com/2/tweets/search/recent?query="
response <- httr::GET(url = EP_recent_search,
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

# decide what's your stopping rule and implement it using "while" or "for"
# request data from the API N_request times
N_requests <- 50
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
	
	response <- httr::GET(url = EP_recent_search,
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
	
	Sys.sleep("2")
	
	# this stops the "stopwatch" and prints the time it took to execute the 
	#       lines of code between tic and toc
	toc()
}

save(all_response_objects, file = "examples/recent_search/raw_dataset.RData")
