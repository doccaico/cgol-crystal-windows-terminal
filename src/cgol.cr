GRID_X = 100
GRID_Y = 25
GRID_SIZE = GRID_Y * GRID_X
INITIAL_ALIVES = 60
DELAY = 1.0 / 30.0 
DEAD_CELL = "."
ALIVE_CELL = "*"

enum Cell
  Dead
  Alive
end

class App
  @temp_grid : StaticArray(Cell, GRID_SIZE)
  @main_grid : StaticArray(Cell, GRID_SIZE)

  def initialize
    @temp_grid = StaticArray(Cell, GRID_SIZE).new(Cell::Dead)
    @main_grid = StaticArray(Cell, GRID_SIZE).new(Cell::Dead)

    alives_placed = 0
    while alives_placed < INITIAL_ALIVES * GRID_Y
      random_index = rand(GRID_SIZE)
      if @main_grid[random_index].dead?
        @main_grid[random_index] = Cell::Alive
        alives_placed += 1
      end
    end
  end

  def draw
    grid_str = String.build(GRID_SIZE+GRID_Y) do |sb|
      GRID_Y.times do |y|
        GRID_X.times do |x|
          index = y * GRID_X + x
          cell = @main_grid[index]
          sb << (cell == Cell::Dead ? DEAD_CELL : ALIVE_CELL)
        end
        sb << "\n"
      end
    end
    print grid_str
  end

  def count_neighbors(grid, x, y)
    count = 0

    (-1..1).each do |dy|
      (-1..1).each do |dx|
        # Exclude self (dx = 0 and dy = 0)
        next if dx == 0 && dy == 0

        nx = x + dx
        ny = y + dy

        # Check if within grid bounds
        if nx >= 0 && nx < GRID_X && ny >= 0 && ny < GRID_Y
          # Convert to 1D index and check state
          index = ny * GRID_X + nx
          if grid[index].alive?
            count += 1
          end
        end
      end
    end
    count
  end

  def update
    GRID_Y.times do |y|
      GRID_X.times do |x|
        neighbors = count_neighbors(@main_grid, x, y)
        index = y * GRID_X + x
        current_state = @main_grid[index]
        if current_state == Cell::Alive
          @temp_grid[index] = neighbors <= 1 || neighbors >= 4 ? Cell::Dead : Cell::Alive
        else
          @temp_grid[index] = neighbors == 3 ? Cell::Alive : Cell::Dead
      end
    end
  end
  @main_grid.to_unsafe.copy_from(@temp_grid.to_unsafe, GRID_SIZE)
  end

  def sleep
    sleep DELAY.seconds
  end

  def clear
    print "\x1b[H"
  end

  def run
    print "\x1b[2J"

    loop do
      clear
      draw
      update
      sleep
    end
  end

end

app = App.new
app.run
