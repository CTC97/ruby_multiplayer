x = 2
y = 3

array = [
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
  [10, 11, 12, 13, 14, 15, 16, 17, 18],
  [19, 20, 21, 22, 23, 24, 25, 26, 27],
  [28, 29, 30, 31, 32, 33, 34, 35, 36],
  [37, 38, 39, 40, 41, 42, 43, 44, 45],
  [46, 47, 48, 49, 50, 51, 52, 53, 54],
  [55, 56, 57, 58, 59, 60, 61, 62, 63],
  [64, 65, 66, 67, 68, 69, 70, 71, 72],
  [73, 74, 75, 76, 77, 78, 79, 80, 81]
]



def get_relevant_tiles(array, row_position, col_position)
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

  puts "#{get_relevant_tiles(array, 2, 2)}"