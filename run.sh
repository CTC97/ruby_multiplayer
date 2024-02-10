#!/bin/bash
reset

# Get the PIDs using port 12345
pids=$(lsof -ti :12345)

# Check if there are any PIDs
if [ -n "$pids" ]; then
    # Kill the processes
    echo "Killing processes with PIDs: $pids"
    kill $pids
else
    echo "No processes found using port 12345."
fi

# Run server.rb in the background
ruby server.rb &

# Wait for the server to start (you may need to adjust the sleep duration)
sleep 2

# Run three instances of ui.rb in the background
ruby ui.rb &
ruby ui.rb &
ruby ui.rb &

# Wait for all processes to finish
wait