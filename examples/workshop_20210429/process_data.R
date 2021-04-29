# remove all objects from the workspace before running the lines of code below
rm(list = ls())

# you need httr to process the response from the API (using content)
library("httr")

# you need the tidyverse to process data, we'll be relying on purrr quite a bit
library("tidyverse")

# load the dataset that contains all the response objects with the API output
load("examples/workshop_20210429/raw_dataset.RData")

# Always check your data!
# this is how many requests you've placed to the API
length(raw_dataset)
names(raw_dataset)

raw_obj <- map(raw_dataset, httr::content)
# the line above is equivalent to a for loop 
#	that applies the function httr::content to each element in the raw_dataset list

# raw_obj should have the same length as raw_dataset and also same names
length(raw_obj)
names(raw_obj)

# this should the names of the elements within the raw_obj list
map_df(raw_obj, names)
# each element in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
raw_obj_data <- map(raw_obj, "data")
# this shows how many tweets were returned by each API response
map(raw_obj_data, length)
# this is how many tweets there are in total
sum(map_int(raw_obj_data, length))
# check how raw_obj_data looks like and then flatten it
# flatten = removes the first level of indexes from the list
raw_obj_data <- purrr::flatten(raw_obj_data)
# check how raw_obj_data looks like now and notice the differences 
#		to understand what flatten dit
# the flattened list should have as many elements as the number of tweets returned
#		by sum(map_int(raw_obj_data, length)) above
length(raw_obj_data)

# from raw_obj_data, I need: author_id, id, type_of_tweet, info about the referenced tweet
# you need to write functions to extract elements that are in nested lists
f_get_tweet_type <- function(input_list) {
	if(is.null(input_list[["referenced_tweets"]])) {
		# you can change the label for a tweet that is neither a quote nor a retweet
		return("original_tweet")
	} else {
		return(input_list[["referenced_tweets"]][[1]][["type"]])	
	}
}

f_get_ref_tweet_id <- function(input_list) {
	if(is.null(input_list[["referenced_tweets"]])) {
		# you can change the label for a tweet that is neither a quote nor a retweet
		return("original_tweet")
	} else {
		return(input_list[["referenced_tweets"]][[1]][["id"]])	
	}
}

# rearrange the data about tweets in a tibble
df_data <- raw_obj_data %>% 
	{tibble(tweet_id         = map_chr(., "id"),
			text             = map_chr(., "text"),
			author_id        = map_chr(., "author_id"),
			tweet_type       = map_chr(., f_get_tweet_type),
			ref_tweet_id     = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info

# similar to what you've done before for "data", process information in "includes"
raw_obj_includes <- map(raw_obj, "includes")
map(raw_obj_includes, length)
raw_obj_includes <- purrr::flatten(raw_obj_includes)
map(raw_obj_includes, length)
raw_obj_includes <- purrr::flatten(raw_obj_includes)
length(raw_obj_includes)

# If I only need the text and the id, then that I can get like this:
df_includes <- raw_obj_includes %>% 
	{tibble(ref_tweet_id     = map_chr(., "id"),
			ref_author_id    = map_chr(., "author_id"),
			ref_tweet_text   = map_chr(., "text"))}

# for data analysis, you will most likely be using df_data and df_includes
#		so save these to a file and then commit & push to GitHub
save(df_data, df_includes, file = "examples/workshop_20210429/processed_data.RData")
# this makes sure that you have the data you need in a nice format for analysis
#		and no longer have process it every time
# in the .Rmd file for your final report, you will import and use processed_data.RData

# to check if your code works without any errors, select all (on Windows: CTRL + A)
#		and then run all (on Windows: CTRL + Enter)