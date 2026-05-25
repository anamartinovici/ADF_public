library("httr2")

my_request <- httr2::request(base_url = "https://api.thecatapi.com/v1/images/search")
my_request

my_request |> 
	httr2::req_dry_run()

response <- my_request |>
	httr2::req_perform()

response |>
	httr2::resp_status()
response |>
	httr2::resp_status_desc()
response |>
	httr2::resp_content_type()

obj <- response |>
	httr2::resp_body_json()

obj[[1]][["url"]]

if (!dir.exists(here::here("Cat_API", "photos"))) {
	dir.create(here::here("Cat_API", "photos"), recursive = TRUE)
}

download.file(url = obj[[1]][["url"]],
			  destfile = here::here("Cat_API", "photos", "one_cat.jpg"),
			  mode = "wb")

grid::grid.raster(jpeg::readJPEG(here::here("Cat_API", "photos", "one_cat.jpg")))
