library("httr2")

n_observations <- 500
n_per_request <- 100
n_requests <- n_observations / n_per_request

list_responses <- vector(mode = "list", length = n_requests)

base_url <- "https://api.thecatapi.com/v1/images/search"

my_request <- httr2::request(base_url = base_url)

for (index_page in 1:n_requests) {
	my_request <- my_request |>
		httr2::req_url_query(api_key = Sys.getenv("CAT_API_KEY"),
							 limit = 100,
							 order = "ASC",
							 page = index_page - 1)
	
	list_responses[[index_page]] <- my_request |>
		httr2::req_perform()
	
	if (httr2::resp_status_desc(list_responses[[index_page]]) != "OK") {
		stop("check this request")
	}
}

save(list_responses,
	 file = here::here("Cat_API", "data_collection.RData"))
