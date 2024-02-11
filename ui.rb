require 'gosu'
require_relative 'client'
require_relative 'entity'
require_relative 'tilesheet'
require_relative 'camera'

class GameWindow < Gosu::Window
  def initialize(client)
    super(832, 640, false)
    self.caption = 'client server testing'

    @x = @y = 20
    @client = client
    @local_player_id = rand(44444444)
    @local_players_map = {}
    @local_overworld_map = {}
    @color = random_gosu_color

    @entity = Entity.new(self)
    @camera = Camera.new(self, @entity)

    puts @local_player_id

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    @tick_frame = 0

    # this will ultimately be stored server side, but just testing for now
    @tilesheet = Tilesheet.new('other/tilesheet64.png', 64, 64)
    @tileset = [
      [1, 2, 0, 3, 2, 1, 1, 0, 2, 3, 3, 0, 2, 1, 0, 1],
      [2, 1, 3, 0, 2, 2, 3, 0, 2, 1, 0, 2, 1, 3, 1, 2],
      [0, 3, 1, 1, 3, 2, 1, 0, 3, 2, 3, 0, 1, 2, 3, 0],
      [2, 0, 3, 2, 3, 0, 1, 2, 3, 0, 2, 1, 2, 0, 2, 1],
      [3, 0, 2, 1, 0, 3, 2, 1, 3, 0, 0, 1, 2, 3, 1, 2],
      [3, 2, 0, 2, 1, 3, 1, 0, 2, 2, 3, 0, 3, 1, 2, 3],
      [1, 0, 1, 3, 0, 2, 1, 2, 3, 2, 0, 2, 1, 1, 0, 3],
      [0, 2, 3, 2, 1, 1, 2, 0, 3, 0, 2, 3, 2, 1, 1, 2],
      [0, 1, 2, 0, 1, 3, 2, 2, 0, 3, 2, 3, 0, 1, 2, 3],
      [0, 3, 0, 2, 3, 2, 1, 1, 2, 0, 2, 1, 1, 0, 3, 1],
      [2, 3, 2, 1, 1, 2, 3, 0, 3, 1, 2, 3, 2, 1, 0, 3],
      [1, 2, 0, 3, 2, 1, 1, 0, 2, 3, 3, 0, 2, 1, 0, 1],
      [2, 1, 3, 0, 2, 2, 3, 0, 2, 1, 0, 2, 1, 3, 1, 2],
      [0, 3, 1, 1, 3, 2, 1, 0, 3, 2, 3, 0, 1, 2, 3, 0],
      [2, 0, 3, 2, 3, 0, 1, 2, 3, 0, 2, 1, 2, 0, 2, 1],
      [3, 0, 2, 1, 0, 3, 2, 1, 3, 0, 0, 1, 2, 3, 1, 2]
    ]
    
    
  end

  def update
    @tick_frame = (@tick_frame+1) % 60
    @entity.update(@tick_frame)
    @camera.update()

    move_left if Gosu.button_down?(Gosu::KB_LEFT)
    move_right if Gosu.button_down?(Gosu::KB_RIGHT)
    move_up if Gosu.button_down?(Gosu::KB_UP)
    move_down if Gosu.button_down?(Gosu::KB_DOWN)

    @client.close if Gosu.button_down?(Gosu::KB_ESCAPE)

    #check_collisions()

    @client.send_data(type: "player_data", data: {player_id: @local_player_id, x: @x, y: @y, color: color_to_hash(@color)})

    # Update the players' positions based on received data
    # This field will be the post-Marshal'd data
    # puts "\n<<<<<"
    received_data = @client.received_data
    # puts received_data
    # puts ">>>>>>"

    update_local_map(received_data[:data]) if received_data&.key?(:type) && received_data[:type] == "big"
    # update_player_info(received_data) if received_data&.key?(:player_id)
    # update_entity_info(received_data) if received_data&.key?(:entity_id)
  end

  def draw_tilemap()
    @tileset.each_with_index do |row, y|
      row.each_with_index do |val, x|
        #puts "drawing at (#{x*@tilesheet.frame_width}, #{y*@tilesheet.frame_height})"
        @tilesheet.draw(x*@tilesheet.frame_width, y*@tilesheet.frame_height, val)
      end
    end
  end

  def draw
    @camera.translate() do 
      # Set background color to pink
      draw_quad(0, 0, Gosu::Color.new(255, 182, 193), width, 0, Gosu::Color.new(255, 182, 193), 0, height, Gosu::Color.new(255, 182, 193), width, height, Gosu::Color.new(255, 182, 193))

      # draw the map on top of the background (can ultimately remove background)
      draw_tilemap()

      # Draw squares for all players
      @local_players_map.each do |player_id, player_data|
        if !player_data.empty?
          #puts player_data
          x, y, color = player_data[:x], player_data[:y], hash_to_color(player_data[:color])
          Gosu.draw_rect(x, y, 50, 50, color)
          @font.draw_text(player_data[:player_id].to_s, x - 6, y - 16, 1, 0.8, 0.8, Gosu::Color::WHITE)
        end
        #Gosu.draw_text(player_info[:player_id].to_s, x + 25, y + 25, 1, 1, 10, Gosu::Color::BLACK, Gosu.default_font_name)
      end

      @local_overworld_map.each do |ow_id, ow_data|
        if !ow_data.empty?
          #puts ow_data
          x, y, color = ow_data[:x], ow_data[:y], hash_to_color(ow_data[:color])
          Gosu.draw_rect(x, y, 50, 50, color)
          @font.draw_text(ow_data[:entity_id].to_s, x - 6, y - 16, 1, 0.8, 0.8, Gosu::Color::WHITE)
        end
      end

      # Draw square for client player
      Gosu.draw_rect(@x, @y, 50, 50, @color)
      @font.draw_text(@local_player_id.to_s, @x-6, @y-16, 1, 0.8, 0.8, Gosu::Color::WHITE)

      @entity.draw
    end
  end


  def update_local_map(received_data)
    check_collisions()

    #puts "in local update"
    #puts received_data
    player_data_map = received_data[:player_data]
    overworld_data_map = received_data[:overworld_data]
    #puts "here!"
    if !player_data_map.empty?
      player_data_map.each do |player_id, data|
        next if @local_player_id == data[:player_id]
        @local_players_map[player_id] ||= {}
        @local_players_map[player_id] = data

        # prev_x = @local_players_map[player_id][:x] || data[:x]
        # prev_y = @local_players_map[player_id][:y] || data[:y]
    
        # @local_players_map[player_id][:x] = lerp(prev_x, data[:x], 0.5)
        # @local_players_map[player_id][:y] = lerp(prev_y, data[:y], 0.5)
        # @local_players_map[player_id][:color] = received_data[:color]
      end
    end

    @local_overworld_map.each do |ow_id, data|
      if !overworld_data_map.key?(ow_id)
        @local_overworld_map.delete(ow_id)
      end
    end

    if !overworld_data_map.empty?
      overworld_data_map.each do |ow_id, data|
        @local_overworld_map[ow_id] ||= {}
        @local_overworld_map[ow_id] = data
      end
    end
    #puts @local_players_map
    #puts "there\n\n\n"
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
    return Gosu::Color.new(
      color_hash[:red] || 0,
      color_hash[:green] || 0,
      color_hash[:blue] || 0
    )
  end

  def check_collisions
    @local_overworld_map.each do |_id, ow_data|
      if !ow_data[:x].nil? && !ow_data[:y].nil?
       # puts "collision check on #{_id}"
        if collision?(@x, @y, 50, 50, ow_data[:x], ow_data[:y], 50, 50)
          # kill globally
          #@client.send_data(kill_entity: true, entity_id: _id)
          @client.send_data(type: "overworld_kill", overworld_id: _id)
          
         # puts "clientside"
          #puts @overworld_entities
        end
      end
    end
  end

  def collision?(x1, y1, w1, h1, x2, y2, w2, h2)
    x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2
  end

  private def move_left
    @x -= 5
  end

  private def move_right
    @x += 5
  end

  private def move_up
    @y -= 5
  end

  private def move_down
    @y += 5
  end
end

# Example usage
client = Client.new('localhost', 12345)
client.connect

window = GameWindow.new(client)
window.show

# Close the connection when done
client.close