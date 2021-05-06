# ADF_public
Public repo for Analyzing Digital Footprints (course in the BAM MSc, RSM)

Files includes in this repo:
- collect_data.R : this file shows an example of how you can structure the data collection file

- Useful_resources.Rmd: this file includes links to documentation about the Twitter API that you should check for your project

- f_aux_functions.R: this file contains three functions that test whether you can connect to the Twitter API

- examples/example_check_tweet_text_length.R: this file shows how you can retrieve the full text of retweets. The "text" field is truncated to 140 characters, so you need to use expansions in order to get the full text.

- examples/example_collect_all_tweets_from_one_user.R: this file shows how to use the users endpoint to collect all tweets written by a user. It also shows how to process data.

- examples/example_collect_tweets_and_replies.R: this file shows how you can collect recent tweets that mention a specific hashtag (this includes: original tweets, retweets, quoted tweets, replies).

- example/how_to_manage_rate_limits.R: this file show how you can use `Sys.sleep()` to work around API rate limits.

- example/how_to_use_curl.sh: this file shows how you could use curl to get data from the API, using the filtered stream endpoint

- example/workshop_20210429/collect_data.R: this file was used during the April 29 workshop and shows how you can collect data (including loops)

- example/workshop_20210429/process_data.R: this file was used during the April 29 workshop and shows how you can process nested lists, using `purrr::map`. It takes as input `example/workshop_20210429/raw_dataset.RData` and produces as output `example/workshop_20210429/processed_data.RData:`

- example/workshop_20210429/raw_dataset.RData: this file contains the response objects created by 
collect_data.R

- example/workshop_20210429/processed_data.RData: this file contains the processed dataset created by process_data.R. 
