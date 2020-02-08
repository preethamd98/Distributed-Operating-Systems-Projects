defmodule Adder do
    use GenServer
    @diff 1.0e-10
    @round_lim 3
    #state: {neighbours, neighbours_size, s, w, rounds, child pid}

    def spread_pushsum(neighbours, num_neighbours, s, w) do
        Enum.at(neighbours, :rand.uniform(num_neighbours) - 1) |> GenServer.cast({:pushsum, s, w})
        :timer.sleep(100)
        spread_pushsum(neighbours, num_neighbours, s, w)
    end
    
    defp kill_and_replay(child_pid, neighbours, num_neighbours, s, w) do
        if(child_pid != nil) do
            Task.shutdown(child_pid, :brutal_kill) #kill previous spreader 
        end
        Task.async(fn -> __MODULE__.spread_pushsum(neighbours, num_neighbours, s, w) end)
    end

    def handle_call(:show_neighbours, _from, state) do
        {:reply, elem(state, 0), state} 
    end

    #initialize
    def handle_call({:neighbours, neighbours}, _from, s) do
        {:reply, :ok, {neighbours, length(neighbours), s, 1, 0, nil}}
    end

    #first call to start the pushsum algo
    def handle_cast(:start, state) do
        neighbours = elem(state, 0)
        num_neighbours = elem(state, 1)
        s = elem(state, 2)
        w = elem(state, 3)
        
        child_pid = kill_and_replay(nil, neighbours, num_neighbours, s/2, w/2)
        {:noreply, {neighbours, num_neighbours, s/2, w/2, 0, child_pid}} #pass s/2, w/2
    end

    def handle_cast({:pushsum, s, w}, state) do
        if(state != :inactive) do
            neighbours = elem(state, 0)
            num_neighbours = elem(state, 1)
            old_s = elem(state, 2)
            old_w = elem(state, 3)
            rounds = elem(state, 4)
            child_pid = elem(state, 5)

            old_ratio = old_s/old_w
            new_s = old_s + s
            new_w = old_w + w
            new_ratio = new_s/new_w
            if(abs(new_ratio - old_ratio) <= @diff) do
                rounds = rounds + 1
                if(rounds == @round_lim) do
                    if(child_pid != nil) do
                        Task.shutdown(child_pid, :brutal_kill) #kill previous spreader    
                    end
                    master_pid = Process.whereis(:master)
                    if(master_pid != nil) do #required if master dies after getting all successes
                        send master_pid, :success #send master success    
                    end
                    # IO.inspect new_ratio #TODO for debugging
                    {:noreply, :inactive}
                else
                    child_pid = kill_and_replay(child_pid, neighbours, num_neighbours, new_s/2, new_w/2)
                    {:noreply, {neighbours, num_neighbours, new_s/2, new_w/2, rounds, child_pid}} #pass s/2, w/2
                end               
            else
                child_pid = kill_and_replay(child_pid, neighbours, num_neighbours, new_s/2, new_w/2)
                {:noreply, {neighbours, num_neighbours, new_s/2, new_w/2, 0, child_pid}} #if not consec <= diff, rounds back to 0        
            end
        else
            {:noreply, :inactive}
        end
    end 

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end
    
end