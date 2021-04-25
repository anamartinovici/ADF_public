# The file shows how you can collect ALL tweets from a specific user
# we'll be collecting the tweets of @Ana_Martinovici
# Check: https://developer.twitter.com/en/docs/twitter-api/tweets/timelines/introduction
#		for info on:
#			rate limits
#			fields and expansions
#
# This file also shows how you can process data returned by the API

library("httr")
library("jsonlite")
library("tidyverse")

bearer_token <- Sys.getenv("BEARER_TOKEN")
if(is.null(bearer_token)) {
	cat("The bearer token is empty. Fix this before you continue!")
} else {
	cat("The bearer token has a value. Let's see if it's the correct value.\n")
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

# convert the output to text and then to a data frame
obj <- httr::content(response, as = "text")
df_obj <- jsonlite::fromJSON(obj, flatten = TRUE) %>% as.data.frame
print(df_obj)
# data.id is the user_id I need
user_id <- df_obj[["data.id"]]

################################################
# Step 2: get tweets for this user_id
################################################

url_handle <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")
# by default, the number of tweets retrieved per request is 10
# you can ask for more tweets (check the documentation for exact info)
params <- list(max_results = '50')
response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["headers"]]),
					  query = params)
httr::status_code(response)
obj <- httr::content(response, as = "text")
df_obj <- jsonlite::fromJSON(obj, flatten = TRUE) %>% as.data.frame
tweets_1_to_50 <- df_obj

# there are more tweets to collect, so we need to use the pagination token 
# to make sure that you're doing this correctly and are not missing any tweets, 
#		you can try this:
#		collect tweets 1-25
#		use the pagination token to collect tweets 26-50
#		compare the results against tweets_1_to_50

#		collect tweets 1-25
params <- list(max_results = '25')
response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["headers"]]),
					  query = params)
httr::status_code(response)
obj <- httr::content(response, as = "text")
df_obj <- jsonlite::fromJSON(obj, flatten = TRUE) %>% as.data.frame
tweets_1_to_25 <- df_obj

#		use the pagination token to collect tweets 26-50
next_token <- distinct(tweets_1_to_25 %>% select(meta.next_token))
next_token

params <- list(max_results = '25',
			   pagination_token = next_token$meta.next_token)
response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["headers"]]),
					  query = params)
httr::status_code(response)
obj <- httr::content(response, as = "text")
df_obj <- jsonlite::fromJSON(obj, flatten = TRUE) %>% as.data.frame
tweets_26_to_50 <- df_obj

#		compare the results against tweets_1_to_50
tweets_two_steps <- rbind(tweets_1_to_25, 
						  tweets_26_to_50 %>% select(-meta.previous_token))
# are any tweet ids in the initial df of 50 that are not available in the two step procedure?
anti_join(tweets_1_to_50, tweets_two_steps, by = c("data.id", "data.text"))
# are any tweet ids in the two step procedure that are not available in the initial df of 50?
anti_join(tweets_two_steps, tweets_1_to_50, by = c("data.id", "data.text"))

remove(df_obj, next_token, params, response, tweets_1_to_25, tweets_1_to_50,
	   tweets_26_to_50, tweets_two_steps, handle, obj, url_handle)

################################################
# Step 3: get ALL tweets for this user_id
################################################

# get the first batch
url_handle <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")
n_tweets_per_request <- '50'
params <- list(max_results = n_tweets_per_request)
response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["headers"]]),
					  query = params)
httr::status_code(response)
obj <- httr::content(response, as = "text")
df_obj <- jsonlite::fromJSON(obj, flatten = TRUE) %>% as.data.frame

ALL_tweets <- df_obj %>% select(data.id, data.text)

