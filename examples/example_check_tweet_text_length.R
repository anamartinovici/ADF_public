# IMPORTANT if you plan to use the text of retweets (and not only replies, 
#		quote tweets, or original tweets)

# The file checks if tweet text is truncated for retweets
# I have a separate account (BayesCalling) that I have used to tweet just now
# I've tweeted using a hashtag I will search for and 
#		I have tweets that are exactly 280 characters long
#		I have quote retweeted these original tweets so I can now test if
#		the text is truncated or not

# there's no need for rm(list=ls()) at the start of the file
# to restart the R Session on Windows, use CTRL + SHIFT + F10

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

# you can use logical operators to add more hashtags
hashtag_1 <- "#test1ng"
hashtag_2 <- "#test1ngADF"	
target_hashtag <- paste0(hashtag_1, " OR ", hashtag_2)
target_hashtag

# this is the endpoint you need to connect to
API_endpoint_recentsearch <- 'https://api.twitter.com/2/tweets/search/recent?query='

# the url_handle is:
# check https://www.rdocumentation.org/packages/utils/versions/3.6.2/topics/URLencode
#		to understand why you need to use URLencode if the target_hashtag contains 
#		characters other than English alphanumeric characters
url_handle <- paste0(API_endpoint_recentsearch, URLencode(target_hashtag, reserved = TRUE))
url_handle
# add expansions to make sure you get the full text also for retweets
params <- list(tweet.fields = 'referenced_tweets',
			   expansions = 'referenced_tweets.id.author_id',
			   max_results = '50')
# get recent tweets that match the criteria
response_V4 <- httr::GET(url = url_handle,
						 config = httr::add_headers(.headers = my_header[["headers"]]),
						 query = params)
# always check the HTTP response before doing anything else
httr::status_code(response_V4)
obj_V4 <- httr::content(response_V4)
names(obj_V4)
names(obj_V4[["data"]][[1]])
names(obj_V4[["includes"]][["tweets"]][[1]])
obj_V4[["data"]][[1]]
obj_V4[["data"]][[2]]

# some tweets are retweets or quoted, others are neither (ref_tweet is null)
f_get_tweet_type <- function(input_list) {
	if(is.null(input_list[["referenced_tweets"]])) {
		# you can change the label to use for a tweet that is neither a quote or a retweet
		return("original_tweet")
	} else {
		return(input_list[["referenced_tweets"]][[1]][["type"]])	
	}
}

f_get_ref_tweet_id <- function(input_list) {
	if(is.null(input_list[["referenced_tweets"]])) {
		# you can change the label to use for a tweet that is neither a quote or a retweet
		return("original_tweet")
	} else {
		return(input_list[["referenced_tweets"]][[1]][["id"]])	
	}
}

# compare the text you get from "data" with the one you get from "includes"
text_tweets_V4_data <- obj_V4[["data"]] %>% {
	tibble(id = map_chr(., "id"),
		   text_of_tweet = map_chr(., "text"),
		   author_id = map_chr(., "author_id"),
		   tweet_type = map_chr(., f_get_tweet_type),
		   ref_tweet_id = map_chr(., f_get_ref_tweet_id))
}

text_tweets_V4_data <- text_tweets_V4_data %>% 
	mutate(text_length = str_length(text_of_tweet),
		   includes_hashtag_1 = str_detect(text_of_tweet, regex(hashtag_1, ignore_case = TRUE)),
		   includes_hashtag_2 = str_detect(text_of_tweet, regex(hashtag_2, ignore_case = TRUE)))
text_tweets_V4_data %>% filter(includes_hashtag_1 == FALSE, includes_hashtag_2 == FALSE)
# the text of retweets is truncated so it might appear as if the hashtag is not included
# get the full text of the tweet that was retweeted from "includes"

names(obj_V4[["includes"]][["tweets"]][[1]])
obj_V4[["includes"]][["tweets"]][[1]]

text_tweets_V4_includes <- obj_V4[["includes"]][["tweets"]] %>% {
	tibble(ref_tweet_id = map_chr(., "id"),
		   ref_text_of_tweet = map_chr(., "text"),
		   ref_author_id = map_chr(., "author_id"),
		   tweet_type = map_chr(., f_get_tweet_type),
		   ref_tweet_id_bis = map_chr(., f_get_ref_tweet_id))
}

# text_tweets_V4_data contains all the tweets that include the target hashtag
# if one of those tweets is in fact a retweet (not a quote retweet), then the 
#		text of the tweet is "RT @handle_of_original_tweet_author: truncated_text"
#		the text is truncated, so I only get 140 characters
#		this means that if the target hashtag appeared at the end of the tweet, it will be cut off
# example:
# this tweet is a retweet
text_tweets_V4_data[1, ]
text_tweets_V4_data[1, "id"]
text_tweets_V4_data[1, "text_of_tweet"]
text_tweets_V4_data[1, "ref_tweet_id"]
# and this is the original tweet
text_tweets_V4_data[2, ]
text_tweets_V4_data[2, "id"]
# the id of the original tweet matches the value of the referenced tweet
(text_tweets_V4_data[2, "id"] == text_tweets_V4_data[1, "ref_tweet_id"])
str_length(text_tweets_V4_data[2, "text_of_tweet"])
text_tweets_V4_data[["text_of_tweet"]][2]
text_tweets_V4_data[2, "ref_tweet_id"]

# for retweets it's good to check the text of the original tweet, 
#	just in case it's been truncated
fulltext_retweets <- text_tweets_V4_data %>% 
	filter(tweet_type == "retweeted")

fulltext_retweets <- fulltext_retweets %>% 
	left_join(text_tweets_V4_includes %>% 
			  	select(ref_tweet_id, ref_text_of_tweet), 
			  by = "ref_tweet_id")

fulltext_retweets <- fulltext_retweets %>% 
	mutate(ref_text_length = str_length(ref_text_of_tweet),
		   ref_includes_hashtag_1 = str_detect(ref_text_of_tweet, regex(hashtag_1, ignore_case = TRUE)),
		   ref_includes_hashtag_2 = str_detect(ref_text_of_tweet, regex(hashtag_2, ignore_case = TRUE)))
fulltext_retweets %>% filter(includes_hashtag_1 == FALSE, includes_hashtag_2 == FALSE)
fulltext_retweets %>% filter(ref_includes_hashtag_1 == FALSE, ref_includes_hashtag_2 == FALSE)

# problem solved