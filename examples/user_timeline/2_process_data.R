# there's no need for rm(list=ls()) at the start of the file
# to restart the R Session on Windows, use CTRL + SHIFT + F10

# you need httr to GET data from the API and then to extract the content
# note that httr can be used also with other APIs, 
#		it this is not specific to the Twitter API
library("httr")
# you need the tidyverse to process data, we'll be relying on purrr quite a bit
library("tidyverse")
# add more packages ONLY if you need to use them

# f_aux_functions.R contains functions for data processing
source("f_aux_functions.R")

# load the dataset you've just collected
load("examples/user_timeline/raw_dataset.RData")

raw_content <- purrr::map(all_response_objects, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each element in the raw_dataset list

# this is how many response objects you've received from the API
length(raw_content)

# this gives the names of the elements within the raw_obj list
purrr::map(raw_content, names)
# each element in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
raw_tweets <- purrr::map(raw_content, "data")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(raw_tweets, length)
# this is how many tweets there are in total
sum(purrr::map_int(raw_tweets, length))
# check how raw_tweets looks like and then flatten it
# flatten removes the first level of indexes from the list
raw_tweets <- purrr::flatten(raw_tweets)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elements as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(raw_tweets)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(raw_tweets, length))
purrr::map(raw_tweets, names)

# you need to use functions to extract elements that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
df_tweets <- raw_tweets %>% 
	{tibble(tweet_id           = map_chr(., "id"),
			text               = map_chr(., "text"),
			lang               = map_chr(., "lang"),
			created_at         = map_chr(., "created_at"),
			author_id          = map_chr(., "author_id"),
			source             = map_chr(., "source"),
			retweet_count      = map_int(., f_get_retweet_count),
			reply_count        = map_int(., f_get_reply_count),
			like_count         = map_int(., f_get_like_count),
			quote_count        = map_int(., f_get_quote_count))}

save(df_tweets, df_users, df_ref_tweets, df_places, file = "examples/recent_search/processed_data.RData")

