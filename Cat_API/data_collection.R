library("httr2")

base_url <- "https://api.thecatapi.com/v1/images/search"

my_request <- httr2::request(base_url = base_url)

my_request

my_request |>
	httr2::req_dry_run()

response <- my_request |>
	httr2::req_perform()

response |>
	httr2::resp_status()
response |>
	httr2::resp_status_desc()

content <- response |>
	httr2::resp_body_json()
