#> there are different ways of placing the request
#> this example shows 3 different options

library("httr2")

# Example 1 ----
#> example query, starting from https://api.kivaws.org/graphql
#> if I hit 'prettify' in the browser I can copy the url and then use it here
V1_get_url <-
    "https://api.kivaws.org/graphql?query=%7B%0A%20%20lend%20%7B%0A%20%20%20%20loan(id%3A%202758168)%20%7B%0A%20%20%20%20%20%20id%0A%20%20%20%20%20%20description%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D%0A&operationName=null"
# adjust verbosity to what you prefer
V1_response <-
    httr2::req_perform(req = httr2::request(base_url = V1_get_url),
                       verbosity = 1)
# print headers and the response body
V1_response |>
    httr2::resp_raw()
# check status code
V1_response |>
    httr2::resp_status()
# check status code meaning
V1_response |>
    httr2::resp_status_desc()
# see the body, use _json because that matches the type of the response
# use str to visualize it better
V1_response |>
    httr2::resp_body_json() |>
    str()
V1_content <- V1_response |>
    httr2::resp_body_json()
V1_content
V1_content |>
    str()

# Example 2 ----
#> I can start from https://api.kivaws.org/graphql to test the query and
#> see how it works
#> then, I can modify the code and execute directly in R
#> this makes it possible to have reproducible results that I can share with
#> others, and possible to modify the code
V2_get_url <- "https://api.kivaws.org/graphql"
V2_response <-
    httr2::req_perform(
        req = httr2::request(base_url = V2_get_url) |>
            req_url_query(query = "{
                                    lend {
                                            loan(id: 2758168) {
                                                id
                                                description
                                            }
                                        }
                                    }"),
        verbosity = 1
    )
# print headers and the response body
V2_response |>
    httr2::resp_raw()
# check status code
V2_response |>
    httr2::resp_status()
# check status code meaning
V2_response |>
    httr2::resp_status_desc()
# see the body, use _json because that matches the type of the response
# use str to visualize it better
V2_response |>
    httr2::resp_body_json() |>
    str()
V2_content <- V2_response |>
    httr2::resp_body_json()
V2_content
V2_content |>
    str()

# Example 3 ----
#> similar to example 2, but this time I read the target loan id from an R obj
#> this is useful when looping over multiple ids
V3_target_id <- 2758168
V3_get_url <- "https://api.kivaws.org/graphql"
V3_response <-
    httr2::req_perform(
        req = httr2::request(base_url = V3_get_url) |>
            req_url_query(
                query = glue::glue("{{
                                     lend {{
                                            loan(id: {V3_target_id}) {{
                                                id
                                                description
                                            }}
                                     }}
                                   }}")
            ),
        verbosity = 1
    )
# print headers and the response body
V3_response |>
    httr2::resp_raw()
# check status code
V3_response |>
    httr2::resp_status()
# check status code meaning
V3_response |>
    httr2::resp_status_desc()
# see the body, use _json because that matches the type of the response
# use str to visualize it better
V3_response |>
    httr2::resp_body_json() |>
    str()
V3_content <- V3_response |>
    httr2::resp_body_json()
V3_content
V3_content |>
    str()
