class Camera
    def initialize(window, target)
      @window = window
      @target = target
    end
  
    def update
      # Adjust the camera position based on the player's position
      @x = @target.x - @window.width / 2
      @y = @target.y - @window.height / 2
    end
  
    def translate
      # Use Gosu.translate to adjust the rendering position
      Gosu.translate(-@x, -@y) { yield }
    end
  end