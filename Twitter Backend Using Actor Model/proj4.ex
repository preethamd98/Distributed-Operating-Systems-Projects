a = System.argv()
[a1|t] = a
[a2|_] = t

{nou,_} = Integer.parse(a1)
{notweets,__} = Integer.parse(a2)

{:ok,twitter_engine} = GenServer.start_link(TwitterEngine,[])  

#Tweet DataBase:
{:ok, contents} = File.read("gentweets.txt")
contents = contents |> String.split("\n", trim: true) 

{:ok, usernames} = File.read("usernames.txt")
usernames = usernames |> String.split("\n", trim: true) 
n = 30 # Number of users 
temp = Enum.map(n+1..nou,fn x-> "user"<>Integer.to_string(x) end)
usernames = usernames ++ temp
n = length(usernames)

pids = Enum.map(0..n-1,fn x -> {:ok,client} = GenServer.start_link(Client,[Enum.at(usernames,x),twitter_engine]);Process.register(client, String.to_atom(Enum.at(usernames,x))); client end)
#pids = Enum.map(0..n-1,fn x -> {:ok,client} = GenServer.start_link(Client,[Enum.at(usernames,x),twitter_engine]); Process.register(client, String.to_atom(Enum.at(usernames,x))) client end)
Enum.each(pids,fn x-> Client.register(x) end)
:timer.sleep(100)

Enum.each(0..n-1,
    fn x-> 
    name = Enum.at(usernames,x);
    follower_list = Enum.take_random(usernames,Kernel.round(n/2));
    follower_list = Enum.filter(follower_list,fn y-> y != name end);
    Enum.each(follower_list,fn y-> Client.follow(Enum.at(pids,x),y) end)
    end
)
:timer.sleep(1000)
# Make random number of users online
online_users = Enum.take_random(pids,Kernel.round(n/2));
:timer.sleep(1000)
Enum.each(online_users,fn x-> Client.login(x) end)

#Tweets
Enum.each(0..notweets*nou-1, fn x-> 
    id = Enum.random(pids);
    tweet = Enum.random(contents);
    :timer.sleep(100)
    Client.tweet(id,tweet);
end
    )
# retweet
Enum.each(0..notweets*nou-1, fn x-> 
    id = Enum.random(pids);
    Client.retweet(id);
end
    )






