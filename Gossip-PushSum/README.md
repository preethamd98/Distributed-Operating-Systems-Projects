            .::COP5615  -- Project-2 -- Gossip-Push-Sum-Simulator::.

Team Members:
Preetham Dasari (UFID:69698425)
Tharshith Gandi (UFID:43007097)

Instructions to run the Program:

1.) Extract the zip file Dasari_Gandi
2.) Navigate to folder Dasari_Gandi
3.) Open terminal and run the command "mix escript.build" which is going to build the program.
4.) run the command escript project2 number_of_nodes topology algorithm
        number of nodes -> is the number of nodes you want in the network
        topology -> different type of topologies in this program are full_network, Line, 2D random grid, 3D torus, honeycomb, honeycomb random
        Algorithm -> The two algorithms available are push-sum and gossip.
5.) Graphs can viewed in experiments.xls

Specifications of the machine where the test are runned:

Model: MacBook Pro (Retina, 13-inch, Early 2015)
Processor : 2.7Ghz Intel Core i5 
Number of Cores: 2
Memory :  8GB 1867 MHz DDR3


Some design decisions:

1.)Every node, after receipt of a rumor or (sum, weight), continuously transmits the rumor or (sum/2, weight/2) every 100 milliseconds
2.)All times measured are in microseconds
3.)If the provided value of num is not a perfect square for torus,honeycomb and honeycombrandom topologies, the nearest perfect sqaure is used as the value of num        
4.)Percentage of convergence(i.e the number of nodes which are going to die) have been changed for each algorithm as some algorithms are not converging. The percentage has been tweaked so that every one converges.
5.) When using the 3D torus and honeycomb the number of nodes is rounded to nearest number so that the structure can be formed.



What is working: All combinations of topologies and algorithms in accordance with their definitions of convergence.

Graphs: 
1.) All the graphs are drawn seperately because the percentage of convergence criteria are different for different topologies and algorithms.

Interesting observations:
1.) For line topology, when the network size is less 50 s/w ratio is not accurate for all the nodes. Also, for higher number of nodes line fails to converge faster than other topologies like full network.
2.) Random 2D is highly unreliable because during formation the nodes are sparsley connected so some messages are not going to be transfered.
3.) 3D torus, honeycombrandom, full network have the best performance
