require 'gosu'

class Spritesheet
  attr_reader :frames

  def initialize(window, filename, frame_width, frame_height, frame_speed=20)
    @frames = Gosu::Image.load_tiles(window, filename, frame_width, frame_height, false)
    @num_frames = @frames.length()
    @frame_width = frame_width
    @frame_height = frame_height
    @current_frame = 0
    @frame_speed = frame_speed # every 20 frames this will update
  end

  def draw(x, y)
    @frames[@current_frame].draw_as_quad(
      x - @frame_width / 2, y - @frame_height / 2, Gosu::Color::WHITE,
      x + @frame_width / 2, y - @frame_height / 2, Gosu::Color::WHITE,
      x - @frame_width / 2, y + @frame_height / 2, Gosu::Color::WHITE,
      x + @frame_width / 2, y + @frame_height / 2, Gosu::Color::WHITE,
      0
    )
  end

  def update(tick)
    if tick % @frame_speed == 0
        @current_frame = (@current_frame+1) % @num_frames
    end
  end
end