# Twitter Mentions

This is a command line application which searches Twitter for a given number of tweets that mention a given username.

To run the application, execute the following in a terminal:
```
$ ./search_tweets.rb <username> <count> 
```
Notes:
- The application requires two files to be present in its directory, called `access_token` and `consumer_key`, which can be generated at https://apps.twitter.com/.
- if the application is run without arguments, it will ask the user to provide the username and return 5 tweets by default.
