class PathManager

    def self.circlePath(x_center, y_center, radius)
        num_points = 128
        angle_increment = (2 * Math::PI) / num_points
      
        circle_points = []
      
        num_points.times do |i|
          angle = i * angle_increment
          point_x = x_center + radius * Math.cos(angle)
          point_y = y_center + radius * Math.sin(angle)
      
          circle_points << [point_x, point_y]
        end
      
        circle_points
      end

end