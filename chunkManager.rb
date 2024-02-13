class ChunkManager
    attr_reader :chunk_map

    # CREATE A COLLISION TILES ATTRIBUTE

    def initialize(x_dim, y_dim)
        @chunk_map = {}
        @x_dim = x_dim
        @y_dim = y_dim

        @collision_set = [4,5,6,7,8]

        @seed_map = {
           # 0 => [0],
            1 => [1,2,3],
            2 => [1,2,3],
            3 => [1,2,3],
            4 => [4,5,6,7,8],
            5 => [4,5,6,7,8],
            6 => [4,5,6,7,8],
            7 => [4,5,6,7,8],
            8 => [4,5,6,7,8]
        }
    end

    def generate_chunk(chunk_x, chunk_y)
        chunk = Array.new(@y_dim) { Array.new(@x_dim) }
      
        # initial layout and seeding

        @y_dim.times do |y| # y
            @x_dim.times do |x| # x
              chunk[y][x] = 0
      
              chunk[y][x] = 2 if rand(50) < 1 
              chunk[y][x] = 1 if rand(50) < 1 
              chunk[y][x] = 3 if rand(50) < 1 
              chunk[y][x] = 4 if rand(100) < 1
              chunk[y][x] = 5 if rand(100) < 1
              chunk[y][x] = 6 if rand(100) < 1
              chunk[y][x] = 7 if rand(100) < 1
              chunk[y][x] = 8 if rand(100) < 1
            end
          end
      
          @y_dim.times do |y|
              @x_dim.times do |x|
      
                convert_strength = nil
      
                convert_strength = 60 if [1,2,3].include?(chunk[y][x])
                convert_strength = 20 if [4,5,6,7,8].include?(chunk[y][x])
            
      
                if chunk[y][x] != 0
                  # Adjust these probabilities as needed
                  if rand(100) < convert_strength
                    neighbor_x = x + rand(-1..1)
                    neighbor_y = y + rand(-1..1)
          
                    # Ensure the neighbor is within bounds
                    if (0..(@x_dim - 1)).cover?(neighbor_x) && (0..(@y_dim - 1)).cover?(neighbor_y)
                      chunk[neighbor_y][neighbor_x] = @seed_map[chunk[y][x]].sample
                    end
                  end
                end
              end
            end
      
            @y_dim.times do |y|
              @x_dim.times do |x|
                if chunk[y][x] != 0
                  rand(5).times do
                    neighbor_x = x + rand(-1..1)
                    neighbor_y = y + rand(-1..1)
          
                    next unless (0..(@x_dim - 1)).cover?(neighbor_x) && (0..(@y_dim - 1)).cover?(neighbor_y)
          
                    # Convert the neighbor with a probability
                    chunk[neighbor_y][neighbor_x] = chunk[y][x] if rand(100) < 30
                  end
                end
              end
            end

            @y_dim.times do |y| 
              @x_dim.times do |x|
                if (y < 3 || y > @y_dim -3 || x < 3 || x > @x_dim - 3) && @collision_set.include?(chunk[y][x])
                  chunk[y][x] = 0
                end
              end
            end

      
        chunk_key = [chunk_x, chunk_y]
        @chunk_map[chunk_key] = Marshal.dump(chunk)
        #puts retreive_relevant_chunks(0, 0)
        chunk
    end

    # pull the 8 squares around x and y
    # [] entity - the entity we're checking
    # [x] entityChunk - the [x,y] pair to lookup the chunk the entity is in
    # [] tilLoc - the x,y position of the tile the player is currently on
    # [] tile_width, tile_height - the dimensions of the tiles in the set
    # [] collision tiles - array of tiles that are solid
    def check_entity_collision(entity, entityChunk, tileLoc, tile_width, tile_height, collision_tiles)     
        puts "checking entity collision #{entity}, #{entityChunk}, #{tileLoc}"   
        chunk = Marshal.load(@chunk_map[entityChunk])

        tile_x = tileLoc[0]
        tile_y = tileLoc[1]


        relevant_tiles = get_relevant_tiles_for_collision(chunk, tile_x, tile_y)

        puts "#{relevant_tiles}"

        if !relevant_tiles.nil?
            relevant_tiles.each_with_index do |row, cell_y|
                # Iterate over each element in the row
                row.each_with_index do |element, cell_x|
                    # Call the function on each element
                    next if !collision_tiles.include?(element)

                    local_tile_x = (tile_x) + (cell_x - 1)
                    local_tile_y = (tile_y) + (cell_y - 1)

                    tile_global_x = (entityChunk[0] * 16) * 64 + local_tile_x * 64
                    tile_global_y = (entityChunk[1] * 16) * 64 + local_tile_y * 64
                    puts "tile at : [#{entityChunk[0]}, #{entityChunk[1]}] | [#{local_tile_x}, #{local_tile_y}] | [#{tile_global_x}, #{tile_global_y}]"
                    entity.handle_collision(element, collision_tiles, tile_global_x, tile_global_y, tile_width, tile_height)
                end
            end
        end
    end


    def get_relevant_tiles_for_collision(array, col_position, row_position)
        #puts "checking #{array}, #{row_position}, #{col_position}"
        # Define the size of the smaller arrays (3x3)
        small_array_size = 3
      
        # Check if the specified position is within bounds
        if row_position >= 0 && row_position + small_array_size <= array.length &&
           col_position >= 0 && col_position + small_array_size <= array[0].length
      
          # Grab the specified 3x3 array
          small_array = array[row_position-1, small_array_size].map { |r| r[col_position-1, small_array_size] }
          return small_array
        else
          # If out of bounds, return nil or handle it as needed
          return nil
        end
    end

    def retreive_relevant_chunks(pchunk_coords)
        pchunk_x, pchunk_y = pchunk_coords[0], pchunk_coords[1]
        #puts "retreiving relevant chunks around (#{pchunk_x}, #{pchunk_y})"
        chunk_keys = [
            [[pchunk_x-1, pchunk_y-1], [pchunk_x, pchunk_y-1], [pchunk_x+1, pchunk_y-1]],
            [[pchunk_x-1, pchunk_y], [pchunk_x, pchunk_y], [pchunk_x+1, pchunk_y]],
            [[pchunk_x-1, pchunk_y+1], [pchunk_x, pchunk_y+1], [pchunk_x+1, pchunk_y+1]]
        ]

        #puts "relevant: #{chunk_keys}"

        relevant_chunks = Array.new(3){Array.new(3)}
    
        chunk_keys.each_with_index do |row, y|
            row.each_with_index do |pair, x|
                if @chunk_map.key?(pair)
                    relevant_chunks[x][y] = Marshal.load(@chunk_map[pair])
                # if we haven't already generated it, generate a chunk
                else
                    #puts "generating :: #{pair[0]}, #{pair[1]}"
                    relevant_chunks[x][y] = generate_chunk(pair[0], pair[1])
                end
            end
          end

       # puts "relevant: #{relevant_chunks}"
        relevant_chunks
    end
end
