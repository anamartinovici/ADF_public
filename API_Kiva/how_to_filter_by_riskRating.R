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
content_allresults
content_allresults |>
	str()
