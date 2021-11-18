#! /bin/bash

# Test basic concurrency: can the server handle multiple
# concurrent sessions.

if [ $# -ne 3 ]; then
	echo "Usage: test_server_concurrent1.sh <port> <input file> <output file>"
	exit 1
fi

port="$1"
input_file="$2"
output_file="$3"

# Start server process
./calcServer $port &
CALC_PID=$!

# Give the server a moment to start up
sleep 2

# Start a "long-running" client
( (echo "1 + 1"; sleep 6; echo "quit") | nc localhost $port > /dev/null )&
LONG_RUNNING_CLIENT_PID=$!

# Start a second session, send input to server, capture its output
# Note we only allow 4 seconds for this session to complete!
timeout 4 nc localhost $port < $input_file > $output_file

# Wait for long running client to finish
wait $LONG_RUNNING_CLIENT_PID
echo "Long running client has finished"

# Kill server process
sleep 1
kill -9 $CALC_PID
