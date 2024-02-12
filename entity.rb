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
      @canMoveLeft = @canMoveRight = @canMoveUp = @canMoveDown = true
      @width = 32 # pull out to parameter
      @height = 32 # pull out to parameter
      @spritesheet = Spritesheet.new(window, 'other/testsheet.png', @width, @height)
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
      move_left if Gosu.button_down?(Gosu::KB_A) && @canMoveLeft
      move_right if Gosu.button_down?(Gosu::KB_D) && @canMoveRight
      move_up if Gosu.button_down?(Gosu::KB_W) && @canMoveUp
      move_down if Gosu.button_down?(Gosu::KB_S) && @canMoveDown
      @canMoveLeft = @canMoveRight = @canMoveUp = @canMoveDown = true
    end

    def fetch_chunk(tileSize, chunkSize)
        [(@x / tileSize) / chunkSize, (@y / tileSize) / chunkSize]
    end

    def fetch_tile(tileSize, chunkSize)
        [(@x / tileSize) % chunkSize, (@y / tileSize) % chunkSize]
    end
    
    # tile_x, tile_y - global position of tile in question
    # tile_width, tile_height - self explanatory
    def handle_collision(tile_val, collision_tiles, tile_x, tile_y, tile_width, tile_height)
      #puts "checking #{tile_val} at #{tile_x}, #{tile_y}"

      # # Calculate the boundaries of the colliding tile
      tile_right = tile_x + tile_width
      tile_bottom = tile_y + tile_height
    
      # # Calculate the boundaries of the entity
      entity_left = @x
      entity_right = @x + @width
      entity_top = @y
      entity_bottom = @y + @height
    
      puts "checking collision"

      # Check for intersection
      if entity_right > tile_x && entity_left < tile_right &&
         entity_bottom > tile_y && entity_top < tile_bottom
        # Collision detected, adjust entity position
        #puts "collision!"
        adjust_entity_position(tile_x, tile_y, tile_width, tile_height)
      end
    end

    def adjust_entity_position(tile_x, tile_y, tile_width, tile_height)
      puts "ADJUSTING"
      
      # Determine the direction of the collision (left, right, top, or bottom)
      x_collision = @x + @width / 2 < tile_x + tile_width / 2
      y_collision = @y + @height / 2 < tile_y + tile_height / 2
    
      # Adjust the entity's position based on the collision direction
      if x_collision
        @canMoveRight = false
      else
        @canMoveLeft = false
      end
    
      if y_collision
        @canMoveDown = false
      else
        @canMoveUp = false
      end
    end

    private
  
    def move_left
      oldX = @x
      @x -= @speed #if @x > 32
      if !@canMoveLeft
        @x = oldX
      end
    end
  
    def move_right
      oldX = @x
      @x += @speed #if @x > 32
      if !@canMoveRight
        @x = oldX
      end
    end
  
    def move_up
      oldY = @y
      @y -= @speed #if @x > 32
      if !@canMoveUp
        @y = oldX
      end
    end
  
    def move_down
      oldY = @y
      @y += @speed #if @x > 32
      if !@canMoveDown
        @y = oldX
      end
    end
  
    def window_width
      Gosu::window.width
    end
  
    def window_height
      Gosu::window.height
    end
  end
  