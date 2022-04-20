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
