# ADF_public

Public repo for Analyzing Digital Footprints (course in the BAM MSc, RSM)

Files included in this repo:

- `aux_functions.R` contains:
  
  - `f_test_API`: you can use this function to test your connection to the Twitter API
  
  - `f_get...`: helper functions that you can use to extract specific fields from the response object

- `aux_objects.R` contains: objects with available fields and expansions you can use to request additional data from the API. Check the API documentation to see if there are other values you can add.

- `examples\` contains:

  - `how_to_test_your_connection.R` shows how to check if you are able to collect data via the Twitter API
  
  - `steps_to_collect_data.R` shows how to structure the data collection file
  
  - `recent_search`: a detailed example for how to collect data using the recent search endpoint, how to process the response objects, and how to check the output. 
  
  - `user_timeline`: a detailed example for how to collect tweets from a single user, using the timeline endpoint.

