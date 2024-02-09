require 'socket'

# Replace 12345 with the port you want to use
server_port = 12345

# Create a server socket
server = TCPServer.new(server_port)

puts "Server listening on port #{server_port}"

# Array to store connected clients
clients = []

def handle_client(client, clients)
  loop do
    # Read the time sent by the client
    received_data = client.gets&.chomp

    if received_data.nil?
      # Client has closed the connection
      puts "Client disconnected."
      clients.delete(client)
      break
    end

    puts "Received data from client (#{client.peeraddr[2]}, port #{client.peeraddr[1]}): #{received_data}"

    # Broadcast the received message to all other clients
    clients.each do |other_client|
      next if other_client == client # Skip the sender
      begin
        other_client.puts(received_data)
      rescue Errno::EPIPE
        # Handle broken pipe error (client disconnected)
        puts "Error: Broken pipe. Client disconnected."
        clients.delete(other_client)
      end
    end
  end

  # Close the client connection
  client.close
end


loop do
  # Wait for a client to connect
  client = server.accept

  # Add the new client to the list
  clients << client

  # Print information about the connected client
  puts "Client connected from #{client.peeraddr[2]}, port #{client.peeraddr[1]}"

  # Create a new thread to handle the client
  Thread.new(client, clients) do |current_client, all_clients|
    handle_client(current_client, all_clients)
  end
end
