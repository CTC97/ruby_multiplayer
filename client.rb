# client.rb

require 'socket'
require 'json'

class Client
  attr_reader :received_data

  def initialize(server_address, server_port)
    @server_address = server_address
    @server_port = server_port
    @socket = nil
  end

  def connect
    @socket = TCPSocket.new(@server_address, @server_port)
    puts "Connected to server #{@server_address}:#{@server_port}"

    # Start a thread to continuously listen for server messages
    start_listener_thread
  end

  def send_data(data)
    return unless @socket

    # Convert the hash to a JSON-formatted string
    json_data = data.to_json

    # Send the JSON data to the server
    @socket.puts(json_data)
    #puts "Sent JSON data to the server: #{json_data}"
  end

  def close
    @socket&.close
  end

  private

  def start_listener_thread
    Thread.new do
      loop do
        received_data = @socket.gets&.chomp

        if received_data.nil?
          # Server closed the connection
          puts "Server disconnected."
          break
        else
          puts "Received from server: #{received_data}"
          @received_data = JSON.parse(received_data, symbolize_names: true)
        end
      end
    end
  end
end
