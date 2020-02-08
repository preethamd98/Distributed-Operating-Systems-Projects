COP5615 Twitter Clone Project 4.2

Team Members:
Preetham Dasari (UFID:69698425)
Tharshith Gandi (UFID:43007097)

Instructions to run the Program

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Things which have been implemented and working:

-> login
-> Register 
-> Tweet
-> Retweet
-> hashtag, mention search 

Approach:

-> This project is mainly intended to provide a frontend to project 4.1 which is implemented using pheonix channels and javascript
-> An ets table which consists of mapping from pids of the clients to channel id's
-> The newly created ets table is utilised in the old code so that distribution of tweets and queries of hashtags and mentions can be sent to channels.
-> This code has been tested for 100 users and all the features works without consuming much memory as actor models are very light weighted.
-> Several improvements can be made like creating UI using frameworks like react and using a databases for storing tweets and users.

Video Link:
https://youtu.be/G5GoghOXW3Q
