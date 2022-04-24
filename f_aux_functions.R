f_test_API <- function(token_type) {
	if(!sum(token_type %in% c("essential", "elevated", "academic"))) {
		stop("You need to specify the type of token to test: essential, elevated, or academic.")	
	}
	
	if(token_type == "essential") {
		bearer_token <- Sys.getenv("BEARER_TOKEN_ESSE")
	}
	
	if(token_type == "elevated") {
		bearer_token <- Sys.getenv("BEARER_TOKEN_ELEV")
	}
	
	if(token_type == "academic") {
		bearer_token <- Sys.getenv("BEARER_TOKEN_ACAD")
	}
	
	if(is.null(bearer_token) || bearer_token == "") {
		stop("The bearer token is empty. Fix this before you continue!\n")
	} else {
		cat("The bearer token has a value. Let's see if it's the correct value.\n")
		headers  <- c(Authorization = paste0("Bearer ", bearer_token))
		params   <- list(user.fields = "description")
		response <-	httr::GET(url = "https://api.twitter.com/2/users/by?usernames=Ana_Martinovici",
							  config = httr::add_headers(.headers = headers),
							  query = params)
		# for a complete list of HTTP status codes, 
		#		check: https://developer.twitter.com/ja/docs/basics/response-codes
		if(httr::status_code(response) == 200) {
			cat(paste("The HTTP status code is: ", httr::status_code(response), "\n", sep = ""))
			cat("This means Success!\n")
		} else {
			cat("Oh, no! Something went wrong.\n")
			cat(paste("The HTTP status code is: ", httr::status_code(response), "\n", sep = ""))
			cat("Check the list of HTTP status codes to understand what went wrong.\n")
		}
		
		# put the headers in a list so it doesn't show up on screen
		my_header <- list(headers = headers)
		return(my_header)
	}	
}

# the functions below show examples for how to extract information from nested lists
# these account for not all tweets having the same fields
f_get_geo_placeid <- function(input_list) {
	if(is.null(input_list[["geo"]])) {
		# you can change the label
		return("no_geo_info")
	} else {
		return(input_list[["geo"]][["place_id"]])	
	}
}

f_get_retweet_count <- function(input_list) {
	if(is.null(input_list[["public_metrics"]])) {
		# you can change the label 
		return("no_public_metrics")
	} else {
		return(input_list[["public_metrics"]][["retweet_count"]])	
	}
}

f_get_reply_count <- function(input_list) {
	if(is.null(input_list[["public_metrics"]])) {
		# you can change the label 
		return("no_public_metrics")
	} else {
		return(input_list[["public_metrics"]][["reply_count"]])	
	}
}

f_get_like_count <- function(input_list) {
	if(is.null(input_list[["public_metrics"]])) {
		# you can change the label 
		return("no_public_metrics")
	} else {
		return(input_list[["public_metrics"]][["like_count"]])	
	}
}

f_get_quote_count <- function(input_list) {
	if(is.null(input_list[["public_metrics"]])) {
		# you can change the label 
		return("no_public_metrics")
	} else {
		return(input_list[["public_metrics"]][["quote_count"]])	
	}
}

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

f_get_u_location <- function(input_list) {
	if(is.null(input_list[["location"]])) {
		# you can change the label 
		return("no_u_location")
	} else {
		return(input_list[["location"]])	
	}
}

f_get_followers_count <- function(input_list) {
	if(is.null(input_list[["public_metrics"]])) {
		# you can change the label 
		return("no_public_metrics")
	} else {
		return(input_list[["public_metrics"]][["followers_count"]])	
	}
}

f_get_following_count <- function(input_list) {
	if(is.null(input_list[["public_metrics"]])) {
		# you can change the label 
		return("no_public_metrics")
	} else {
		return(input_list[["public_metrics"]][["following_count"]])	
	}
}

f_get_tweet_count <- function(input_list) {
	if(is.null(input_list[["public_metrics"]])) {
		# you can change the label 
		return("no_public_metrics")
	} else {
		return(input_list[["public_metrics"]][["tweet_count"]])	
	}
}

f_get_listed_count <- function(input_list) {
	if(is.null(input_list[["public_metrics"]])) {
		# you can change the label 
		return("no_public_metrics")
	} else {
		return(input_list[["public_metrics"]][["listed_count"]])	
	}
}


