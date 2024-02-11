require 'gosu'

class Tilesheet
  attr_reader :frames, :frame_width, :frame_height

  def initialize(filename, frame_width, frame_height)
    @frames = Gosu::Image.load_tiles(filename, frame_width, frame_height, {tileable: true, retro: true})
    @num_frames = @frames.length()
    @frame_width = frame_width
    @frame_height = frame_height
  end

  def draw(x, y, frame)
    #puts ("in tilesheet drawing frame [#{frame}]")
    @frames[frame].draw_as_quad(
      x, y, Gosu::Color::WHITE,
      x + @frame_width, y, Gosu::Color::WHITE,
      x, y + @frame_height, Gosu::Color::WHITE,
      x + @frame_width, y + @frame_height, Gosu::Color::WHITE,
      0
    )
  end
end