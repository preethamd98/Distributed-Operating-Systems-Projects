a = System.argv()
[a1|t] = a
[a2|_] = t

{n,_} = Integer.parse(a1)
{numRequest,__} = Integer.parse(a2)



defmodule Collector do #Collector is a GenServer for collecting all the hops from the requests
    use GenServer

    def init([list,requests]) do
        {:ok,[list,requests]}
    end

    def handle_call({:add_requests,request},_from,[list,_requests]) do
        {:reply,"Sucessfully inserted",[list,request]}
    end

    def handle_cast({:add_value,value},[list,requests]) do
        l = list++[value]
        if(length(l)==requests) do
            IO.puts "The Max-Number of hops take in the network are: "<>to_string(Enum.max(l))
        end
        {:noreply,[l,requests]}
    end

    def handle_call({:debug},_from,[list,requests]) do
        IO.inspect [list,requests]
        {:reply,"Result",[list,requests]}
    end


    def add_requests(pid,number) do
        GenServer.call(pid,{:add_requests,number})
    end

    def add_value(pid,value) do
        GenServer.cast(pid,{:add_value,value})
    end

    def debug(pid) do
        GenServer.cast(pid,{:debug})
    end

end

defmodule SString do #Till what index are they matching
    def whereMatch(s1,s2) do 
        if(s1==s2) do
            l = String.length(s1)-1
            l
        else
        index = helper(s1,s2,0)
        index
        end
    end
    def helper(s1,s2,num) do
        if num==String.length(s1)-1 and String.at(s1,num)==String.at(s2,num)do
                num
        end
        if String.at(s1,num)==String.at(s2,num) do
            helper(s1,s2,num+1)
        else
            num
        end
    end
end

#Inserting in to the hashtable
defmodule HTInsert do
    def put(ht,i,j,val) do
         l = Enum.at(ht,i)
         l = List.replace_at(l, j, val)
         ht = List.replace_at(ht, i, l)
         ht
    end
    def put2(routingTable,i,j,id,newNode) do
        l = Enum.at(routingTable,i)
        val = Enum.at(l,j) 
        {a,_} = Integer.parse(Atom.to_string(newNode),16)
        {b,_} = Integer.parse(Atom.to_string(id),16)
        if val==0 do
            HTInsert.put(routingTable,i,j,newNode)
        else 
        {c,_} = Integer.parse(Atom.to_string(val),16)
        comp = (a-b)<(c-b)
             if(comp==true) do
                 HTInsert.put(routingTable,i,j,newNode)
             else
                 routingTable
             end
     end
     end

    def put_list(ht,id,list) do
    if length(list)!=0 do
        [value|tail] = list
        matchIndex = SString.whereMatch(Atom.to_string(id),Atom.to_string(value))
        i = matchIndex
        {j,_} = Integer.parse(String.at(Atom.to_string(value),i),16) #Integer.parse("C0", 16)
        ht = put2(ht,i,j,id,value)
        put_list(ht,id,tail)
    else
        ht
    end
    end
    def fill_firstrow(ht,id,list) do
        if(length(list)!=0) do
            [value|tail] = list
            matchIndex = SString.whereMatch(Atom.to_string(id),Atom.to_string(value))
            if(matchIndex==0) do
                i = matchIndex
                {j,_} = Integer.parse(String.at(Atom.to_string(value),i),16)
                ht = put(ht,i,j,value)
            end
            put_list(ht,id,tail)
        else
            ht
        end
    end

    def put_listindex(ht,id,index,list) do
     if length(list)!=0 do
        [value|tail] = list
        matchIndex = SString.whereMatch(Atom.to_string(id),Atom.to_string(value))
        i = matchIndex
        if(matchIndex>index) do
        {j,_} = Integer.parse(String.at(Atom.to_string(value),i),16) #Integer.parse("C0", 16)
        ht = put(ht,i,j,value)
        end
        put_listindex(ht,id,index,tail)
    else
        ht
    end
end

    def put_element(ht,id,value) do #Value is the new to be added
        i = SString.whereMatch(Atom.to_string(id),Atom.to_string(value))
        {j,_} = Integer.parse(String.at(Atom.to_string(value),i),16) #Integer.parse("C0", 16)
        ht = put(ht,i,j,value)
        ht
    end
    def copy_rows(ht1,ht2,i,j) do #ht1 source ht2 destination
        if(i<=j) do
         l = Enum.at(ht1,i)
         ht2 = List.replace_at(ht2, i, l)
         copy_rows(ht1,ht2,i+1,j)
        else
        ht2
        end
    end

end

defmodule Nodes do
    use GenServer 
    def init([id,routingTable,collectorId]) do
         {:ok, [id,routingTable,collectorId]}
    end
   

    def handle_call({:get_rt},_from,[id,routingTable,collectorId]) do
        {:reply,routingTable,[id,routingTable,collectorId]}
    end

    def handle_cast({:set_rt,newRT},[id,routingTable,collectorId]) do
        {:noreply,[id,newRT]}
    end
    


