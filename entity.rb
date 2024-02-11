# class entity
# def initialize()
#   color, x, y (within frame) randomized 
# def draw
#   Gosu.draw_rect(x, y, 50, 50, color)
#   @font.draw_text(player_data[:player_id].to_s, x - 6, y - 16, 1, 0.8, 0.8, Gosu::Color::WHITE)
# def update
#   check for move, process move
# consider custom serialization (marshal dumping) if there are performance issues down the line

# data handling can become much simpler, just storing hash maps of objects unpacked directly from their marshal data
require_relative 'spritesheet'

class Entity
    attr_reader :x, :y, :color

    def initialize(window)
      @x = rand(500) + 50
      @y = rand(500) + 50
      @spritesheet = Spritesheet.new(window, 'other/testsheet.png', 32, 32)
      @current_frame = 0
      #@color = Gosu::Color.new(255, rand(255), rand(255), rand(255))
      @font = Gosu::Font.new(20)
      @window = window
      @speed = 5
    end
  
    def draw
      @font.draw_text("ENTITY", @x - 6, @y - 16, 1, 0.8, 0.8, Gosu::Color::WHITE)
      @spritesheet.draw(@x, @y)
    end
  
    def update(tick)
      @spritesheet.update(tick)
      move_left if Gosu.button_down?(Gosu::KB_A)
      move_right if Gosu.button_down?(Gosu::KB_D)
      move_up if Gosu.button_down?(Gosu::KB_W)
      move_down if Gosu.button_down?(Gosu::KB_S)

      puts "entity: (#{@x}, #{@y})"
    end
  
    private
  
    def move_left
      @x -= @speed #if @x > 32
    end
  
    def move_right
      @x += @speed #if @x < @window.width - 32
    end
  
    def move_up
      @y -= @speed #if @y > 32
    end
  
    def move_down
      @y += @speed #if @y < @window.height - 32
    end
  
    def window_width
      Gosu::window.width
    end
  
    def window_height
      Gosu::window.height
    end
  end
  