# as long as there are more tweets to collect, meta.next_token has a value
# otherwise, if meta.next_token is null, this means you've collected all
# tweets from this user
while(!is.null(df_obj[["meta.next_token"]])) {
	# this is where I left
	next_token <- distinct(df_obj %>% select(meta.next_token))
	
	params <- list(max_results = n_tweets_per_request,
				   pagination_token = next_token$meta.next_token)
	response <-	httr::GET(url = url_handle,
						  config = httr::add_headers(.headers = my_header[["headers"]]),
						  query = params)
	httr::status_code(response)
	obj <- httr::content(response, as = "text")
	df_obj <- jsonlite::fromJSON(obj, flatten = TRUE) %>% as.data.frame
	ALL_tweets <- rbind(ALL_tweets, df_obj %>% select(data.id, data.text))
}


################################################
# Step 4: add twitter fields and expansions
################################################

remove(df_obj, next_token, params, response, 
	   obj, n_tweets_per_request)

# I choose 7 because based on the tweets I have on my page, this will include:
#		replies to tweets written by other people
#		quoted retweets
#		retweets
#		original tweets (that I wrote without replying to someone else)
params <- list(max_results = '7',
			   tweet.fields = 'created_at,author_id,conversation_id',
			   expansions = 'referenced_tweets.id')
# referenced_tweets.id will return a Tweet object that the focal Tweet is referencing
# focal Tweet = the tweet that includes the target_hashtag

response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["headers"]]),
					  query = params)
# always check the HTTP response before doing anything else
httr::status_code(response)
# if 200 (Success), then continue.
# else, fix the issues first
# convert the output
obj <- httr::content(response)
names(obj)

# check obj -> this is a nested list now, so you need to take additional steps to process it
table(sapply(obj[["data"]], length))
table(sapply(obj[["includes"]], length))

# always check your data!
# this is a tweet that I wrote in reply to a tweet written by another user
obj[["data"]][[1]]
# the author_id is my own ID (Ana_Martinovici), so the ID of the user who wrote the "focal tweet"
obj[["data"]][[1]][["author_id"]]
user_id
# this gives info about the id of the tweet I've replied to
obj[["data"]][[1]][["referenced_tweets"]]
# notice that the id of the referenced_tweet matches the conversation id
obj[["data"]][[1]][["referenced_tweets"]][[1]][["id"]]
obj[["data"]][[1]][["conversation_id"]]

# rearrange the data
df_data <- obj[["data"]] %>% 
	{tibble(created_at      = map_chr(., "created_at"),
			text            = map_chr(., "text"),
			tweet_id        = map_chr(., "id"),
			author_id       = map_chr(., "author_id"),
			conversation_id = map_chr(., "conversation_id"),
			ref_tweet       = map(., "referenced_tweets"))}
# check: https://jennybc.github.io/purrr-tutorial/ls01_map-name-position-shortcuts.html#data_frame_output
# for info about what the {} around tibble do
# you can also try it out without {} and see how df_data differs
	
		
# some tweets are retweets or quoted, others are neither (ref_tweet is null)
f_get_tweet_type <- function(input_list) {
	if(is.null(input_list)) {
		# you can change the label to use for a tweet that is neither a quote or a retweet
		return("original_tweet")
	} else {
		return(input_list[[1]][["type"]])	
	}
}

f_get_ref_tweet_id <- function(input_list) {
	if(is.null(input_list)) {
		# you can change the label to use for a tweet that is neither a quote or a retweet
		return("original_tweet")
	} else {
		return(input_list[[1]][["id"]])	
	}
}

# for those tweets that are retweets or quoted, extract their type and id
df_data <- df_data %>%
	mutate(tweet_type          = map_chr(ref_tweet, f_get_tweet_type),
		   referenced_tweet_id = map_chr(ref_tweet, f_get_ref_tweet_id))

# now that you've extracted all info from ref_tweet, you can remove it
df_data <- df_data %>% select(-ref_tweet)
# how many tweets if each type do I have?
table(df_data[["tweet_type"]])

# includes contains info about those tweets that are not "original"
#		that is, tweets that I've replied to or retweeted
length(obj[["includes"]])
length(obj[["includes"]][["tweets"]])
# for example, this is the tweet written by Robert Rooderkerk that I have replied to
obj[["includes"]][["tweets"]][[1]]
# this is a tweet that I have retweeted and that included a quote of another tweet
obj[["includes"]][["tweets"]][[3]]

