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
          end
        end
      
        chunk_key = [chunk_x, chunk_y]
        @chunk_map[chunk_key] = Marshal.dump(chunk)
        #puts retreive_relevant_chunks(0, 0)
        chunk
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
