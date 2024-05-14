#> if you place a request for loans that meet a set of criteria (filters)
#> the API results 20 loan IDs by default
#> if you want more results, then you need to specify how many in "limit"
#> even if you ask for more than 100 IDs, the API returns only 100 per response
#> to get more than 100, you need to place multiple calls and use "offset"

get_url <- "https://api.kivaws.org/graphql"
response_allresults <-
	httr2::req_perform(
		req = httr2::request(base_url = get_url) |>
			httr2::req_url_query(
				query = '{
                            lend {
                                loans (filters: {riskRating: {min:0.5, max:2.5}},
                                       sortBy: newest) {
                                            totalCount
                                            values {
                                                id
                                            }
                                       }
                                }
                        }'),
		verbosity = 1
	)
# check status code
response_allresults |>
	httr2::resp_status()
# check status code meaning
response_allresults |>
	httr2::resp_status_desc()
# see the body, use _json because that matches the type of the response
# use str to visualize it better
response_allresults |>
	httr2::resp_body_json() |>
	str()
content_allresults <- response_allresults |>
	httr2::resp_body_json()

#> this is how many results there are in total:
content_allresults[["data"]][["lend"]][["loans"]][["totalCount"]]
#> now, the value I get as I am testing this code is 1085
#> if you execute this code at another time, 
#> the number will most likely be different
#> for example, just 5 minutes earlier, the value I had was 1084

#> the number of IDs returned by default is:
length(content_allresults[["data"]][["lend"]][["loans"]][["values"]])

# ask for more than 20 IDs ----
get_url <- "https://api.kivaws.org/graphql"
response_allresults <-
	httr2::req_perform(
		req = httr2::request(base_url = get_url) |>
			httr2::req_url_query(
				query = '{
                            lend {
                                loans (limit: 1100,
                                	   filters: {riskRating: {min:0.5, max:2.5}},
                                       sortBy: newest) {
                                            totalCount
                                            values {
                                                id
                                            }
                                       }
                                }
                        }'),
		verbosity = 1
	)
# check status code
response_allresults |>
	httr2::resp_status()
# check status code meaning
response_allresults |>
	httr2::resp_status_desc()
# see the body, use _json because that matches the type of the response
# use str to visualize it better
response_allresults |>
	httr2::resp_body_json() |>
	str()
content_allresults <- response_allresults |>
	httr2::resp_body_json()

#> this is how many results there are in total:
content_allresults[["data"]][["lend"]][["loans"]][["totalCount"]]

#> the number of IDs returned:
length(content_allresults[["data"]][["lend"]][["loans"]][["values"]])
#> even though I asked for 1100, I got only 100, the max

# use a loop and offset ----
# based on the previous query, I know the total number of results
totalCount <- content_allresults[["data"]][["lend"]][["loans"]][["totalCount"]]
#> I can get max 100 IDs per request, so I need this many requests:
n_per_request <- 100
N_requests <- totalCount %/% n_per_request + 
	as.integer((totalCount %% n_per_request) > 0)
	
all_response_objects <- vector(mode = "list", length = N_requests)
request_number <- 1
tictoc::tic("while loop takes this much:")
# you could use either for or while
while(request_number <= N_requests) {
	# use tic toc functions to see how much time it takes per request
	tictoc::tic(glue::glue("duration for request number {request_number}"))
	
	current_offset <- (request_number - 1) * n_per_request
	
	response <- httr2::req_perform(
		req = httr2::request(base_url = get_url) |>
			httr2::req_url_query(
				query = glue::glue("{{
										lend {{
											loans (offset: {current_offset},
													limit: {n_per_request},
													filters: {{riskRating: {{min:0.5, max:2.5}}}},
                                    				sortBy: newest) {{
                                    					totalCount
                                            			values {{
                                            				id
                                            			}}
                                    				}}
                                		}}
								   }}")
			),
		verbosity = 0
	)
	
	# you can (and should) print some messages so you know 
	#		how many requests you've already placed
	#		and if these requests were successful
	if((response |>
		httr2::resp_status_desc()) == "OK") {
		message("Request number ", request_number, " has status OK")
	} else {
		stop("Request number ", request_number, "status not OK, please check")
	}
	
	if(!is.null((response |>
				 httr2::resp_body_json())[["errors"]])) {
		stop("Request number ", request_number, "has an error, please check")
	}
	
	# add the current response to all_response_objects
	all_response_objects[[request_number]] <- response
	names(all_response_objects)[request_number] <- paste0("request_", request_number)
	
	# increment the request number
	request_number <- request_number + 1
	
	# this stops the "stopwatch" and prints the time it took to execute the 
	#       lines of code between tic and toc
	tictoc::toc()
}
tictoc::toc()

#> this gives you the loan IDs, so you still need to get the info
#> for each of these loan IDs
#> first, check that you have as many unique loan IDs as you were expecting

all_content <- purrr::map(all_response_objects, 
						  httr2::resp_body_json)
all_content <- purrr::map(all_content, "data")
all_content <- purrr::map(all_content, "lend")
all_content <- purrr::map(all_content, "loans")
all_content <- purrr::map(all_content, "values")
all_content <- purrr::flatten(all_content)
length(all_content)

vec_loan_IDs <- purrr::map_int(all_content, "id")
if(length(vec_loan_IDs) == length(unique(vec_loan_IDs))) {
	message("You have ", length(vec_loan_IDs), " unique loan IDs.")
	message("Is this what you were expecting?")
} else {
	stop("hmmmm, you have some duplicate IDs. Look into it!")
}

#> now that you have the vector of loan IDs for which you want more info,
#> you can follow the example in API_Kiva / loans_filter / collect_data.R
#> to loop through them and get detailed info




