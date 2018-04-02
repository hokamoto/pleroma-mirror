# WV: server for the pixelbot. 
# I need to incorporate the parser code here to extract the pixels from the message
defmodule Pleroma.Bots.PixelBot do
  use GenServer
  alias Pleroma.Bots.PixelBot.ParseMessage  
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

## Callbacks

  def init({canvas_w,canvas_h}) do
     canvas = init_canvas(canvas_w,canvas_h)
    {:ok, canvas}
  end

  def handle_call(msg, _from, canvas) do
    pixels = ParseMessage.get_pixels_from_message(msg)
    #IO.inspect(pixels)
    updated_canvas = update_canvas(pixels,canvas)
    {:reply, updated_canvas, updated_canvas}
  end

  def handle_cast( msg, canvas) do
    pixels = ParseMessage.get_pixels_from_message(msg)
    #IO.inspect(pixels)
    updated_canvas = update_canvas(pixels,canvas)
    {:noreply, updated_canvas}
  end

  def update_canvas(pixels,canvas) do
    # pixels is a list of tuples
    # for every tuple we need to update the canvas so this is a fold
    updated_canvas = List.foldl(pixels,canvas, fn(pixel, canvas) -> update_single_pixel(pixel, canvas) end )
    # So now we should write this to a PNG
    # Easiest way will be to write to CSV and then do a system call
    write_canvas_to_csv(updated_canvas)
    create_png_via_system_call()
    #IO.inspect( updated_canvas )
    updated_canvas
  end

  def update_single_pixel(pixel,canvas) do
    {xx,yy,colour}=pixel
    canvas_h=length(canvas)
    canvas_w=length(List.first(canvas))
    #IO.puts("#{xx} % #{canvas_w},#{yy} % #{canvas_h}")
    x = Integer.mod(xx,canvas_w)
    y = Integer.mod(yy,canvas_h)
    #IO.puts "Updating pixel #{x},#{y} to colour #{colour}"
    {row_at_x, canvas_min_row} = List.pop_at(canvas,x)
    
    updated_row_at_x = List.replace_at(row_at_x,y,colour)
    List.insert_at(canvas_min_row, x, updated_row_at_x)
  end

  def init_canvas(w,h) do
    # If a canvas.csv file exists we should load that one first
    canvas_from_csv = read_canvas_from_csv()
    if length(canvas_from_csv)==0 do
      row = List.duplicate(0,w)
      canvas = List.duplicate(row,h)
      canvas
    else
      # TODO: deal with canvas of different size
      canvas_from_csv
    end
      #Enum.map(canvas, fn(row) -> Enum.map(row,fn(elt) -> IO.puts(elt) end ) end)
      #canvas
  end
  def read_canvas_from_csv() do
    {:ok,wd }= File.cwd()
    file_path = wd <>"/pixelbot/canvas.csv"
    IO.puts( file_path )
    {status, file} = File.open(file_path,[:read,:utf8])
    if status != :ok do
      []
    else
      csv_str = IO.read(file, :all) 
      #IO.inspect(csv_str)
      row_strs = String.split(csv_str,"\n")
                 |> Enum.filter(fn(str) -> str != "" end)
      IO.inspect(row_strs)
      Enum.map(row_strs, fn(row_str) -> String.split(row_str,",") |> Enum.map(fn(elt) -> String.to_integer(elt) end) end)
    end
  end  
    
  def write_canvas_to_csv(canvas) do
    # WV: how to change this to a relative path? Using CWD but how?
    {:ok,wd }= File.cwd()
    file_path = wd <>"/pixelbot/canvas.csv"
    csv_str = create_csv_str_from_canvas(canvas) 
    #IO.puts("Writing CSV file " <> csv_str <> " to " <> file_path)
    File.write(file_path,csv_str)
  end

  def create_csv_str_from_canvas(canvas) do
    Enum.map(canvas,fn(row) -> Enum.join(row,",") end)
    |> Enum.join("\n")
  end

  def create_png_via_system_call() do
    System.cmd("/home/pleroma/pleroma/pixelbot/create_png_from_csv",[])
  end

end

