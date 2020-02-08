defmodule Topology do

def sender(list,topo) do
    case topo do
    :full ->
    l = Enum.map(list, fn x-> [x,Enum.filter(list, fn y -> y != x end )] end)
    Enum.each(l, fn x -> [id,list] = x ; GenServer.call(id, {:neighbours, list}) end)
    :line ->
        l = Topologies_Gen.line(list)
        Enum.each(l, fn x -> [id,list] = x ; GenServer.call(id, {:neighbours, list}) end)
    :randomgrid -> 
        l = Topologies_Gen.grid_gen(list)
        Enum.each(l, fn x -> [id,list] = x ; GenServer.call(id, {:neighbours, list++[id]}) end)
    :torus -> 
        l = Topologies_Gen.build3DTorus(list)
        Enum.each(l, fn x -> [id,list] = x ; GenServer.call(id, {:neighbours, list}) end)
    :honeycomb ->
        l = Topologies_Gen.buildHoneyComb(list)
        Enum.each(l, fn x -> [id,list] = x ; GenServer.call(id, {:neighbours, list}) end)
    :honeycombrn -> 
        l = Topologies_Gen.buildHoneyCombRN(list)
        Enum.each(l, fn x -> [id,list] = x ; GenServer.call(id, {:neighbours, list}) end)
    
    end
    :ok
end





    
    def create(num, topo, algo) do
        #1 spawn processes
        #2 send info of neighbors to each process spawned before
        
        num = 
            case topo do
                "full" -> num
                "line" -> num
                "3Dtorus" -> num
                "rand2D" -> num
                "honeycomb" -> num
                "randhoneycomb" -> num 
                _ -> raise "Not supported"     
            end
        
        list = 
            case algo do
                "gossip" -> 1..num |> Enum.map(fn _ -> elem(GenServer.start_link(Gossiper, []), 1) end)
                "push-sum" -> 1..num |> Enum.map(fn i -> elem(GenServer.start_link(Adder, i), 1) end) #i = s
                _ -> raise "Not supported"
            end

        case topo do
            #"full" -> :ok = send_data(list, 0, num, :full)
            "full" -> :ok = sender(list,:full)
            "line" -> :ok = sender(list,:line)
            "3Dtorus" -> :ok = sender(list,:torus)
            "rand2D" -> :ok = sender(list,:randomgrid)
            "honeycomb" -> :ok = sender(list,:honeycomb)
            "randhoneycomb" -> :ok = sender(list,:honeycombrn)


            
        end
        {list, num}
    end
end




