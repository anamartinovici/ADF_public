library("httr2")
library("tidyverse")

#> place a request for a 1-hour token
request_access_token <- httr2::request("https://accounts.spotify.com/api/token") |>
	httr2::req_method("POST") |>
	httr2::req_body_raw(paste0("grant_type=client_credentials&client_id=",
							   Sys.getenv("API_SPOTIFY_CLIENT_ID"),
							   "&client_secret=",
							   Sys.getenv("API_SPOTIFY_CLIENT_SECRET")), 
						"application/x-www-form-urlencoded") |>
	httr2::req_perform()
#> check the status of your request
httr2::resp_status_desc(request_access_token)
#> extract the token
temp_access_token <- request_access_token |> 
	httr2::resp_body_json()

#> we're going to request artist data for "fazathecat"
#> https://open.spotify.com/artist/1NPgPB1Ay8nmZIGfr4Xm6Y?si=_xrmZLoQQ8Gcor8OZw2ZQQ

first_request <- httr2::request("https://api.spotify.com/v1/artists/4Z8W4fKeB5YxbusRsdQVPb") |>
	httr2::req_headers(
		Authorization = paste0("Bearer  ", temp_access_token[["access_token"]]),
	) |>
	httr2::req_perform()
httr2::resp_status_desc(first_request)
first_response <- httr2::resp_body_json(first_request)

#> congrats! you've just completed the 'hello world' step