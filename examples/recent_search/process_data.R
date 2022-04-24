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
load("examples/recent_search/raw_dataset.RData")

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
# extract all "includes" lists in a separate list
raw_includes <- purrr::map(raw_content, "includes")

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

# similar to what you've done for "data", process information in "includes"
purrr::map_int(raw_includes, length)
purrr::map(raw_includes, names)

raw_users <- map(raw_includes, "users")
purrr::map_int(raw_users, length)
sum(purrr::map_int(raw_users, length))
raw_users <- purrr::flatten(raw_users)
length(raw_users)
table(purrr::map_int(raw_users, length))

raw_ref_tweets <- map(raw_includes, "tweets")
purrr::map_int(raw_ref_tweets, length)
sum(purrr::map_int(raw_ref_tweets, length))
raw_ref_tweets <- purrr::flatten(raw_ref_tweets)
length(raw_ref_tweets)

raw_places <- map(raw_includes, "places")
purrr::map_int(raw_places, length)
sum(purrr::map_int(raw_places, length))
raw_places <- purrr::flatten(raw_places)
length(raw_places)
names(raw_places)
names(raw_places) <- NULL

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
			conversation_id    = map_chr(., "conversation_id"),
			possibly_sensitive = map_chr(., "possibly_sensitive"),
			reply_settings     = map_chr(., "reply_settings"),
			geo_place_id       = map_chr(., f_get_geo_placeid),
			retweet_count      = map_int(., f_get_retweet_count),
			reply_count        = map_int(., f_get_reply_count),
			like_count         = map_int(., f_get_like_count),
			quote_count        = map_int(., f_get_quote_count),
			tweet_type         = map_chr(., f_get_tweet_type),
			ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info

df_users <- raw_users %>% 
	{tibble(u_id                = map_chr(., "id"),
			u_name              = map_chr(., "name"),
			u_username          = map_chr(., "username"),
			u_protected         = map_chr(., "protected"),
			u_description       = map_chr(., "description"),
			u_verified          = map_chr(., "verified"),
			u_created_at        = map_chr(., "created_at"),
			u_profile_image_url = map_chr(., "profile_image_url"),
			u_location          = map_chr(., f_get_u_location),
			u_followers_count   = map_int(., f_get_followers_count),
			u_following_count   = map_int(., f_get_following_count),
			u_tweet_count       = map_int(., f_get_tweet_count),
			u_listed_count      = map_int(., f_get_listed_count))}
nrow(df_users)
df_users <- distinct(df_users)
nrow(df_users)

df_ref_tweets <- raw_ref_tweets %>% 
	{tibble(ref_tweet_id           = map_chr(., "id"),
			ref_text               = map_chr(., "text"),
			ref_lang               = map_chr(., "lang"),
			ref_created_at         = map_chr(., "created_at"),
			ref_author_id          = map_chr(., "author_id"),
			ref_source             = map_chr(., "source"),
			ref_conversation_id    = map_chr(., "conversation_id"),
			ref_possibly_sensitive = map_chr(., "possibly_sensitive"),
			ref_reply_settings     = map_chr(., "reply_settings"),
			ref_geo_place_id       = map_chr(., f_get_geo_placeid),
			ref_retweet_count      = map_int(., f_get_retweet_count),
			ref_reply_count        = map_int(., f_get_reply_count),
			ref_like_count         = map_int(., f_get_like_count),
			ref_quote_count        = map_int(., f_get_quote_count),
			ref_tweet_type         = map_chr(., f_get_tweet_type),
			ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(df_ref_tweets)
df_ref_tweets <- distinct(df_ref_tweets)
nrow(df_ref_tweets)

df_places <- raw_places %>% 
	{tibble(place_id           = map_chr(., "id"),
			place_full_name    = map_chr(., "full_name"),
			place_name         = map_chr(., "name"),
			place_country      = map_chr(., "country"),
			place_country_code = map_chr(., "country_code"),
			place_type         = map_chr(., "place_type"))}
nrow(df_places)
df_places <- distinct(df_places)
nrow(df_places)

save(df_tweets, df_users, df_ref_tweets, df_places, file = "examples/recent_search/processed_data.RData")

