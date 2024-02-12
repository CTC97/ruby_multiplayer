class ChunkManager
    attr_reader :chunk_map

    def initialize(x_dim, y_dim)
        @chunk_map = {}
        @x_dim = x_dim
        @y_dim = y_dim
    end

    def generate_chunk(chunk_x, chunk_y)
        chunk = Array.new(@y_dim) { Array.new(@x_dim) }
      
        @y_dim.times do |i|
          @x_dim.times do |j|
            chunk[i][j] = rand(4)  

            # dont spawn chest at the edge of a chunk
            if !(i < 3 || i > 12 || j < 3 || j > 12)
                bit = rand(25) == 0 ? 1 : 0
                chunk[i][j] = 4 if bit == 1
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
