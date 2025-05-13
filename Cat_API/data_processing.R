library("httr2")
library("tidyverse")

load(here::here("Cat_API", "data_collection.RData"))

response |>
	httr2::resp_status_desc()

content <- response |>
	httr2::resp_body_json()

