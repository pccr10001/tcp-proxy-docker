#!/usr/bin/env bash

# Check if required environment variables exist
if [ -z "$DST_ADDRS" ] || [ -z "$LISTEN_PORTS" ]; then
    echo "Error: Both DST_ADDRS and LISTEN_PORTS environment variables must be set"
    echo "Example: DST_ADDRS='host1:port1;host2:port2' LISTEN_PORTS='listen_port1;listen_port2'"
    exit 1
fi

# Parse semicolon-separated values into arrays
IFS=';' read -ra DESTINATIONS <<< "$DST_ADDRS"
IFS=';' read -ra PORTS <<< "$LISTEN_PORTS"

# Check if arrays have the same length
if [ ${#DESTINATIONS[@]} -ne ${#PORTS[@]} ]; then
    echo "Error: Number of destinations (${#DESTINATIONS[@]}) must match number of listen ports (${#PORTS[@]})"
    exit 1
fi

# Start socat processes for each destination-port pair
for i in "${!DESTINATIONS[@]}"; do
    DESTINATION="${DESTINATIONS[$i]}"
    LISTEN_PORT="${PORTS[$i]}"
    
    # Split destination into host and port
    HOST=$(echo "$DESTINATION" | cut -d':' -f1)
    PORT=$(echo "$DESTINATION" | cut -d':' -f2)
    
    echo "Relay TCP/IP connections on :${LISTEN_PORT} to ${HOST}:${PORT}"
    socat TCP-LISTEN:${LISTEN_PORT},fork,reuseaddr TCP:${HOST}:${PORT} &
done

# Wait for all background processes
wait
