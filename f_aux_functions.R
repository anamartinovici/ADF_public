f_test_API <- function(use_header) {
	# this function tests if the bearer token allows a successful GET request
	
	params <- list(user.fields = 'description')
	handle <- 'Ana_Martinovici'
	url_handle <- paste0('https://api.twitter.com/2/users/by?usernames=', handle)
	response <-	httr::GET(url = url_handle,
						  config = httr::add_headers(.headers = use_header),
						  query = params)
	
	# for a complete list of HTTP status codes, 
	#		check: https://developer.twitter.com/ja/docs/basics/response-codes
	if(httr::status_code(response) == 200) {
		cat(paste("The HTTP status code is: ", status_code(response), sep = ""))
		cat("\n")
		cat("This means Success!")
	} else {
		cat("Oh, no! Something went wrong.\n")
		cat(paste("The HTTP status code is: ", status_code(response), "\n", sep = ""))
		cat("Check the list of HTTP status codes to understand what went wrong.\n")
	}
}

f_test_token_API <- function() {
	if(is.null(Sys.getenv("BEARER_TOKEN"))) {
		cat("The bearer token is empty. Fix this before you continue!\n")
	} else {
		cat("The bearer token has a value. Let's see if it's the correct value.\n")
		headers <- c(Authorization = paste0('Bearer ', Sys.getenv("BEARER_TOKEN")))
		f_test_API(use_header = headers)
		# put the headers in a list so it doesn't show up on screen
		my_header <- list(headers = headers)
		return(my_header)
	}
}

f_test_API_standard_academic <- function(token_type) {
	if(token_type == "standard") {
		bearer_token <- Sys.getenv("BEARER_TOKEN")
	} else {
		if(token_type == "academic") {
			bearer_token <- Sys.getenv("BEARER_TOKEN_ACAD")
		} else {
			cat("You need to specify the type of token to test: standard or academic.")
		}
	}
	
	if(is.null(bearer_token)) {
		cat("The bearer token is empty. Fix this before you continue!\n")
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
			cat(paste("The HTTP status code is: ", status_code(response), sep = ""))
			cat("\n")
			cat("This means Success!")
		} else {
			cat("Oh, no! Something went wrong.\n")
			cat(paste("The HTTP status code is: ", status_code(response), "\n", sep = ""))
			cat("Check the list of HTTP status codes to understand what went wrong.\n")
		}
		
		# put the headers in a list so it doesn't show up on screen
		my_header <- list(headers = headers)
		return(my_header)
	}
}