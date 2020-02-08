defmodule TwitterTest do
  use ExUnit.Case, async: false

  setup_all do
    {:ok,server} = GenServer.start_link(TwitterEngine,[])  
    :global.register_name(:server,server)
    :timer.sleep(20)
  end

  test "User Registration" do #testing if 5 users have been registered or not
    server = :global.whereis_name(:server)
    :timer.sleep(20)
    users = ["user1","user2","user3","user4","user5"]
    Enum.each(0..4,fn x -> {:ok,client} = GenServer.start_link(Client,[Enum.at(users,x),server]); Process.register(client,String.to_atom(Enum.at(users,x))); Client.register(client) end)
    :timer.sleep(100)
    list = Enum.map(users, fn x-> :ets.lookup(:users,x) end)
    :timer.sleep(10)
    assert length(list)==5
  end

  test "Delete Users" do #Insert and delete users 
    server = :global.whereis_name(:server)
    users = ["user6","user7"]
    pids = Enum.map(0..1,fn x -> {:ok,client} = GenServer.start_link(Client,[Enum.at(users,x),server]); client end)
    Enum.each(0..1, fn x-> Process.register(Enum.at(pids,x),String.to_atom(Enum.at(users,x))); Client.register(Enum.at(pids,x)) end)
    Enum.each(pids, fn x-> Client.delete(x) end)
    :timer.sleep(1000)
    list = Enum.map(users, fn x-> :ets.lookup(:users,x) end)
    :timer.sleep(10)
    list = List.flatten(list)
    assert length(list)==0
  end
  
  test "Login Feature" do #If the users are in currently active in the server 
      server = :global.whereis_name(:server)
      users = ["user8","user9"]
      pids = Enum.map(0..1,fn x -> {:ok,client} = GenServer.start_link(Client,[Enum.at(users,x),server]); client end)
      Enum.each(0..1, fn x-> Process.register(Enum.at(pids,x),String.to_atom(Enum.at(users,x))); Client.register(Enum.at(pids,x)) end)
      Enum.each(pids, fn x-> Client.login(x) end)
      :timer.sleep(1000)
      list = TwitterEngine.get_ca_users(server)
      assert users==list or Enum.reverse(users)==list
  end
  test "Logout Feature" do
    server = :global.whereis_name(:server)
    users = ["user10","user11"]
    pids = Enum.map(0..1,fn x -> {:ok,client} = GenServer.start_link(Client,[Enum.at(users,x),server]); client end)
    Enum.each(0..1, fn x-> Process.register(Enum.at(pids,x),String.to_atom(Enum.at(users,x))); Client.register(Enum.at(pids,x)) end)
    Enum.each(pids, fn x-> Client.login(x) end)
    :timer.sleep(1000)
    Enum.each(pids, fn x-> Client.logout(x) end)
    :timer.sleep(1000)
    list = TwitterEngine.get_ca_users(server)
    assert ["user8","user9"]==list or list==["user9","user8"]
  end
  test "Tweet" do
    server = :global.whereis_name(:server)
    users = ["user12"]
    {:ok,client} = GenServer.start_link(Client,[Enum.at(users,0),server]);
    Client.register(client)
    :timer.sleep(100)
    tt = "Hello Twitter!!!"
    Client.tweet(client,tt)
    :timer.sleep(1000)
    [h|_t] = :ets.lookup(:tweets,1)
    h = Tuple.to_list(h)
    assert Enum.at(h,1)==tt
  end
  test "Follower" do
    server = :global.whereis_name(:server)
    users = ["user13","user14","user15","user16"]
    pids = Enum.map(0..3,fn x -> {:ok,client} = GenServer.start_link(Client,[Enum.at(users,x),server]); client end)
    Enum.each(0..3, fn x-> Process.register(Enum.at(pids,x),String.to_atom(Enum.at(users,x))); Client.register(Enum.at(pids,x)) end)
    :timer.sleep(1000)
    [hpid|_] = pids
    [h|t] = users
    Enum.each(t, fn x -> Client.follow(hpid,x) end)
    :timer.sleep(100)
    [hh|_] = :ets.lookup(:users,h)
     hh = Tuple.to_list(hh)
     hh = Tuple.to_list(Enum.at(hh,3))
    assert hh==t
  end
  test "Following" do
    server = :global.whereis_name(:server)
    users = ["user17","user18","user19","user20"]
    pids = Enum.map(0..3,fn x -> {:ok,client} = GenServer.start_link(Client,[Enum.at(users,x),server]); client end)
    Enum.each(0..3, fn x-> Process.register(Enum.at(pids,x),String.to_atom(Enum.at(users,x))); Client.register(Enum.at(pids,x)) end)
    :timer.sleep(1000)
    [_hpid|htails] = pids
    [h|t] = users
    Enum.each(htails,fn x -> Client.follow(x,h) end)
    :timer.sleep(100)
    [hh|_] = :ets.lookup(:users,h)
     hh = Tuple.to_list(hh)
     hh = Tuple.to_list(Enum.at(hh,2))
    assert hh==t
  end
  test "HashTag Query" do
    server = :global.whereis_name(:server)
    users = ["user12"]
    {:ok,client} = GenServer.start_link(Client,[Enum.at(users,0),server]);
    Client.register(client)
    :timer.sleep(100)
    Client.tweet(client,"Hi #Welcome")
    Client.tweet(client,"World #Welcome")
    Client.tweet(client,"Bye #Welcome")
    :timer.sleep(1000)
    list = :ets.lookup(:hashtags,"#Welcome")
    assert length(list)==3
  end
  test "Mention Query" do
    server = :global.whereis_name(:server)
    users = ["user13"]
    {:ok,client} = GenServer.start_link(Client,[Enum.at(users,0),server]);
    Client.register(client)
    :timer.sleep(100)
    Client.tweet(client,"Hi @user1")
    Client.tweet(client,"Bye @user2")
    :timer.sleep(1000)
    list1 = :ets.lookup(:mentions,"@user1")
    list2 = :ets.lookup(:mentions,"@user2")
    a = length(list1)==1 and length(list2)==1
    assert a==true
  end
  test "Active users receiving" do
    server = :global.whereis_name(:server)
    users = ["user17","user18","user19"]
    pids = Enum.map(0..2,fn x -> {:ok,client} = GenServer.start_link(Client,[Enum.at(users,x),server]); client end)
    Enum.each(0..2, fn x-> Process.register(Enum.at(pids,x),String.to_atom(Enum.at(users,x))); Client.register(Enum.at(pids,x)) end)
    :timer.sleep(1000)
    Enum.each(pids, fn x-> Client.login(x) end)
    [hpid|htails] = pids
    [h|t] = users
    Enum.each(htails,fn x -> Client.follow(x,h) end)
    :timer.sleep(100)
    tweet = "Hello online users"
    Client.tweet(hpid,tweet)
    :timer.sleep(100)
    timelines = Enum.map(htails,fn x-> Client.get_timeline(x) end)
    :timer.sleep(100)
    h = Enum.at(timelines,0)
    t = Enum.at(timelines,1)
    assert h == t
 end
 test "Retweet" do
  server = :global.whereis_name(:server)
  TwitterEngine.logout_all(server)
  users = ["user20","user21"]
  pids = Enum.map(0..1,fn x -> {:ok,client} = GenServer.start_link(Client,[Enum.at(users,x),server]); client end)
  Enum.each(0..1, fn x-> Process.register(Enum.at(pids,x),String.to_atom(Enum.at(users,x))); Client.register(Enum.at(pids,x)) end)
  :timer.sleep(1000)
  Enum.each(pids, fn x-> Client.login(x) end)
  u1 = Enum.at(users,0)
  u2 = Enum.at(users,1)
  tweet = "Hello online users"
  Client.follow(Enum.at(pids,0),u2)
  Client.follow(Enum.at(pids,1),u1)
  :timer.sleep(1000)
  Client.tweet(Enum.at(pids,0),tweet)
  :timer.sleep(1000)
  Client.retweet(Enum.at(pids,1))
  :timer.sleep(1000)
  l = Client.get_timeline(Enum.at(pids,0))
  :timer.sleep(1000)
  assert l == [tweet]
 end
 


end



# -> create 5 users and check if the users have been registered or not
# -> delete 5 users and check if they have been deleted or not
# -> login
# -> logout
# -> Tweet
# -> If follower are filled
# -> If following are filled
# -> Active users
# -> Reteet function
