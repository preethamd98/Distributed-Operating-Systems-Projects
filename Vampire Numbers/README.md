                                    .::COP5615  -- Project-1 -- Finding Vampire Numbers::.

Team Members:
Preetham Dasari (UFID:69698425)
Tharshith Gandi (UFID:43007097)

Instructions to run the Program:

1.) Extract the zip file Dasari_Gandi
2.) Navigate to folder Dasari_Gandi
3.) Open terminal and run the command "mix run proj1.exs start end" (Where start is the lower bound and end is the upper-bound)


Approach:

1-> The main intention of the project is to get a feel for elixir and understand the actor model. In Actor model an actor can
    spawn process and send and receive messages from other processes. An actor can also send messages to itself.
2-> The project is done using mainly The Genserver and and Tasks module.
3-> The main module implemented is VampireBoss which takes the input range given by the user and passes to the spawnBulkProcesses which divides the range into chunks and then
    it spawns the Vampire.task process. The number of processes spawned is equal to the number of chunks the range is divided into.
4-> The task.await waits for all the tasks to finish. When a processes finishes the computation it sends to the boss using handle call method.


Work Size for each task:

The work size for each process is 5% of the number in the range. This number is decided based on running tests.

Specifications of the machine where the test are runned:

Model: MacBook Pro (Retina, 13-inch, Early 2015)
Processor : 2.7Ghz Intel Core i5 
Number of Cores: 2
Memory :  8GB 1867 MHz DDR3

The testing is done for finding the vampire number between the range 1 - 2000000

Results:

+------------+-----------+-----------+----------+-------+
| Batch_size | Real_time | User_time | sys_time | Ratio |
+------------+-----------+-----------+----------+-------+
| 1%         | 0m5.427s  | 0m16.512s | 0m0.496s | 3.13  |
+------------+-----------+-----------+----------+-------+
| 5%         | 0m5.470s  | 0m16.899s | 0m0.669s | 3.21  |
+------------+-----------+-----------+----------+-------+
| 10%        | 0m5.885s  | 0m15.880s | 0m0.775s | 2.83  |
+------------+-----------+-----------+----------+-------+
| 20%        | 0m5.994s  | 0m12.374s | 0m1.018s | 2.23  |
+------------+-----------+-----------+----------+-------+

Based on the test we have concluded that a batch size of 5% is giving the best results.


Results for the Given problem:

Range: 100000 - 200000

Output:
 190260 210 906 192150 210 915 193257 327 591 193945 395 491
 125248 152 824 125433 231 543 125460 204 615 246 510 125500 251 500 126027 201 627 126846 261 486 129640 140 926 129775 179 725
 131242 311 422 132430 323 410 133245 315 423 134725 317 425
 162976 176 926 163944 396 414
 135828 231 588 135837 351 387 136525 215 635 136948 146 938
 197725 275 719
 172822 221 782 173250 231 750 174370 371 470
 105210 210 501 105264 204 516 105750 150 705 108135 135 801
 186624 216 864
 140350 350 401
 102510 201 510 104260 260 401
 145314 351 414 146137 317 461 146952 156 942
 175329 231 759
 150300 300 501 152608 251 608 152685 261 585 153436 356 431
 115672 152 761 116725 161 725 117067 167 701 118440 141 840
 156240 240 651 156289 269 581 156915 165 951
 180225 225 801 180297 201 897 182250 225 810 182650 281 650
 110758 158 701
 120600 201 600 123354 231 534 124483 281 443

The Ordering of the output in non deterministic because we do not know which worker is going to return the message to the boss first.


Time taken to run:

real:       0m1.157s
user:	    0m2.868s
sys:	    0m0.151s
cpu_time:   0m3.019s(Usertime+Systemtime)
Ratio:      3.019>1 (Parallelism is achieved)

Largest Calculation which can be done:
Vampire number between 1-5000000
Larger calculations can be done by tweaking the task function as I am getting a timeout error.


Learnings:
1.) The number of process should be chosen carefully because initially we have tried spawning each processes for each number which was very inefficient and spawning and communication takes some time.
2.) Functional programming is different from structural programming language.


Improvements:
1.) We got a timeout exception for calculating large values which can be fixed by tweaking the task.await function.
2.) The current project is not fault tolerant and the improvements can be made using a task supervisor.
