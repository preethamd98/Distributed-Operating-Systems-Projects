# Tapastry Algorithm (P2P) Implementation

**Includes an algorithm for distributed hash table protocol and lookups**

## Group info
| Name  | UFID  |
|---|---|
| Preetham Dasari | 69698425  |
|  Tarshith Gandi| 79154462  |

## Instructions

1. Unzip Dasari_Gandi.zip file and navigate to Dasari_Gandi folder.
2. Open the terminal and enter the below mix command to compile and run the code.
</br>**Input:** Enter numNodes, numRequests 
</br> Here numNodes are the total number of nodes in a network and numRequests are the total number of requests which each node performs sending 1 request per second.
</br>**Output:** Maximum number of hops per request </br>
**mix run tapastry.exs numNodes numRequests** </br>
3. **Input:**
mix run main.exs 1000 10</br>
**Output:**
</br>Forming a Static Network
</br>Adding the node dynamically
</br>Multicast message has been sent
</br>Dynamic join has been done
</br>The Max-Number of hops take in the network are: 4</br></br>

4. Working:</br>

    1.    Initially a network is created of a small amount of totaL number of nodes.
    2.    Remaining nodes join the network by sending a multicast message to all the nodes. 
    3.    The routing  tables for the node contained the 6-bit SHA-1 hash nodeIPs and are of the size 6 each. 
    4.    Lookup is then performed in the hash table and the routing is done accordingly.
    5.    The largest network managed for number of nodes and number of requests is 1000 nodes and 10 requests.
