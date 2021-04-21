# The file shows how you can collect recent tweets that mention a specific hashtag
# Check: https://developer.twitter.com/en/docs/twitter-api/tweets/search/introduction
#	and  https://developer.twitter.com/en/docs/twitter-api/conversation-id
#		for info on:
#			rate limits
#			fields and expansions
#			conversation ids
#
# This file also shows how you can process data returned by the API

library("httr")
library("jsonlite")
library("tidyverse")

bearer_token <- Sys.getenv("BEARER_TOKEN")
if(is.null(bearer_token)) {
	cat("The bearer token is empty. Fix this before you continue!")
} else {
	cat("The bearer token has a value. Let's see if it's the correct value.")
	cat("\n")
	headers <- c(Authorization = paste0('Bearer ', bearer_token))
	source("f_aux_functions.R")
	f_test_API(use_header = headers)
	# put the headers in a list so it doesn't show up on screen
	my_header <- list(headers = headers)
	remove(headers)
	remove(bearer_token)
	remove(f_test_API)
}

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
# Step 1: collect recent tweets that include the target hashtag
################################################

target_hashtag <- "#CatsOfTwitter"

# this is the endpoint you need to connect to
API_endpoint_recentsearch <- 'https://api.twitter.com/2/tweets/search/recent?query='

# the url_handle is:
# check https://www.rdocumentation.org/packages/utils/versions/3.6.2/topics/URLencode
#		to understand why you need to use URLencode if the target_hashtag contains 
#		characters other than English alphanumeric characters
url_handle <- paste0(API_endpoint_recentsearch, URLencode(target_hashtag, reserved = TRUE))
url_handle

# get recent tweets that match the criteria
response_V1 <- httr::GET(url = url_handle,
						 config = httr::add_headers(.headers = my_header[["headers"]]))
# always check the HTTP response before doing anything else
httr::status_code(response_V1)
# if 200 (Success), then continue.
# else, fix the issues first

# convert the output, this should create a list
obj_V1 <- httr::content(response_V1)
# check the list
names(obj_V1)
sapply(obj_V1[["data"]], names)
# by default, you only get the tweet id and the tweet text
# if you want other fields, you need to specify them in the field and/or extension parameters

################################################
# Step 2: add more tweet fields
################################################

params <- list(tweet.fields = 'created_at,author_id,conversation_id')
# get recent tweets that match the criteria
response_V2 <- httr::GET(url = url_handle,
						 config = httr::add_headers(.headers = my_header[["headers"]]),
						 query = params)
# always check the HTTP response before doing anything else
httr::status_code(response_V2)
# if 200 (Success), then continue.
# else, fix the issues first

# convert the output, this should create a list
obj_V2 <- httr::content(response_V2)
names(obj_V2)
sapply(obj_V2[["data"]], names)
# now you also get the other fields you've specified in "params"

# check meta to know what's the next_token if you want to collect more tweets
obj_V2[["meta"]]
# see examples/example_collect_all_tweets_from_one_user.R for how to use pagination

# for your analysis, it's probably easier if the tweet data is stored as a data frame
# these two examples above are equivalent
df_data_1 <- dplyr::bind_rows(obj_V2[["data"]])
df_data_V2 <- purrr::map_df(obj_V2[["data"]], dplyr::bind_rows)
remove(df_data_1)

################################################
# Step 3: add expansions that return a user object
################################################

# "author.id" will return a user object representing the Tweet's author
params[["expansions"]] <- c('author_id')
response_V3 <- httr::GET(url = url_handle,
						 config = httr::add_headers(.headers = my_header[["headers"]]),
						 query = params)
# always check the HTTP response before doing anything else
httr::status_code(response_V3)
# if 200 (Success), then continue.
# else, fix the issues first

# convert the output
obj_V3 <- httr::content(response_V3)
names(obj_V3)
# now you have also "includes"

# you have the same tweet fields as before in data
sapply(obj_V3[["data"]], names)
# this is the user object added because you've specified params[["expansions"]] <- c('author_id')
sapply(obj_V3[["includes"]][["users"]], names)


