library("httr2")
library("tidyverse")

load(here::here("Cat_API", "collect_data.Rdata"))

list_content <- map(list_response, httr2::resp_body_json)
list_content <- flatten(list_content)
names(list_content) <- paste0("cat", 1:length(list_content))

table(map_int(list_content, length))
#> all list items are of length 5
reduce(map(list_content, names), unique)
#> and these are the names of the 5 items

df_cats <- list_content %>%
	{tibble(obs_id = map_chr(., "id"),
			url    = map_chr(., "url"),
			width  = map_int(., "width"),
			height = map_int(., "height"))}
df_cats <- df_cats %>%
	mutate(cat_number = attr(df_cats[["obs_id"]], "names")) %>%
	relocate(cat_number)

list_breeds <- map(list_content, pluck, "breeds")
list_breeds <- flatten(list_breeds)
list_breeds <- map(list_breeds, 
				   function(x) {
				   	x[["weight_imperial"]] <- x[["weight"]][["imperial"]]
				   	x[["weight_metric"]] <- x[["weight"]][["metric"]]
				   	x[["weight"]] <- NULL
				   	
				   	return(x)
				   })
df_breeds <- map_dfr(list_breeds, as_tibble, .id = "cat_number")

remove(list_response, list_content, list_breeds)

# data checks ----
df_breeds %>%
	distinct(name) %>%
	nrow()
df_breeds %>%
	select(-cat_number) %>%
	distinct() %>%
	nrow()

df_cats <- df_cats %>%
	left_join(df_breeds,
			  by = "cat_number") %>%
	rename(breed_name = name)

df_breeds <- df_breeds %>%
	select(-cat_number) %>%
	distinct()

save(df_breeds,
	 df_cats,
	 file = here::here("Cat_API", "process_data.Rdata"))