################################################
# Step 5: add even more twitter fields and expansions
################################################
remove(df_data, obj, response)

# I choose 7 because based on the tweets I have on my page, this will include:
#		replies to tweets writen by other people
#		quoted retweets
#		retweets
#		original tweets (that I wrote without replying to someone else)
params <- list(max_results = '7',
			   tweet.fields = 'created_at,author_id,conversation_id',
			   expansions = 'referenced_tweets.id,in_reply_to_user_id')
# referenced_tweets.id will return a Tweet object that the focal Tweet is referencing
# in_reply_to_user_id will return a user object representing the Tweet author this requested Tweet is a reply of
# focal Tweet = the tweet that includes the target_hashtag

response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["headers"]]),
					  query = params)
# always check the HTTP response before doing anything else
httr::status_code(response)
# if 200 (Success), then continue.
# else, fix the issues first
# convert the output
obj <- httr::content(response)
names(obj)

# check obj -> this is a nested list now, so you need to take additional steps to process it
table(sapply(obj[["data"]], length))
table(sapply(obj[["includes"]], length))

# always check your data!
# this is a tweet that I wrote in reply to a tweet written by another user
obj[["data"]][[1]]
# the author_id is my own ID (Ana_Martinovici), so the ID of the user who wrote the "focal tweet"
obj[["data"]][[1]][["author_id"]]
user_id
# this gives info about the id of the tweet I've replied to
obj[["data"]][[1]][["referenced_tweets"]]
# notice that the id of the referenced_tweet matches the conversation id
obj[["data"]][[1]][["referenced_tweets"]][[1]][["id"]]
obj[["data"]][[1]][["conversation_id"]]

# rearrange the data
df_data <- obj[["data"]] %>% 
	tibble(created_at       = map_chr(., "created_at"),
		   text             = map_chr(., "text"),
		   tweet_id         = map_chr(., "id"),
		   author_id        = map_chr(., "author_id"),
		   conversation_id  = map_chr(., "conversation_id"),
		   l_rpl_to_user_id = map(., "in_reply_to_user_id"),
		   ref_tweet        = map(., "referenced_tweets"))

# some tweets are retweets or quoted, others are neither (ref_tweet is null)
f_get_tweet_type <- function(input_list) {
	if(is.null(input_list)) {
		# you can change the label to use for a tweet that is neither a quote or a retweet
		return("original_tweet")
	} else {
		return(input_list[[1]][["type"]])	
	}
}

f_get_ref_tweet_id <- function(input_list) {
	if(is.null(input_list)) {
		# you can change the label to use for a tweet that is neither a quote or a retweet
		return("original_tweet")
	} else {
		return(input_list[[1]][["id"]])	
	}
}

f_get_reply_to_user_id <- function(input_list) {
	if(is.null(input_list)) {
		# you can change the label to use for a tweet that is neither a quote or a retweet
		return("original_tweet")
	} else {
		return(input_list[[1]])	
	}
}

# for those tweets that are retweets or quoted, extract their type and id
df_data <- df_data %>%
	mutate(tweet_type          = map_chr(ref_tweet, f_get_tweet_type),
		   referenced_tweet_id = map_chr(ref_tweet, f_get_ref_tweet_id),
		   reply_to_user_id    = map_chr(l_rpl_to_user_id, f_get_reply_to_user_id))

# now that you've extracted all info from ref_tweet, you can remove it
df_data <- df_data %>% select(-ref_tweet, -l_rpl_to_user_id)
# how many tweets if each type do I have?
table(df_data[["tweet_type"]])

# includes contains info about those tweets that are not "original"
#		that is, tweets that I've replied to or retweeted
length(obj[["includes"]])
length(obj[["includes"]][["tweets"]])
# for example, this is the tweet written by Robert Rooderkerk that I have replied to
obj[["includes"]][["tweets"]][[1]]
# this is a tweet that I have retweeted and that included a quote of another tweet
obj[["includes"]][["tweets"]][[3]]