defmodule Topologies_Gen do
    def line(a) do
    l = length(a)
    Enum.map(0..l-1,fn x->x
        cond do
        x==0 -> 
        t1 = Enum.at(a,x)
        t2 = Enum.at(a,x+1)
        [t1]++[[t2]]
        x==length(a)-1 ->
        t1 = Enum.at(a,x-1)#(n-1)th element
        t2 = Enum.at(a,x)#nth element 
         [t2]++[[t1]]
        true -> 
        t1 = Enum.at(a,x-1)#(n-1)th element
        t2 = Enum.at(a,x)#nth element 
        t3 = Enum.at(a,x+1)#(n+1)th element
        [t2]++[[t1]++[t3]]
        end
        end)
    end
    def grid(a,n,c) do
            if(c==n) do
                a
            else
                x = :rand.uniform()|>Float.round(5)
                y = :rand.uniform()|>Float.round(5)
                a = a ++ [[c+1]++[[x,y]]]
                grid(a,n,c+1)
            end
        end
        def grid_gen(processes) do
            n = length(processes) 
            g = grid([],n,0)
            m = Enum.map(g, fn x->
                temp = Enum.filter(g, fn y-> y != x end)
                neighbour = [Enum.at(x,0)]
                temp2 = Enum.map(temp, fn y-> 
                x1 = Enum.at(y,1)
                x2 = Enum.at(x,1)
                if(Distance.euclid(x1,x2)<=0.01) do
                    Enum.at(y,0)
                    end
                end)
                neighbour ++ [Enum.filter(temp2, fn x-> x !=nil end)] 
            end)
            l = length(m)
            t = Enum.map(0..l-1, fn x-> 
                [id,list] = Enum.at(m,x)
                list_len = length(list)
                if(list_len>0) do
                ll = Enum.map(0..list_len-1, fn y->
                    a = Enum.at(list,y)
                end)
                [Enum.at(processes,id-1),ll]
                else
                [Enum.at(processes,id-1),[]]
                end
                end)
        t
    
        end
        def build3DTorus(allNodes) do #Taking input as pids
          # list = allNodes
          ncount = length(allNodes)
          rowNodeCount = round(Float.ceil(:math.pow(ncount,(1/3))))
          #plainNodeCount = round(Float.ceil(:math.pow(numofNodes,(2/3)))
          planeNodeCount = round(:math.pow(rowNodeCount,2))
    
          numofNodes = rowNodeCount * rowNodeCount * rowNodeCount
    
           list = Enum.map(1..numofNodes, fn x->
    
           positiveX = if(x+1 <= numofNodes && rem(x,rowNodeCount) != 0 ) do x+1 else x-rowNodeCount+1 end
           negativeX = if(x-1 >= 1 && rem(x-1,rowNodeCount) != 0) do x-1 else x+rowNodeCount-1 end
           positiveY = if(rem(x,planeNodeCount) != 0 && planeNodeCount - rowNodeCount >= rem(x,(planeNodeCount))) do x+ rowNodeCount else x-planeNodeCount+rowNodeCount end
           negativeY = if((planeNodeCount - rowNodeCount*(rowNodeCount-1)) < rem(x-1,(planeNodeCount)) + 1) do x- rowNodeCount else x+planeNodeCount-rowNodeCount end
           positiveZ = if(x+ planeNodeCount <= numofNodes) do x+ planeNodeCount else x - planeNodeCount*(rowNodeCount-1) end
           negativeZ = if(x- planeNodeCount >= 1) do x- planeNodeCount else x + planeNodeCount*(rowNodeCount-1) end
    
    
           # neighbour = [positiveX,negativeX,positiveY,negativeY,positiveZ,negativeZ]
    
           neighbour = [
             Enum.at(allNodes, positiveX-1) ,
             Enum.at(allNodes, negativeX-1) ,
             Enum.at(allNodes, positiveY-1) ,
             Enum.at(allNodes, negativeY-1) ,
             Enum.at(allNodes, positiveZ-1) ,
             Enum.at(allNodes, negativeZ-1) ]
    
           neighbour = Enum.filter( neighbour, fn x -> x != nil end )
            # Enum.at(allNodes, x) end end)
           # some=Enum.reject( neighbour,&is_nil/1)
           end)
    
          Enum.map( 1..ncount, fn x ->
            [Enum.at(allNodes, x-1) ,Enum.at(list, x-1)]
            # IO.inspect x
            # IO.inspect Enum.at(list,x-1)
          end)
    
        end
    
    #HoneyComb
    
    
     def buildHoneyComb(allNodes) do
          ncount = Enum.count(allNodes)
          w = Kernel.trunc(:math.floor( :math.pow( ncount, 1/2) ) )
          Enum.map( 1..ncount, fn x ->
          row_num = Kernel.trunc(:math.floor((x-0.1)/w))
                cond do
                  rem(row_num,2) == 0 ->
                    cond do
                      rem(x,2) == 0 ->
                        n1 = x-1
                        n2 = x+w
                        n3 = x-w
                        neigh_list = [ n1, n2, n3 ]
    
                        neigh_list = Enum.filter( neigh_list, fn x -> x > 0 && x <= ncount end )
                        neigh_list = Enum.map( neigh_list, fn x -> Enum.at(allNodes, x-1) end)
                        [Enum.at(allNodes, x-1) ,neigh_list]
                        #GenServer.call( Enum.at(allNodes, x-1) , {:neighbor_list, neigh_list })
    
                       rem(x,2) == 1 ->
                         n1 = x+1
                         n2 = x+w
                         n3 = x-w
                         neigh_list = [ n1, n2, n3 ]
    
                         neigh_list = Enum.filter( neigh_list, fn x -> x > 0 && x <= ncount end )
                         neigh_list = Enum.map( neigh_list, fn x -> Enum.at(allNodes, x-1) end)
                        [Enum.at(allNodes, x-1) ,neigh_list]
    
                    end
                  rem(row_num,2) == 1 ->
                    cond do
                      rem(x,2) == 0 ->
                        n1 = if ( rem( x , w) != 0 ) do x+1 end
                        # n1 = x+1
                        n2 = x+w
                        n3 = x-w
                        neigh_list = [ n1, n2, n3 ]
    
                        neigh_list = Enum.filter( neigh_list, fn x -> x > 0 && x <= ncount end )
                        neigh_list = Enum.map( neigh_list, fn x -> Enum.at(allNodes, x-1) end)
                        [Enum.at(allNodes, x-1) ,neigh_list]
                      rem(x,2) == 1 ->
                        n1 = if ( rem( (x-1), w) != 0 ) do x-1 end
                        # n1 = x-1
                        n2 = x+w
                        n3 = x-w
                        neigh_list = [ n1, n2, n3 ]
    
                        neigh_list = Enum.filter( neigh_list, fn x -> x > 0 && x <= ncount end )
                        neigh_list = Enum.map( neigh_list, fn x -> Enum.at(allNodes, x-1) end)
                        [Enum.at(allNodes, x-1) ,neigh_list]
                    end
                end
           end )
        end
        
    
    
    #Random HoneyComb
    
        def buildHoneyCombRN(allNodes) do
    
          ncount = Enum.count(allNodes)
          w = Kernel.trunc(:math.floor( :math.pow( ncount, 1/2) ) )
          IO.inspect w
         Enum.map( 1..ncount, fn x ->
            row_num = Kernel.trunc(:math.floor((x-0.1)/w))
                cond do
                  rem(row_num,2) == 0 ->
                    cond do
                      rem(x,2) == 0 ->
                        n1 = x-1
                        n2 = x+w
                        n3 = x-w
                        neigh_list = [ n1, n2, n3 ]
    
                        neigh_list = Enum.filter( neigh_list, fn x -> x > 0 && x <= ncount end )
                        neigh_list = Enum.map( neigh_list, fn x -> Enum.at(allNodes, x-1) end)
                        rand_list = List.delete(allNodes, Enum.at(allNodes, x-1))
                        neigh_list = [Enum.random(rand_list)] ++ neigh_list
                        [Enum.at(allNodes, x-1) ,neigh_list]
                        rem(x,2) == 1 ->
                         n1 = x+1
                         n2 = x+w
                         n3 = x-w
                         neigh_list = [ n1, n2, n3 ]
    
                         neigh_list = Enum.filter( neigh_list, fn x -> x > 0 && x <= ncount end )
                         neigh_list = Enum.map( neigh_list, fn x -> Enum.at(allNodes, x-1) end)
                         rand_list = List.delete(allNodes, Enum.at(allNodes, x-1))
                         neigh_list = [Enum.random(rand_list)] ++ neigh_list
                         [Enum.at(allNodes, x-1) ,neigh_list]
                    end
                  rem(row_num,2) == 1 ->
                    cond do
                      rem(x,2) == 0 ->
                        n1 = if ( rem( x , w) != 0 ) do x+1 end
                        # n1 = x+1
                        n2 = x+w
                        n3 = x-w
                        neigh_list = [ n1, n2, n3 ]
    
                        neigh_list = Enum.filter( neigh_list, fn x -> x > 0 && x <= ncount end )
                        neigh_list = Enum.map( neigh_list, fn x -> Enum.at(allNodes, x-1) end)
                        rand_list = List.delete(allNodes, Enum.at(allNodes, x-1))
                        neigh_list = [Enum.random(rand_list)] ++ neigh_list
                        [Enum.at(allNodes, x-1) ,neigh_list]
                      rem(x,2) == 1 ->
                        n1 = if ( rem( (x-1), w) != 0 ) do x-1 end
                        # n1 = x-1
                        n2 = x+w
                        n3 = x-w
                        neigh_list = [ n1, n2, n3 ]
    
                        neigh_list = Enum.filter( neigh_list, fn x -> x > 0 && x <= ncount end )
                        neigh_list = Enum.map( neigh_list, fn x -> Enum.at(allNodes, x-1) end)
                        rand_list = List.delete(allNodes, Enum.at(allNodes, x-1))
                        neigh_list = [Enum.random(rand_list)] ++ neigh_list
                        [Enum.at(allNodes, x-1) ,neigh_list]
                    end
                end
           end )
        end
    end

    defmodule Distance do
        def euclid(x,y) do
            x1 = Enum.at(x,0)
            x2 = Enum.at(x,1)
            y1 = Enum.at(y,0)
            y2 = Enum.at(y,1)
            x3 = x2 - x1
            y3 = y2 - y1
            :math.sqrt(x3*x3+y3*y3)
        end
    end