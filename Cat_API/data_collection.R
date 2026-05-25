library("httr2")
library("tidyverse")

n_cats <- 220
n_cats_per_request <- 100
n_requests <- n_cats %/% n_cats_per_request + 
	as.numeric((n_cats %% n_cats_per_request) > 0)

list_response <- vector(mode = "list", length = n_requests)
for(index_page in 1:n_requests) {
	if (index_page == n_requests) {
		n_cats_per_request <- n_cats - (n_requests - 1)*n_cats_per_request
	}
	
	my_request <- httr2::request(base_url = "https://api.thecatapi.com/v1/images/search") |>
		req_url_query(api_key = Sys.getenv("CAT_API_KEY"),
					  limit = n_cats_per_request,
					  page = index_page - 1,
					  has_breeds = 1,
					  format = "json",
					  order = "ASC")
	
	list_response[[index_page]] <- my_request |>
		httr2::req_perform()
	
	if(httr2::resp_status_desc(list_response[[index_page]]) != "OK") {
		stop("not OK")
	}
}

save(list_response,
	 file = here::here("Cat_API", "collect_data.Rdata"))