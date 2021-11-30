---
layout: default
title: "Assignment 6: Multithreaded network calculator"
---

**Due**: Wednesday, Dec 8th by 11pm

**Assignment type**: Pair (you may work with one partner, or do the assignment individually)

*Update 11/30*: Made it clear that this assignment does not have milestones

## Overview

In this assignment you will make your `calcServer` program from [Assignment 5](assign05.html)
multithreaded, so it can handle connections from multiple clients simultaneously.

Get started by making a copy of your code for Assignment 5 in a new directory.  You will
modify both `calcServer.c` and either `calc.cpp` or `calc.c` (depending on
whether you used C++ or C to implement the calculator functionality.)

## Goals of the assignment

The goals of the assignment are:

* Use threads to handle concurrent client connections
* Use synchronization to allow multiple threads to access shared data

## Grading rubric

Your grade will be determined as follows:

* Autograder tests of concurrent client connections: 75%
* `README.txt`, manual review of synchronization: 15%
* Design and coding style: 10%

There is also an extra credit option: if you can make your `calcServer`
program shut down cleanly after receiving a `shutdown` command from
a client, *exiting only after all client connections have finished*, you will
receive an extra 2 points.  Please note that we will only consider your
submission for the extra credit if it implements the base functionality
correctly.

Note that at most 48 late hours may be used for Milestone 2.

<!--
## Milestone 1 tasks

For Milestone 1, your code must compile, and there must be a substantial
start on handling client connections using threads.  We will expect to see
a reasonable thread start function, and a new thread using this start function
should be started for each accepted connection. We will also expect to see
a `struct` data type encapsulating the data needed for a client connection.
A dynamically-allocated instance of this type should be passed to the
thread start function as its argument.  At a minimum, this object should
contain the client socket file descriptor and a pointer to the shared
`struct Calc` object.

Your code doesn't need to be fully working, but it must compile and
have the elements described above.

## Milestone 2 tasks

Your main tasks for Milestone 2 are (1) to use multiple threads to handle
client connections (fully working), and (2) to use synchronization to protect
shared data so that expression evaluations are atomic.
-->

## Tasks

Your overall tasks are:

* Create a thread for each client connection. You will need a struct type
  to represent the data associated with a particular client, which should
  include the client socket file descriptor and a pointer to the shared
  `struct Calc` instance.  Make sure an instance of this type is
  dynamically allocated for each thread.
* Add synchronization to your `struct Calc` implementation so that expression
  evaluations are atomic.

### Using threads for client connections

In general, it makes sense for server applications to handle connections from
multiple clients simultaneously.  Threads are a useful mechanism for handling
multiple client connections because they allow the code which communicates
with each client to execute concurrently.

In your main server loop, create a thread for each accepted client connection.
Use `pthread_create` to create the client threads.  You can let the client
threads be detached (i.e., by having them call `pthread_detach` with their
own thread id.)  You do not need to place any upper limit on the number of
threads that can be active simultaneously (although in practice that's a
good idea.)

You can test that your server can handle multiple client sessions simultaneously
by running 2 (or more) `telnet` sessions connecting to the server.

Note that as with the server from [Assignment 5](assign05.html), all connections should share
a common `struct Calc` instance.  This means that a variable set by one client
is visible to other clients, and in fact, can be considered a simple form
of communication between clients.

