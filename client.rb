# client.rb

require 'socket'
require 'json'

class Client
  attr_reader :received_data
  attr_reader :local_client_id

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
    @socket.puts(Marshal.dump(data))
  end

  def close
    @socket&.close
  end

  def assign_local_client_id(client_id)
    @local_client_id = client_id
  end

  # Change this thread to interpret byte streams from Marshal
  private def start_listener_thread
    Thread.new do
      loop do
        received_data = @socket.recv(4096)
        #puts received_data

        if received_data.nil?
          # Server closed the connection
          puts "Server disconnected."
          break
        else
          #puts "Received from server: #{received_data}"
          @received_data = Marshal.load(received_data)
        end
      end
    end
  end
end
