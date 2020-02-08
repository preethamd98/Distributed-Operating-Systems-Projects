defmodule TwitterEngine do
  use GenServer

  def init([]) do
      users = :ets.new(:users,[:set,:public,:named_table])
      mentions = :ets.new(:mentions,[:bag,:public,:named_table])
      hashtags = :ets.new(:hashtags,[:bag,:public,:named_table])
      tweets = :ets.new(:tweets,[:bag,:public,:named_table])
      IO.inspect "GenSever created"
      {:ok,[]}
  end

  #insert service 

  def handle_call({:insert,name},_from,active_users) do
      :ets.insert(:users,{name,{},{},{}}) # {user_name, tweets, followers}
      {:reply,"insert_done",active_users} 
  end

  def create_user(pid,name) do
      if length(find(name))==0 do
          GenServer.call(pid,{:insert,name}) 
      else
          "Please try out with a different name as a user with this name already exists."
      end
      
  end



  #Find user service

  def handle_call({:get,name},_from,active_users) do
      a = :ets.lookup(:users,name)
      {:reply,"get_operation",active_users} 
  end
  
  def get_user(pid,name) do 
      GenServer.call(pid,{:get,name})
  end

  def handle_cast({:addfollower,user,follower},active_users) do
      [h|t] = :ets.lookup(:users,user)
       h = Tuple.to_list(h)     #["Preetham", {}]
      [h|t] = h
      [t1|t2] = t
      [t2|_] = t2
      t2 = Tuple.to_list(t2)++[follower]
      t2 = List.to_tuple(t2)
      :ets.update_element(:users, user, {3, t2})
      #Update the follower table
      [h|t] = :ets.lookup(:users,follower)
      h = Tuple.to_list(h)
      l = Enum.at(h,3)
      l = Tuple.to_list(l)
      l = l++[user]
      l = List.to_tuple(l)
      :ets.update_element(:users, follower, {4,l})
      {:noreply,active_users}
  end


  def add_follower(pid,user,follower) do
      GenServer.cast(pid,{:addfollower,user,follower})
  end



  #Find which can be used for internal purpose

  def find(name) do 
      a = :ets.lookup(:users,name)
  end

  def handle_cast({:login,name},active_users) do
      active_users = active_users++[name]
      IO.puts "User: "<>name<>" has logged in"
      {:noreply,active_users}
  end

  def login(pid,name) do
      GenServer.cast(pid,{:login,name})
  end

  def handle_cast({:logout,name},active_users) do
      IO.puts "User: "<>name<>" has logged out"
      {:noreply,Enum.filter(active_users,fn x-> x != name end)}
  end



  def logout(pid,name) do
      GenServer.cast(pid,{:logout,name})
  end

  def handle_call({:get_ca_users},_from,active_users) do
      {:reply,active_users,active_users} 
  end

  def get_ca_users(pid) do
      GenServer.call(pid,{:get_ca_users})
  end

  def handle_call({:querymentions,query_string},_from,active_users) do
      ret = :ets.lookup(:mentions,query_string)
      ret = Enum.map(ret,fn x-> Enum.at(Tuple.to_list(x),1) end)
      ret = Enum.map(ret, fn x-> x<>"\n" end)
      ret = List.to_string(ret)
      {:reply,ret,active_users}
  end

  def query_mentions(pid,query_string) do
      GenServer.call(pid,{:querymentions,query_string})
  end

  def handle_call({:queryhashtags,query_string},_form,active_users) do
      ret = :ets.lookup(:hashtags,query_string)
      ret = Enum.map(ret,fn x-> Enum.at(Tuple.to_list(x),1) end)
      ret = Enum.map(ret, fn x-> x<>"\n" end)
      ret = List.to_string(ret)
      {:reply,ret,active_users}
  end

  def query_hashtags(pid,query_string) do
      GenServer.call(pid,{:queryhashtags,query_string})
  end

  def handle_call({:logout_all},_from,active_users) do
    {:reply,"everyone has logged-out",[]}
  end

  def logout_all(pid) do
      GenServer.call(pid,{:logout_all})
  end

  def handle_cast({:delete,username},active_users) do
      #delete in the user database
      [h|t] = :ets.lookup(:users,username)
      h = Tuple.to_list(h)
      tids = Tuple.to_list(Enum.at(h,1))
      :ets.delete(:users, username)
      #delete his tweets 
      Enum.each(tids,fn x->:ets.delete(:tweets,x) end)
      #delete in activeusers
      {:noreply,Enum.filter(active_users,fn x-> x != username end)}
      #delete his mentions
      #delete his hashtags
      
  end

  def delete(pid,username) do
      GenServer.cast(pid,{:delete,username})
  end


 def handle_cast({:tweet,tweet,user},active_users) do 
      tweetid = System.unique_integer [:monotonic,:positive]
      :ets.insert(:tweets, {tweetid, tweet})
      [h|t] = :ets.lookup(:users,user)
      h = Tuple.to_list(h)
      [h|t] = h
      [t|_] = t
      t = [tweetid]++Tuple.to_list(t)
      t = List.to_tuple(t)
      :ets.update_element(:users, user, {2, t})
      hashtags = Regex.scan(~r/#[[:alnum:]]+/,tweet)|>List.flatten()
      mentions = Regex.scan(~r/@[[:alnum:]]+/,tweet)|>List.flatten()
      Enum.each(hashtags,fn x->:ets.insert(:hashtags,{x,tweet});end)
      Enum.each(mentions,fn x->:ets.insert(:mentions,{x,tweet});end)

      # Distibute tweets to currently active users and followers of that users
      [h|t] = :ets.lookup(:users,user)
      h = Tuple.to_list(h)
      h = Enum.at(h,2)
      followers = Tuple.to_list(h)

      list3 = active_users -- followers
      final_pids = active_users -- list3

      pids_activeusers = Enum.map(final_pids,fn x -> Process.whereis(String.to_atom(x)) end)
      Enum.each(pids_activeusers,fn x->Client.add_to_timeline(x,tweet) end)
      

      # Send all the tweets to channels
      # Get all the channel ids
      cids = Enum.map(final_pids, fn x-> 
      [x|_] = :ets.lookup(:cidtopid,String.to_atom(x));
      x = Tuple.to_list(x);
      cid = Enum.at(x,1);
      cid
      end
      )
      IO.inspect cids

      Enum.each(cids, fn x ->  send(x, {:feed, user, tweet, tweetid})  end)
      
      {:noreply,active_users}
  end

 def handle_cast({:tweet2,user,id,pid},active_users) do
    ret = :ets.lookup(:tweets,id)
    [ret|_] = ret
    ret = Tuple.to_list(ret)
    tweet = Enum.at(ret,1)
    IO.inspect tweet
    IO.inspect pid
    GenServer.cast(pid,{:tweet,tweet,user})
    {:noreply,active_users}
 end

def tweet(pid,user,tweet) do
      GenServer.cast(pid,{:tweet,tweet,user})
  end

  def tweet2(pid,user,id) do
      GenServer.cast(pid,{:tweet2,user,id,pid})
  end



end