The following screen capture shows two instances of telnet connecting to the
same `calcServer` (using [GNU Screen](https://www.gnu.org/software/screen/)
as a split-screen terminal):

<center>
<video width="720" controls>
  <source src="calcServer.webm" type="video/webm">
Your browser does not support the video tag.
</video>
</center>

### Using synchronization to protect shared data

Any time two thread access shared data, such that one or both threads
might modify the shared data, *synchronization* is typically necessary
to ensure the integrity of the shared data.  In addition, synchronization
is sometimes necessary to ensure that the desired semantics of
accesses to shared data is assured.

Add synchronization to your `struct Calc` data type so that it is guaranteed
that updates to calculator variables are atomic.  For example, if multiple
clients execute the update `a = a + 1` some arbitrary number of times,
then assuming that the initial value of `a` was 0, the final value of `a`
should be exactly equal to the number of times `a = a + 1` was executed.

Another way of describing the synchronization requirements is that for any
variable update of the form <code><i>lhs</i> = <i>rhs</i></code>,
where <code><i>lhs</i></code> is the variable being updated, and <code><i>rhs</i></code>
is an expression computing the value to assign to <code><i>lhs</i></code>,
you must guarantee that any variable or variables accessed in <code><i>rhs</i></code>
will not be modified while the execution of the overall assignment is in progress.

From a practical standpoint, you should add either a mutex or semaphore
(`mutex_t` or `sem_t`) field to your `struct Calc` data type, and then add
critical section(s) where needed to ensure that the synchronization
requirements are met.  **Very important**: the critical section(s) should be
in the `struct Calc` functions (in `calc.c` or `calc.cpp`), and *not* in `calcServer.c`.

**Important requirement**: In your `README.txt` file, briefly describe
how you made the calculator instance's shared data safe to access from multiple
threads.  Indicate what kind of synchronization object you used, and how
you determined which regions of code were critical sections.

### Clean shutdown (extra credit!)

*You can ignore this section if you're not planning to try the extra
credit, although what's described here is useful stuff to think about
if you're interested in systems and network programming.*

One difficulty in implementing a multithreaded server is how to allow it
to shut down cleanly.

For `calcServer`, the problem is that when one client sends a `shutdown`
command, there could be other threads still running, and shutting down
the server would interrupt these connections.

For up to 2 points extra credit, you can implement the `shutdown`
command such that the server will exit

* after a `shutdown` command has been received from any client
* only after all currently-connected clients have finished

In addition, once a `shutdown` command has been received, `calcServer`
should not accept any further client connections.

Shutting down cleanly is fairly challenging.  Here are some
rough ideas that might be useful:

* Use a semaphore to keep track of the number of client threads
  (this will also allow you to limit the maximum number of simultanous
  client connections, which is good!)
* Use the `select` or `poll` system calls to do a timed wait for
  incoming client connections, rather than doing a blocking
  call to `accept`
* Use a `volatile` global variable to keep track of whether any client
  has requested a shutdown: loading and storing the value of a volatile
  global variable does not constitute a data race if, in its lifetime,
  the variable only transitions from one value to one other value
  (e.g., it's initially false, but some thread sets it to true at a later
  time)

The reason that calls to `accept` need to be nonblocking is because if the
server is stuck waiting for an incoming client connection, it might not
be aware that one of its currently-connected clients has requested a
shutdown.  By using a timed wait, the server can "wake up" periodically
in order to check the global shutdown variable.

### Testing

Here are some automated tests you can try.

Download the following files into the directory containing your `calcServer` executable:

* [test\_server\_concurrent1.sh](assign06/test_server_concurrent1.sh)
* [test\_server\_concurrent2.sh](assign06/test_server_concurrent2.sh)
* [test\_server\_concurrent\_stress.sh](assign06/test_server_concurrent_stress.sh)
* [test\_input.txt](assign06/test_input.txt)
* [conc\_test\_input1.txt](assign06/conc_test_input1.txt)
* [conc\_test\_input2.txt](assign06/conc_test_input2.txt)

You can download the above files from a terminal by running the following commands:

```bash
curl -O https://jhucsf.github.io/fall2021/assign/assign06/test_server_concurrent1.sh
curl -O https://jhucsf.github.io/fall2021/assign/assign06/test_server_concurrent2.sh
curl -O https://jhucsf.github.io/fall2021/assign/assign06/test_server_concurrent_stress.sh
curl -O https://jhucsf.github.io/fall2021/assign/assign06/test_input.txt
curl -O https://jhucsf.github.io/fall2021/assign/assign06/conc_test_input1.txt
curl -O https://jhucsf.github.io/fall2021/assign/assign06/conc_test_input2.txt
```

Make the scripts executable:

```bash
chmod a+x test_server_concurrent1.sh
chmod a+x test_server_concurrent2.sh
chmod a+x test_server_concurrent_stress.sh
```

**First test**: run the following commands:

```bash
./test_server_concurrent1.sh 30000 test_input.txt actual1.txt
cat actual1.txt
```

The output of the `cat` command should be:

```
2
3
5
```

This test tests that a long-running client does not prevent the server from handling an additional client connection.

**Second test**: run the following commands:

```bash
./test_server_concurrent2.sh 30000 conc_test_input1.txt actual1.txt conc_test_input2.txt actual2.txt
cat actual1.txt
cat actual2.txt
```

The output of the first `cat` command should be:

```
1
42
```

The output of the second `cat` command should be:

```
40
54
```

This test tests that two client sessions can interact with each other through commands accessing a shared variable.

**Third test**: run the following commands:

```bash
./test_server_concurrent_stress.sh 30000
cat final_count.txt
```

The file `final_count.txt` must contain the value 400000.  Any value less than 400000 means
that expression evaluation is not atomic, so the thread synchronization does not meet
the requirements.

## Deliverables

You should not need to make any changes to your `Makefile`.

To submit your work, run the command

```
make solution.zip
```

As you did with [Assignment 5](assign05.html), make sure that your `solution.zip`
contains a `README.txt` file (in addition to the other required files.)

Upload `solution.zip` to Gradescope as **Assignment 6**.
