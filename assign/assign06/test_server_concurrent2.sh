#! /bin/bash

# Test interleaved connections from multiple clients.
# It works by sending one line at a time, as specified by
# the two input files, alternating lines sent between the
# two clients.  I.e., first send a line from the first
# input file, then send a line from the second input file,
# then the first, then the second, etc., until all lines
# have been sent.  This allows the implementation of repeatable 
# tests where clients communicate using share variable(s).

if [ $# -ne 5 ]; then
	echo "Usage: test_server_concurrent2.sh <port> <input file 1> <output file 1> <input file 2> <output file 2>"
	exit 1
fi

port="$1"
input_file1="$2"
output_file1="$3"
input_file2="$4"
output_file2="$5"

fifo1="fifo1_$$"
fifo2="fifo2_$$"

# Make FIFOs to send input to client procs
rm -f $fifo1 $fifo2
mkfifo $fifo1
mkfifo $fifo2

# Read contents of input files into arrays
IFS=$'\r\n' GLOBIGNORE='*' command eval  'FILE1_CONTENTS=($(cat '$input_file1'))'
IFS=$'\r\n' GLOBIGNORE='*' command eval  'FILE2_CONTENTS=($(cat '$input_file2'))'

# Start server process
./calcServer $port &
CALC_PID=$!

# Give the server a moment or two to start up...
sleep 2

# Start client processes; they will read from their respective FIFOs
# to get the commands to be sent to the calcServer
( (cat $fifo1 | nc localhost $port) > $output_file1 )&
CLIENT1_PID=$!
( (cat $fifo2 | nc localhost $port) > $output_file2 )&
CLIENT2_PID=$!

# Open file descriptors to write to the FIFOs: we need these
# to remain open for writing for the duration of the sessions
exec 4> $fifo1
exec 5> $fifo2

# Read input file contents into arrays
FILE1_NLINES=${#FILE1_CONTENTS[@]}
FILE2_NLINES=${#FILE2_CONTENTS[@]}
ct1=0
ct2=0

# Interleave input file contents, line by line, sending each
# line to the appropriate FIFO.
while [ $ct1 -lt $FILE1_NLINES -a $ct2 -lt $FILE2_NLINES ]; do
	if [ $ct1 -lt $FILE1_NLINES ]; then
		echo "${FILE1_CONTENTS[$ct1]}" >&4
		echo "sent data to client 1"
		ct1=$(expr $ct1 + 1)
		# Give clients a bit of time to process the command
		sleep 1
	fi
	if [ $ct2 -lt $FILE2_NLINES ]; then
		echo "${FILE2_CONTENTS[$ct2]}" >&5
		echo "sent data to client 2"
		ct2=$(expr $ct2 + 1)
		# Give clients a bit of time to process the command
		sleep 1
	fi
done

# Close FIFO output file descriptors
exec 4>&-
exec 5>&-

wait $CLIENT1_PID
echo "Client 1 finished"
wait $CLIENT2_PID
echo "Client 2 finished"

# Delete FIFOs
rm -f $fifo1 $fifo2

# Kill server process
sleep 1
kill -9 $CALC_PID
