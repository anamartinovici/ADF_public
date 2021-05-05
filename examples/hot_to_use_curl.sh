############################
#
# how to place one simple request to user endpoint
curl --request GET \
--url 'https://api.twitter.com/2/users/by?usernames=Ana_Martinovici' \
--header "Authorization: Bearer ${BEARER_TOKEN}"

# if you want to save the output, you can write it to a file
# how to place one simple request to the tweet search endpoint
curl --request GET \
--url 'https://api.twitter.com/2/users/by?usernames=Ana_Martinovici' \
--header "Authorization: Bearer ${BEARER_TOKEN}" >> examples/example_curl.json


############################
#
# how to use the filtered stream endpoint
# this gives my all the replies in real time, but not the historic replies
#

# how to add a rule, to be used for the filtered stream
curl -X POST 'https://api.twitter.com/2/tweets/search/stream/rules' \
-H "Content-type: application/json" \
-H "Authorization: Bearer ${BEARER_TOKEN}" -d \
'{
  "add": [
    {"value": "#CatsOfTwitter", "tag": "rule to get cat tweets"}
  ]
}'

# check what rules there are 
curl -X GET 'https://api.twitter.com/2/tweets/search/stream/rules' \
-H "Authorization: Bearer ${BEARER_TOKEN}" 

# connect to the stream API to get data that matches the rule you've just set
curl -X GET -H "Authorization: Bearer ${BEARER_TOKEN}" "https://api.twitter.com/2/tweets/search/stream?tweet.fields=in_reply_to_user_id,author_id,created_at,conversation_id&expansions=author_id"
# use CTRL+C to stop the stream

# delete the rule - you need to use the correct id associated with the rules you have
curl -X POST 'https://api.twitter.com/2/tweets/search/stream/rules' \
-H "Content-type: application/json" \
-H "Authorization: Bearer ${BEARER_TOKEN}" -d \
'{
  "delete": {
    "ids": [
        "1389939137831227402"
    ]   
  }
}'

# check what rules there are
curl -X GET 'https://api.twitter.com/2/tweets/search/stream/rules' \
-H "Authorization: Bearer ${BEARER_TOKEN}" 
