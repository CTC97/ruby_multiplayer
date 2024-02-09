require 'gosu'
require_relative 'client'

class GameWindow < Gosu::Window
  def initialize(client)
    super(800, 600, false)
    self.caption = 'client server testing'

    @x = @y = 100
    @client = client
    @player_id = rand(44444444)
    @players = {}
    @color = random_gosu_color

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  def update
    move_left if Gosu.button_down?(Gosu::KB_LEFT)
    move_right if Gosu.button_down?(Gosu::KB_RIGHT)
    move_up if Gosu.button_down?(Gosu::KB_UP)
    move_down if Gosu.button_down?(Gosu::KB_DOWN)

    # Send coordinates and player ID to the server using the client instance
    @client.send_data(player_id: @player_id, x: @x, y: @y, color: color_to_hash(@color))

    # Update the players' positions based on received data
    received_data = @client.received_data
    update_player_info(received_data) if received_data&.key?(:player_id)
  end

  def draw
    # Set background color to pink
    draw_quad(0, 0, Gosu::Color.new(255, 182, 193), width, 0, Gosu::Color.new(255, 182, 193), 0, height, Gosu::Color.new(255, 182, 193), width, height, Gosu::Color.new(255, 182, 193))

    # Draw squares for all players
    @players.each do |_id, player_info|
      x, y, color = player_info[:x], player_info[:y], hash_to_color(player_info[:color])
      Gosu.draw_rect(x, y, 50, 50, color)
      @font.draw_text(player_info[:player_id].to_s, x - 6, y - 16, 1, 0.8, 0.8, Gosu::Color::WHITE)
      #Gosu.draw_text(player_info[:player_id].to_s, x + 25, y + 25, 1, 1, 10, Gosu::Color::BLACK, Gosu.default_font_name)
    end

    Gosu.draw_rect(@x, @y, 50, 50, @color)
    @font.draw_text(@player_id.to_s, @x-6, @y-16, 1, 0.8, 0.8, Gosu::Color::WHITE)
  end

  private

  def move_left
    @x -= 5
  end

  def move_right
    @x += 5
  end

  def move_up
    @y -= 5
  end

  def move_down
    @y += 5
  end

  def update_player_info(received_data)
    player_id = received_data[:player_id]
  
    if player_id
      # Update information for a specific player
      @players[player_id] ||= {}

      @players[player_id][:player_id] = player_id
  
      prev_x = @players[player_id][:x] || received_data[:x]
      prev_y = @players[player_id][:y] || received_data[:y]
  
      @players[player_id][:x] = lerp(prev_x, received_data[:x], 0.5)
      @players[player_id][:y] = lerp(prev_y, received_data[:y], 0.5)
      @players[player_id][:color] = received_data[:color]
    end
  end

  def lerp(start, target, alpha)
    start + alpha * (target - start)
  end

  def random_gosu_color
    return Gosu::Color.new(rand(255), rand(255), rand(255))
  end

  def color_to_hash(color)
    return { red: color.red, green: color.green, blue: color.blue }
  end

  def hash_to_color(color_hash)
    return Gosu::Color.new(color_hash[:red], color_hash[:green], color_hash[:blue])
  end
end

# Example usage
client = Client.new('localhost', 12345)
client.connect

window = GameWindow.new(client)
window.show

# Close the connection when done
client.close