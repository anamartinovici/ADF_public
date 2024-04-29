#> this shows how I tested and developed the code used in `collect_data.R` 
#> (same directory)

# go to kiva, filter for a category with less than 50 results
# query and get number of results
# query and get all results
# query and get first 5, and next 5 to practice using offset

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

length(content_allresults)
names(content_allresults)

length(content_allresults[["data"]])
names(content_allresults[["data"]])

length(content_allresults[["data"]][["lend"]])
names(content_allresults[["data"]][["lend"]])

length(content_allresults[["data"]][["lend"]][["loans"]])
names(content_allresults[["data"]][["lend"]][["loans"]])

content_allresults[["data"]][["lend"]][["loans"]][["totalCount"]]
length(content_allresults[["data"]][["lend"]][["loans"]][["values"]])
names(content_allresults[["data"]][["lend"]][["loans"]][["values"]])
content_allresults[["data"]][["lend"]][["loans"]][["values"]][[1]]
content_allresults[["data"]][["lend"]][["loans"]][["values"]][[1]][["id"]]
content_allresults[["data"]][["lend"]][["loans"]][["values"]][[5]][["id"]]
content_allresults[["data"]][["lend"]][["loans"]][["values"]][[6]][["id"]]
content_allresults[["data"]][["lend"]][["loans"]][["values"]][[10]][["id"]]

# query and get first 5
content_allresults[["data"]][["lend"]][["loans"]][["values"]][[1]][["id"]]
content_allresults[["data"]][["lend"]][["loans"]][["values"]][[5]][["id"]]
# query and loop until I get all results
response_1to5 <- 
    httr2::req_perform(
        req = httr2::request(base_url = get_url) |>
            httr2::req_url_query(
                query = '{
                            lend {
                                loans (limit: 5,
                                        filters: {country: ["MD"]},
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
# check status code meaning
response_1to5 |>
    httr2::resp_status_desc()
response_1to5 |>
    httr2::resp_body_json() |>
    str()
content_1to5 <- response_1to5 |>
    httr2::resp_body_json()
content_allresults[["data"]][["lend"]][["loans"]][["values"]][[1]][["id"]]
content_1to5[["data"]][["lend"]][["loans"]][["values"]][[1]][["id"]]

content_allresults[["data"]][["lend"]][["loans"]][["values"]][[5]][["id"]]
content_1to5[["data"]][["lend"]][["loans"]][["values"]][[5]][["id"]]

# next 5
response_6to10 <- 
    httr2::req_perform(
        req = httr2::request(base_url = get_url) |>
            httr2::req_url_query(
                query = '{
                            lend {
                                loans (offset: 5,
                                        limit: 5,
                                        filters: {country: ["MD"]},
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

# check status code meaning
response_6to10 |>
    httr2::resp_status_desc()
content_6to10 <- response_6to10 |>
    httr2::resp_body_json()
content_allresults[["data"]][["lend"]][["loans"]][["values"]][[6]][["id"]]
content_6to10[["data"]][["lend"]][["loans"]][["values"]][[1]][["id"]]

content_allresults[["data"]][["lend"]][["loans"]][["values"]][[10]][["id"]]
content_6to10[["data"]][["lend"]][["loans"]][["values"]][[5]][["id"]]

