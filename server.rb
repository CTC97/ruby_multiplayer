require 'socket'
require 'json'

class Server
  def initialize(port)
    @server = TCPServer.new(port)
    @clients = []
    @overworld_entities = {
      1000 => { entity_id: 1000, x: 100, y: 150, color: { red: 255, green: 0, blue: 0 }, status: 'alive' },
      1001 => { entity_id: 1001, x: 200, y: 250, color: { red: 0, green: 255, blue: 0 }, status: 'alive' },
      1002 => { entity_id: 1002, x: 300, y: 350, color: { red: 0, green: 0, blue: 255 }, status: 'alive' }
      # Add more entities as needed
    }
    puts "Server listening on port #{port}"
  end

  def start
    loop do
      client = @server.accept
      @clients << client
      puts "Client connected from #{client.peeraddr[2]}, port #{client.peeraddr[1]}"
      Thread.new(client) { |current_client| handle_client(current_client) }
    end
  end

  def clean_overworld
    @overworld_entities.each do |_id, data|
      if data[:status] == "dead"
        puts "cleaning #{_id}"
        @overworld_entities.delete(_id)
      end
    end
  end

  private

  def handle_client(client)
    loop do
      begin
        received_data = client.gets&.chomp
  
        if received_data.nil?
          puts "Client disconnected."
          @clients.delete(client)
          break
        end
  
        #puts "Received data from client (#{client.peeraddr[2]}, port #{client.peeraddr[1]}): #{received_data}"
        data_hash = JSON.parse(received_data, symbolize_names: true)
        puts data_hash

        if data_hash&.key?(:kill_entity)
          entity_id = data_hash[:entity_id]
        
          if @overworld_entities.key?(entity_id)
            @overworld_entities[entity_id][:status] = "dead"
            puts "Marking entity #{entity_id} as dead"
            puts @overworld_entities
          else
            puts "Entity #{entity_id} not found in @overworld_entities"
          end
        end

        broadcast_to_clients(client, received_data)
        send_overworld_to_clients()
      rescue Errno::ECONNRESET
        puts "Error: Connection reset by peer. Client disconnected."
        @clients.delete(client)
        client.close
        break
      end
    end
  end

  def send_overworld_to_clients()
    @clients.each do |client|
      @overworld_entities.each do |_id, data|
        puts "sending entity #{_id} from server"
        begin
          json_data = data.to_json
          client.puts(json_data)
        rescue Errno::EPIPE
          puts "Error: Broken pipe. Client disconnected."
          @clients.delete(other_client)
        end
      end
    end

    # clean_overworld()
    # puts "\tcleaned"
    # puts @overworld_entities
  end

  def broadcast_to_clients(sender, message)
    @clients.each do |other_client|
      next if other_client == sender
      begin
        other_client.puts(message)
      rescue Errno::EPIPE
        puts "Error: Broken pipe. Client disconnected."
        @clients.delete(client)
      end
    end
  end
end

# Usage
server = Server.new(12345)
server.start
