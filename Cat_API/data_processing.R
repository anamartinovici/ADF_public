library("httr2")
library("tidyverse")

load(here::here("Cat_API", "data_collection.RData"))

obj1 <- list_responses[[1]]
content1 <- obj1 %>%
	httr2::resp_body_json()

obj2 <- list_responses[[2]]
content2 <- obj2 %>%
	httr2::resp_body_json()

list_content <- vector(mode = "list", length = length(list_responses))
for (index_element in 1:length(list_responses)) {
	list_content[[index_element]] <- list_responses[[index_element]] %>%
		httr2::resp_body_json()
}

list_content <- flatten(list_content)

length(list_content)
names(list_content)


url_list <- map(list_content, pluck, "url")
url_vector <- unlist(url_list)

length(unique(url_vector))