#TODO : Repair the populate function
    def handle_call({:populate,list},_from,[id,routingTable,collectorId]) do #Populating the hashtable 
        list = Enum.filter(list, fn x-> x !=id end) #remove the self() from the list
        
        routingTable = HTInsert.put_list(routingTable,id,list)
        {:reply,"Insert Has been done",[id,routingTable,collectorId]}
    end

    def handle_cast({:addme,newNode},[id,routingTable,collectorId]) do #Adding a single node into a routing table
        routingTable = HTInsert.put_element(routingTable,id,newNode)
        {:noreply,[id,routingTable,collectorId]}
    end

    #To Copying from 20% to 80%
    def handle_call({:copy_o,newid},_from,[id,routingTable,collectorId]) do   
        routingTable = HTInsert.put_element(routingTable,id,newid)
        {:reply,"Added the node",[id,routingTable,collectorId]}
    end

    #To Copy from 80% to 20%
    def handle_call({:copy_t,newid},_from,[id,routingTable,collectorId]) do  #new_id is the table from which you want to copy #new_id is a string    
        #copy_o(Process.whereis(id),newid)
        from_table = get_rt(Process.whereis(newid))
        j = SString.whereMatch(Atom.to_string(newid),Atom.to_string(id))
        routingTable = HTInsert.copy_rows(from_table,routingTable,1,j)
        {:reply,"Routing table has been updated",[id,routingTable,collectorId]}
    end

    def handle_cast({:passmessage,source,destination,value},[id,routingTable,collectorId]) do #value is the message counter
        if(id==destination) do
            Collector.add_value(collectorId,value)
            #IO.puts "Final has been received to "<>to_string(destination)<> " number of hops is "<> to_string(value)
        else 
           #IO.puts "Message has been received from " <> to_string(source) <> " number of hops is "<> to_string(value)
            matchIndex = SString.whereMatch(Atom.to_string(id),Atom.to_string(destination))
            i = matchIndex
            {j,_} = Integer.parse(String.at(Atom.to_string(destination),i),16) #Integer.parse("C0", 16)
            l = Enum.at(routingTable,i)
            d = Enum.at(l,j)
            passmessage(Process.whereis(d),d,destination,value+1)
            end
        
            {:noreply,[id,routingTable,collectorId]}
    end

    def handle_call({:replaceme,newNode},_from,[id,routingTable,collectorId]) do #Sending a muticast message to the network
        i = SString.whereMatch(Atom.to_string(id),Atom.to_string(newNode))
        {j,_} = Integer.parse(String.at(Atom.to_string(newNode),i),16)
        routingTable = HTInsert.put2(routingTable,i,j,id,newNode)
        {:reply,"Replacement has been done",[id,routingTable,collectorId]}
    end

    def replaceMe(pid,newNode) do
        GenServer.call(pid,{:replaceme,newNode})
    end

    def passmessage(pid,source,destination,value) do
        GenServer.cast(pid,{:passmessage,source,destination,value})
    end

    def populate(pid,list) do
         GenServer.call(pid,{:populate,list})
    end

    def addMe(pid,newNode) do 
        GenServer.cast(pid,{:addme,newNode})
    end

    def copy_o(pid,newid) do
        GenServer.call(pid,{:copy_o,newid})
    end

    def copy_t(pid,newid) do
        GenServer.call(pid,{:copy_t,newid})
    end

    def get_rt(pid) do
        GenServer.call(pid,{:get_rt})
    end

    def set_rt(pid,ht) do
        GenServer.cast(pid,{:set_rt,ht})
    end

 end

#Initialisation of the routing table
ht = Enum.map(1..6, fn x-> Enum.map(1..16, fn y -> 0 end) end)
iDs = Enum.map(1..n*10,fn x-> :crypto.hash(:sha,to_string(x))|>Base.encode16()|>String.downcase()|>String.slice(0..5)|>String.to_atom() end)|> Enum.uniq() |> Enum.take(n) # Creation of a 6bit hash id atom's 
#Creation of collector genserver
{:ok,collectorId} = GenServer.start_link(Collector,[[],Kernel.trunc(n*numRequest)])

#Creation of Processes and registering the processes 
Enum.each(1..n, fn x-> {:ok, pid} = GenServer.start_link(Nodes, [Enum.at(iDs,x-1),ht,collectorId]);Process.register(pid, Enum.at(iDs,x-1)) end) 

#Division of the lists into two parts
[network|[toBeAdded|_]] = Enum.chunk_every(iDs,n-1)
temp_network = network
toBeAdded = List.flatten(toBeAdded)
#For populating all the elements
#Enum.each(1..80,fn x-> Nodes.populate(Process.whereis(Enum.at(iDs,x-1)),network) end)
IO.puts "Forming a Static Network"
Enum.each(1..n-1,fn x-> Nodes.populate(Process.whereis(Enum.at(iDs,x-1)),network) end)
IO.puts "Adding the node dynamically"
Enum.each(1..n-1,fn x-> Nodes.replaceMe(Process.whereis(Enum.at(iDs,x-1)),Enum.at(toBeAdded,0)) end)


#Dynamic Join
IO.puts "Multicast message has been sent"
toBeAdded = List.flatten(toBeAdded)
Nodes.populate(Process.whereis(Enum.at(toBeAdded,0)),network)
IO.puts "Dynamic join has been done"

#invoking requests
Enum.each(iDs, fn x->
        list = Enum.take_random(Enum.filter(iDs, fn y-> y !=x end),10)
        Enum.each(list,fn y-> Nodes.passmessage(Process.whereis(x),x,y,0) end)
end)

:timer.sleep(1000)



