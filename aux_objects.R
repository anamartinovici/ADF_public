# you should only collect the data you need
ALL_tweet_fields <- c("attachments",
					  "author_id",
					  "context_annotations",
					  "conversation_id",
					  "created_at",
					  "entities",
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

ALL_place_fields <- c("contained_within",
					  "country",
					  "country_code",
					  "full_name",
					  "geo",
					  "id",
					  "name",
					  "place_type")

ALL_user_fields <- c("created_at",
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

ALL_expansions <- c("attachments.poll_ids",
					"attachments.media_keys",
					"author_id",
					"entities.mentions.username",
					"geo.place_id",
					"in_reply_to_user_id",
					"referenced_tweets.id",
					"referenced_tweets.id.author_id")

EP_username_lookup <- "https://api.twitter.com/2/users/by?usernames="
EP_tweet_lookup    <- "https://api.twitter.com/2/tweets?ids="
EP_recent_search   <- "https://api.twitter.com/2/tweets/search/recent?query="
EP_full_search     <- 'https://api.twitter.com/2/tweets/search/all?query='
