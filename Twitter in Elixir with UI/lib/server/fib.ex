defmodule Fib do
    def calculator(n) do
        if(n == 0 or n==1) do
            1
        else
            n+calculator(n-1)
        end

    end
end
defmodule Tester do

  def register(name) do
    server = :global.whereis_name(:twitter)
    {:ok,client} = GenServer.start_link(Client,[name,server])
    :global.register_name(String.to_atom(name),client)
    Client.register(client)
    IO.inspect client


  end

end


