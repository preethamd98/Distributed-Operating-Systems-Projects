a = System.argv()
[a1|t] = a
[a2|_] = t

{n1,_} = Integer.parse(a1)
{n2,__} = Integer.parse(a2)


defmodule VampireBoss do
  use GenServer

  #Server - Code

  def start_link() do
    GenServer.start_link(__MODULE__ ,[])
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:result,value},state) do
     # Aggregating values in a list which are satisfied by the vampire number property
    {:noreply, [value | state]}
  end

  def handle_call(:result,_from,state) do
    # Calling the server to find the consoldiated list of values satisfying requirement
    {:reply,state,state}
  end

  #Client - side

  def vampireGenerator(n1,n2) do
    # Start the server and get its process id
    {:ok,pid}=VampireBoss.start_link
    # This method is used for spawning multiple processes where batch size of each process is 1/8th root of n
    spawnProcesses(n1,n2,pid)
 

    l = GenServer.call(pid,:result) 
    l = Enum.reject(l,fn x->String.length(x)==0 end)
     Enum.each(l,fn x-> IO.puts x end)

  end

  def spawnProcesses(n1,n2,pid) do
    batch = Kernel.trunc((n2-n1)*0.05)
    list = Enum.chunk_every(n1..n2,batch)
    tasks =
      Enum.map(list, fn x->
         Task.async(fn ->
          Vampire.task(x,pid)
          end) end)
    Enum.map(tasks, &Task.await/1) #It waits for the tasks to get completed 
  end
end

defmodule Vampire do
  def factor_pairs(n) do
    f = trunc(n / :math.pow(10, div(char_len(n), 2)))
    l = :math.sqrt(n) |> round
    for i <- f .. l, rem(n, i) == 0, do: {i, div(n, i)}
  end
 
  def vampire_factors(n) do
    if rem(char_len(n), 2) == 1 do
      []
    else
      half = div(length(to_charlist(n)), 2)
      sorted = Enum.sort(String.codepoints("#{n}"))
      Enum.filter(factor_pairs(n), fn {a, b} ->
        char_len(a) == half && char_len(b) == half &&
        Enum.count([a, b], fn x -> rem(x, 10) == 0 end) != 2 &&
        Enum.sort(String.codepoints("#{a}#{b}")) == sorted
      end)
    end
  end
 
  defp char_len(n), do: length(to_charlist(n))
 
  def task(l,pid) do
    pair = &Tuple.to_list/1
    s = Enum.map(l, fn n ->
      case vampire_factors(n) do
        vf -> 
        if(length(vf)!=0) do
        _pair = &Tuple.to_list/1
        l = Enum.map(vf,fn x-> pair.(x) end)
        l = List.flatten(l)
        l = Enum.join(l," ")
         [" #{n}"<>" #{l}"]
        else
        []
        end
      end
    end)|>Enum.reject(fn x->x==nil or x==[] end)|>Enum.join("")
    GenServer.cast(pid,{:result,s})
  end
end

VampireBoss.vampireGenerator(n1,n2)

