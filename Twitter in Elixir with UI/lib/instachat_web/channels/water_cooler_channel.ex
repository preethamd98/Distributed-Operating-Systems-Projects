defmodule InstachatWeb.WaterCoolerChannel do
  use InstachatWeb, :channel

  def join("water_cooler:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("login",payload,socket) do
    name = Map.get(payload,"name")
        
    if length(TwitterEngine.find(name))==0 do
          payload = %{"status"=>0}
          push socket,"login",payload
    else
        client = :global.whereis_name(String.to_atom(name))
        Client.login(client)
        :ets.insert(:cidtopid,{String.to_atom(name),self()})
        temp = :ets.lookup(:cidtopid,String.to_atom(name))
        [temp|_] = temp 
        IO.inspect temp
        IO.inspect self()
        payload = %{"status"=>1}
        push socket,"login",payload
    end
    {:noreply,socket}

  end

  def handle_in("subscribe",payload,socket) do
    name = Map.get(payload,"name")
    subscriber = Map.get(payload,"subscriber")
    if length(TwitterEngine.find(name))==0 do
          payload = %{"status"=>1}
          push socket,"subscribe",payload
    else
        Client.follow(:global.whereis_name(String.to_atom(name)),subscriber)
        payload = %{"status"=>0}
        push socket,"subscribe",payload
    end
    :timer.sleep(1000)
    temp = :ets.lookup(:users,name)
    IO.inspect temp
    temp = :ets.lookup(:users,subscriber)
    IO.inspect temp
    tt = :global.whereis_name(String.to_atom(name))
    IO.inspect tt
    nn = :global.whereis_name(String.to_atom(subscriber))
    IO.inspect nn

    {:noreply,socket}
  end

def handle_in("retweet",payload,socket) do
  nn = :global.whereis_name(:twitter)
  name = Map.get(payload,"name")
  id = Map.get(payload,"retweetid")|>String.to_integer()
  # Client.retweet2(:global.whereis_name(String.to_atom(name)),id)
  [temp|_] = :ets.lookup(:tweets,id)
  temp = temp|>Tuple.to_list()
  temp = Enum.at(temp,1)
  temp = temp<>" -rt"
  Client.tweet(:global.whereis_name(String.to_atom(name)),temp)

  IO.inspect temp
  
  {:noreply,socket}

end







def handle_in("test",_payload,socket) do
  nn = :global.whereis_name(:twitter)
  t = TwitterEngine.get_ca_users(nn)
  m = Enum.map(t, fn x-> Process.alive?(:global.whereis_name(String.to_atom(x))) end)
  IO.inspect nn
  IO.inspect t
  IO.inspect m
  {:noreply,socket}

end

def handle_in("hashtags",payload,socket) do
  query = Map.get(payload,"query")
  nn = :global.whereis_name(:twitter)
  query_result = TwitterEngine.query_hashtags(nn,query)
  IO.inspect query_result
  push socket,"hashtags",%{query: query_result}
  {:noreply,socket}
end


def handle_in("mentions",payload,socket) do
  query = Map.get(payload,"query")
  nn = :global.whereis_name(:twitter)
  query_result = TwitterEngine.query_mentions(nn,query)
  IO.inspect query_result
  push socket,"mentions",%{query: query_result}
  {:noreply,socket}
end










  def handle_in("register",payload,socket) do
    name = Map.get(payload,"name")
    
    if length(TwitterEngine.find(name))==0 do
          Tester.register(name)
          payload = %{"status"=>1}
          push socket,"register",payload
    else
        payload = %{"status"=>0}
        push socket,"register",payload
    end

    {:noreply,socket}
  end


  def handle_in("tweet",payload,socket) do
    name = Map.get(payload,"name")
    tweet = Map.get(payload,"tweet")
    Client.tweet(:global.whereis_name(String.to_atom(name)),tweet)
    {:noreply,socket}
  end



      def handle_info({:feed, userId, tweet, tweet_id}, socket) do
        res = userId <> " tweeted: '#{tweet}'. You can use id " <> Integer.to_string(tweet_id) <> " to retweet"
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
      end



end
