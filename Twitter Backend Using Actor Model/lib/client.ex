
defmodule Client do
  use GenServer
  def init([name,pid]) do        # name, user-timeline, pid--of the twitter engine.
     # TwitterEngine.login(pid,name)
      {:ok,[name,[],pid]}
  end                                 #Client-state -> [name,[],pid]

  def handle_cast({:register},[name,l,pid]) do
      TwitterEngine.create_user(pid,name)
      IO.puts "User: "<>name<>" has been added"
      {:noreply,[name,l,pid]}
  end



  def register(cpid) do 
      GenServer.cast(cpid,{:register})
  end

  def handle_cast({:logout},[name,l,pid]) do
      TwitterEngine.logout(pid,name)
      {:noreply,[name,[],pid]} # When logging out all the tweets are being removed from his time-line
  end

  def logout(cpid) do                   #Here cpid is nothing but the clients pid, pid is the id of the twitter engine
      GenServer.cast(cpid,{:logout})
  end

  def handle_cast({:login},[name,l,pid]) do
      TwitterEngine.login(pid,name)
      IO.puts name<>" has logged in "
      {:noreply,[name,l,pid]}
  end

  def handle_cast({:retweet},[name,l,pid]) do
      if(length(l)>0) do
          text = Enum.random(l)
          IO.puts name<>" retweeted"<>text
          TwitterEngine.tweet(pid,name,text)
      end
      {:noreply,[name,l,pid]}

  end

  def retweet(cpid) do
   GenServer.cast(cpid,{:retweet})
  end

  def delete(cpid) do
      GenServer.cast(cpid,{:delete})
  end

  def handle_cast({:delete},[name,l,pid]) do
      TwitterEngine.delete(pid,name)
      {:noreply,[name,l,pid]}
  end

  def login(cpid) do
      GenServer.cast(cpid,{:login})
  end

  def handle_cast({:addToTimeline,tweet},[name,l,pid]) do
      IO.puts "New tweet is added to the feed "<>tweet
      l = l++[tweet]
      {:noreply,[name,l,pid]}
  end

  def add_to_timeline(pid,tweet) do
      GenServer.cast(pid,{:addToTimeline,tweet})
  end

  def handle_cast({:tweet,tweet_message},[name,l,pid]) do
      TwitterEngine.tweet(pid,name,tweet_message)
      {:noreply,[name,l,pid]}
  end

  def handle_call({:get_timeline},_from,[name,l,pid]) do
      {:reply,l,[name,l,pid]}
  end

  def get_timeline(cpid) do
      GenServer.call(cpid,{:get_timeline})
  end


  def tweet(cpid,tweet_message) do
      GenServer.cast(cpid,{:tweet,tweet_message})
  end

  def handle_cast({:query,query_string},[name,l,pid]) do
      at = Regex.scan(~r/@/,query_string)|>List.flatten()
      htag = Regex.scan(~r/#/,query_string)|>List.flatten()

      t1 = TwitterEngine.query_hashtags(pid,query_string)
      if(String.length(t1)>0) do
          IO.inspect t1
      end
      
      t2 = TwitterEngine.query_mentions(pid,query_string)
      if(String.length(t2)>0) do
          IO.inspect t2
      end

      if(query_string=="subscibed") do

          [h|t] = :ets.lookup(:users,"Preetham")
          h = Tuple.to_list(h) 
          following = Tuple.to_list(Enum.at(h,3))
          Enum.map(following, fn x-> [tweet_ids|t] = :ets.lookup(:users,x);tweet_ids = Tuple.to_list(tweet_ids);
          tweet_ids = Enum.at(tweet_ids,1)
          tweet_ids = Tuple.to_list(tweet_ids)
          t = Enum.map(tweet_ids, fn y-> [tt|t] = :ets.lookup(:tweets,y);tt = Tuple.to_list(tt);Enum.at(tt,1);end) 
          end)
          IO.inspect t
          
      end
      
      
      {:noreply,[name,l,pid]}

  end

  def query(cpid,query_string) do
      GenServer.cast(cpid,{:query,query_string})
  end

  def handle_cast({:follow,person_to_follow},[name,l,pid]) do
      IO.puts name<>" has followed "<>person_to_follow 
      TwitterEngine.add_follower(pid,person_to_follow,name)
      {:noreply,[name,l,pid]}
  end

  def follow(cpid,person_to_follow) do
      GenServer.cast(cpid,{:follow,person_to_follow})
  end



end