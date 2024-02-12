def generate_chunk
    @x_dim = 16
    @y_dim = 16

    chunk = Array.new(@y_dim) { Array.new(@x_dim) }
  
    # initial layout and seeding

    @y_dim.times do |y| # y
      @x_dim.times do |x| # x
        chunk[y][x] = 0

        chunk[y][x] = 1 if rand(10) < 1 
        chunk[y][x] = 2 if rand(300) < 1 
        chunk[y][x] = 3 if rand(500) < 1 
      end
    end

    @y_dim.times do |y|
        @x_dim.times do |x|

          convert_strength = nil

          convert_strength = 30 if chunk[y][x] == 1
          convert_strength = 50 if chunk[y][x] == 2
          convert_strength = 40 if chunk[y][x] == 3

          if chunk[y][x] != 0
            # Adjust these probabilities as needed
            if rand(100) < convert_strength
              neighbor_x = x + rand(-1..1)
              neighbor_y = y + rand(-1..1)
    
              # Ensure the neighbor is within bounds
              if (0..(@x_dim - 1)).cover?(neighbor_x) && (0..(@y_dim - 1)).cover?(neighbor_y)
                puts "converting #{chunk[neighbor_y][neighbor_x]} to #{chunk[y][x]}"
                chunk[neighbor_y][neighbor_x] = chunk[y][x]
              end
            end
          end
        end
      end

      @y_dim.times do |y|
        @x_dim.times do |x|
          if chunk[y][x] != 0
            rand(9).times do
              neighbor_x = x + rand(-1..1)
              neighbor_y = y + rand(-1..1)
    
              next unless (0..(@x_dim - 1)).cover?(neighbor_x) && (0..(@y_dim - 1)).cover?(neighbor_y)
    
              # Convert the neighbor with a probability
              chunk[neighbor_y][neighbor_x] = chunk[y][x] if rand(100) < 30
            end
          end
        end
      end
  
    puts "#{chunk}"
end

generate_chunk