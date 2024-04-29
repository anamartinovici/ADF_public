# query and get number of results
# query and loop until I get all results

#> country: Moldova (MD)
#> https://www.kiva.org/lend/filter?country=MD
#> there are 20 results in the browser

get_url <- "https://api.kivaws.org/graphql"
response_allresults <-
    httr2::req_perform(
        req = httr2::request(base_url = get_url) |>
            httr2::req_url_query(
                query = '{
                            lend {
                                loans (filters: {country: ["MD"]},
                                       sortBy: newest) {
                                            totalCount
                                            values {
                                                id
                                                description
                                                loanAmount
                                                fundraisingDate
                                                loanFundraisingInfo {
                                                 fundedAmount
                                                  reservedAmount
                                                  isExpiringSoon
                                                }
                                                geocode {
                                                  country {
                                                    name
                                                    isoCode
                                                    region
                                                    ppp
                                                    numLoansFundraising
                                                    fundsLentInCountry
                                                  }
                                                }
                                                status
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
content_allresults <- response_allresults |>
    httr2::resp_body_json()


# based on the first query, I know the total number of results
totalCount <- content_allresults[["data"]][["lend"]][["loans"]][["totalCount"]]
n_per_request <- 5
n_requests <- totalCount %/% n_per_request + 
    as.integer((totalCount %% n_per_request) > 0)

# create an object where you store all responses
all_response_objects <- vector(mode = "list", length = n_requests)

request_number <- 1
# you could use either for or while
while(request_number <= n_requests) {
    # use tic toc functions to see how much time it takes per request
    tictoc::tic(glue::glue("duration for request number {request_number}"))
    
    current_offset <- (request_number - 1) * n_per_request
    
    response <-  httr2::req_perform(
        req = httr2::request(base_url = get_url) |>
            httr2::req_url_query(
                query = glue::glue('{{
                                        lend {{
                                            loans (offset: {current_offset},
                                                    limit: {n_per_request},
                                                    filters: {{country: ["MD"]}},
                                                    sortBy: newest) {{
                                                totalCount
                                                values {{
                                                    id
                                                    description
                                                    loanAmount
                                                    fundraisingDate
                                                    loanFundraisingInfo {{
                                                     fundedAmount
                                                      reservedAmount
                                                      isExpiringSoon
                                                    }}
                                                    geocode {{
                                                      country {{
                                                        name
                                                        isoCode
                                                        region
                                                        ppp
                                                        numLoansFundraising
                                                        fundsLentInCountry
                                                      }}
                                                    }}
                                                    status
                                                }}
                                            }}
                                        }}
                                }}'),
                verbosity = 1
            ))
    
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

save(all_response_objects, 
     file = here::here("API_Kiva",
                       "loans_filter", 
                       "collect_data.RData"))



