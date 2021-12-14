#! /bin/bash

# Check to see if client output was valid
check_client_output() {
	local output_filename="$1"
	local expected_num_lines="$2"

	if [ "$(cat $output_filename | wc -l)" != "$expected_num_lines" ]; then
		echo "Client 1 output was the wrong length!"
		return 1
	fi
	if [ "$(grep -i error $output_filename | wc -l)" != "0" ]; then
		echo "Client 1 output contained errors!"
		return 1
	fi

	return 0
}

if [ "$#" -ne 1 ]; then
	echo "usage: ./test_server_concurrent_stress.sh <port>"
	exit 1
fi

port="$1"

# Start server process
./calcServer $port &
CALC_PID=$!

# Give the server a moment or two to start up...
sleep 2

# Make sure that server correctly reports errors
( (echo "x + 3"; echo "quit") | nc localhost $port) > err.txt
if [ "$(grep -i error err.txt | wc -l)" = "0" ]; then
	echo "Server does not correctly report errors!"
	kill -9 $CALC_PID
	exit 1
fi

# Create and initialize the shared variable
( (echo "k = 0"; echo "quit") | nc localhost $port ) > /dev/null
sleep 1

# Start clients
NUM_INCR=200000
( ( (perl -e 'for $v (1..'$NUM_INCR') { print "k = k + 1\n" }'; echo "quit") | nc localhost $port) > client1.out )&
CLIENT_PID1=$!
( ( (perl -e 'for $v (1..'$NUM_INCR') { print "k = k + 1\n" }'; echo "quit") | nc localhost $port) > client2.out )&
CLIENT_PID2=$!
# Client 3 creates new variables in a tight loop
( ( (perl -e 'sub r { chr(97+int(rand(26))) }; for $v (1..'$NUM_INCR') { print r().r().r()," = ",int(rand(1000)),"\n" }'; echo "quit") | nc localhost $port) > client3.out )&
CLIENT_PID3=$!

# Wait for clients to finish
wait $CLIENT_PID1
echo "Client 1 finished"
check_client_output client1.out $NUM_INCR
check1=$?
wait $CLIENT_PID2
echo "Client 2 finished"
check_client_output client2.out $NUM_INCR
check2=$?
wait $CLIENT_PID3
echo "Client 3 finished"
check_client_output client3.out $NUM_INCR
check3=$?

# Make sure server is still running
kill -0 $CALC_PID
if [ $? -ne 0 ]; then
	echo "Server crashed!"
	exit 1
fi

# Check whether clients produced acceptable output
if [ "$check1" -ne 0 -o "$check2" -ne 0 -o "$check3" -ne 0 ]; then
	echo "One or more clients did not produce acceptable output!"
	kill -9 $CALC_PID
	exit 1
else
	echo "Clients completed without errors, that's good"
fi

# Get final count, save to final_count.txt
( (echo "k"; echo "quit") | nc localhost $port) > final_count.txt
final_count=$(cat final_count.txt)
echo "Final count was: $final_count"
if [ "$final_count" = "$(expr $NUM_INCR \* 2)" ]; then
	echo "Final count was exact: synchronization was strict"
elif [ "$(expr $final_count '>' $NUM_INCR)" = "1" ]; then
	echo "Final count was above $NUM_INCR but less than $(expr $NUM_INCR \* 2): synchronization was not strict"
else
	echo "Final count was suspicious...synchronization issues?"
fi

# Shut down server
sleep 1
kill -9 $CALC_PID
