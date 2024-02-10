require 'socket'
require 'json'

# Rework sending data to send the following, per tick
#   - byte stream of hash map of player data
#   - byte stream of hash map of overworld data

# data structure
# {
#   type: ['players', 'overworld']
#   data: {
#     ... specific data based on the type
#   }
# }

class Server
  def initialize(port)
    @server = TCPServer.new(port)
    @clients = []
    @overworld_map = {
      10 => { entity_id: 1000, x: 100, y: 150, color: { red: 255, green: 0, blue: 0 }, status: 'alive' },
      11 => { entity_id: 1001, x: 200, y: 250, color: { red: 0, green: 255, blue: 0 }, status: 'alive' },
      12 => { entity_id: 1002, x: 300, y: 350, color: { red: 0, green: 0, blue: 255 }, status: 'alive' }
      # Add more entities as needed
    }
    @client_player_map = {}
    puts "Server listening on port #{port}"
  end

  def start
    loop do

      # take in a new client
      client = @server.accept
      @clients << client

      # add that client to the map with a unique identifier
      client_id = "#{client.peeraddr[2]}:#{client.peeraddr[1]}"
      @client_player_map[client_id] = {}

      puts "new client"
      puts @client_player_map
      puts "\n"

      #puts "Client connected from #{client.peeraddr[2]}, port #{client.peeraddr[1]}"
      # open up a new thread to handle the new client
      Thread.new(client) { |current_client| handle_client(current_client) }
    end
  end

  # remove dead overworld entities from the global map
  def clean_overworld
    @overworld_map.each do |_id, data|
      if data[:status] == "dead"
        # puts "cleaning #{_id}"
        @overworld_map.delete(_id)
      end
    end
  end

  # Change handle client to leverage the two global hash maps for overworld 
  # As data comes in, 
  #   1. Unpack the byte stream, 
  #   2. Check if its an player or overworld stream
  #   3. Pipe the newest message into the global hash maps
  #   4. Reconvert the hash maps to byte streams
  #   5. Send the bytestreams to the clients
  def handle_client(client)
    client_id = "#{client.peeraddr[2]}:#{client.peeraddr[1]}"

    loop do
      begin
  
        received_data = client.recv(8192)

        if received_data.nil? || received_data.empty?
          puts "Client disconnected."
          @clients.delete(client)
          @client_player_map.delete(client_id)
          break
        end

        marshld_data = Marshal.load(received_data)
        # puts marshld_data

        data_type = marshld_data[:type]

        if data_type == "player_data"
          data_body = marshld_data[:data]
          handle_player_data(data_body, client)
        elsif data_type == "overworld_kill"
          puts "overworld kill <<<<"
          puts @overworld_map
          #puts @overworld_map[10]
          puts ">>>>"
          @overworld_map[marshld_data[:overworld_id]][:status] = "dead"
        end
  
        big_data = {player_data: @client_player_map, overworld_data: @overworld_map}
        puts @client_player_map
        send_data_to_client(big_data)

      rescue Errno::ECONNRESET
        puts "Error: Connection reset by peer. Client disconnected."
        @clients.delete(client)
        @client_player_map.delete(client_id)
        client.close
        break
      end
    end
  end

  
  def send_data_to_client(map)
    
    @clients.each do |receiver|
      begin
        puts "sending to #{receiver}"
        receiver.puts(Marshal.dump(type: "big", data: map))
      rescue Errno::EPIPE
        puts "Error: Broken pipe. Client disconnected."
        @clients.delete(client)
      end
    end
  end

  def handle_player_data(data_body, client)
    client_id = "#{client.peeraddr[2]}:#{client.peeraddr[1]}"
    #puts client_id
    @client_player_map[client_id] ||= {}
    @client_player_map[client_id] = data_body

    #puts @client_player_map
  end

end

# Usage
server = Server.new(12345)
server.start
