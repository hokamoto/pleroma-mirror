# Message parser for the PixelBot
# Parses Mastodon/Pleroma message for 2 types of pixel formats
# WV
defmodule Pleroma.Bots.PixelBot.ParseMessage do

  @colour_map %{
    "black" => 0, #000    
    "red" => 4, #100
    "green" => 2, #010
    "blue" => 1, #001
    "cyan" => 3, #011 
    "yellow" => 6, #110
    "magenta" => 5, #101
    "white" => 7, #111
    "K" => 0, #000    
    "R" => 4, #100
    "G" => 2, #010
    "B" => 1, #001
    "C" => 3, #011 
    "Y" => 6, #110
    "M" => 5, #101
    "W" => 7, #111
    "gray" => 8, # special
    "grey" => 9, # specia
    "0" => 0, #000    
    "4" => 4, #100
    "2" => 2, #010
    "1" => 1, #001
    "3" => 3, #011 
    "6" => 6, #110
    "5" => 5, #101
    "7" => 7, #111
    "8" => 8, # special
    "9" => 9 # specia
  }


  def get_pixels_from_message(msg) do 
    # messages apparently look like 
    # <p><span class="h-card"><a href="https://pynq.limited.systems/users/pixelbot" class="u-url mention">@<span>pixelbot</span></a></span> <br />1,1,2<br />2,2,3<br />5,5,6</p>
    # <p><span class="h-card"><a href="https://pynq.limited.systems/users/pixelbot" class="u-url mention">@<span>pixelbot</span></a></span> <br />1 2 3<br />4 5 6<br />7 8 0</p>
    # I tested this from octodon and cybre
    # But I think in Pleroma it's simply <br> and not wrapped in a </p>
    # So I need to replace the br with a nl and then feed it into the 
    #
    # First remove the header
    # Thenremove everything up to </span>
    msg_chunks=String.split(msg,"</span>")
    msg_body = List.last(msg_chunks)
    #pixels_str=String.slice(msg_body,0..-5)
    pixels_str = Regex.replace(~r/\<\/p\>$/,msg_body,"")
    #IO.puts("<"<>pixels_str<>">" )
    #IO.inspect( String.split(String.trim(pixels_str),"<br />") )
    # TEST
    if Regex.match?(~r/\d+[,\s]\d+[,\s]/,pixels_str) do
      pixels_str_trimmed = Regex.replace(~r/^.*?(\d)/,pixels_str,"\\1")
      regex_parse(pixels_str_trimmed)
    else 
      if Regex.match?(~r/[0-9A-Fa-f]{6}[0-7]/,pixels_str) do
        parse_compact(pixels_str)
      else
        []
      end
    end
    #[{1,1,2},{2,2,3},{3,3,4}]
  end
  # So what I need is to parse some formats like this:
  # \d+ \d+ \w+ or \d+\d+ \d or allow commas too, one per line
  # The regex supports <int X><space or comma><int Y><space or comma><colour names, single-char abbrev or numerical value><newline>
  # If the regex fails I'm not sure what happens
  def regex_parse(text) do
    regex = ~r/^\s*(\d+)\s*[,\s]\s*(\d+)\s*[,\s]\s*(\d|[CMYKRGBW]|[a-z]{3,})\s*$/i
    br_capt = Regex.named_captures(~r/(?<br>\<br\s*\/?\>)/, text)
    #IO.inspect(br_capt)
    maybe_pixels = if is_nil(br_capt) do
      [text]
    else
      String.split(String.trim(text),br_capt["br"])
    end
    IO.inspect(maybe_pixels)
    res = Enum.filter(maybe_pixels,fn(x) -> x != "" end)
    |> Enum.map( fn(line) -> Regex.scan(regex, line) end)    #
    #IO.inspect(res)
    #IO.puts(length(res))
    #IO.inspect(List.first(res))
    #IO.inspect(length(List.first(res)))
    if (length(res)==1 and length(List.first(res))==0) do
      []
    else  
      Enum.map(res,fn(x) -> List.first x end )
      |> Enum.map(fn([_|t]) -> t end)    
      |> Enum.map( fn( [x,y,clr] ) -> { String.to_integer(x), String.to_integer(y),colour_to_code(clr)} end)
    end
  end  
  # If the provided colour is not valid, returns 0
  def colour_to_code(clr) do    
    if String.length(clr)==1 do
      Map.get(@colour_map,String.upcase(clr),0)
    else
      Map.get(@colour_map,String.downcase(clr),0)
    end
    #    IO.puts Map.get(@colour_map,String.downcase(clr),clr)
    #IO.puts res
    #res
  end
  # This is a parser for a more compact format:
  # A string of sets of 3+3+1 characters
  # X-coord as hex, Y coord as hex, color as 0..7
  def fsm_parse(text,state, chunks) do
    if String.length(text) == 0 do chunks
    else 
      if state == 0 do
        {chunk,rest}=String.split_at(text, 3)
        fsm_parse(rest,1,chunks++[chunk])
      else 
        if state == 1 do
          {chunk,rest}=String.split_at(text, 3)
          fsm_parse(rest,2,chunks++[chunk])
        else
          {chunk,rest}=String.split_at(text, 1)
          fsm_parse(rest,0,chunks++[chunk])
        end
      end
    end
  end
  # The result is a flat list, I need to split it
  def split_into_triplets(flat_list,pix_list) do
    [ x | [y | [c | rest]] ] = flat_list
    pix_list_ = pix_list++[{x,y,Integer.mod(c,8)}]
    if length(rest)==0 do
      pix_list_
    else
      split_into_triplets(rest,pix_list_)
    end
  end
  def parse_compact(text) do
    trimmed_str= String.trim( text )
    str_len = String.length(trimmed_str)
    trim_to_7chars = str_len - Integer.mod(str_len,7)
    #IO.puts("<"<>trimmed_str<>">")
    trimmed_str_=String.slice(trimmed_str,0,trim_to_7chars)
    flat_list = fsm_parse(trimmed_str_ ,0,[])
                    |> Enum.map( fn( str ) -> String.to_integer(str, 16) end)
    split_into_triplets(flat_list,[])
  end
  def show(lst) do
    Enum.join(lst,",")
    |> IO.puts
  end

end # of ParseMessage
#
#msg1 = "<p><span class=\"h-card\"><a href=\"https://pynq.limited.systems/users/pixelbot\" class=\"u-url mention\">@<span>pixelbot</span></a></span> 1f41a420ff0ff11aa1bb3</p>"
#
#res1 = Pleroma.Bots.PixelBot.ParseMessage.get_pixels_from_message(msg1)
#IO.inspect(res1)
#
#msg2 = "<p><span class=\"h-card\"><a href=\"https://pynq.limited.systems/users/pixelbot\" class=\"u-url mention\">@<span>pixelbot</span></a></span> 1,2,3<br>4,5,6<br></p>"
#
#res2 = Pleroma.Bots.PixelBot.ParseMessage.get_pixels_from_message(msg2)
#IO.inspect(res2)
#

#MyTests.show( "1f41a420ff0ff11aa1bb3" )

#text="
#11 22 C
#33,44,yellow
#55,6,3
#1 2 magenta
#101 42 BLACK
#"
#MyTests.regex_parse(text)
#|> Enum.map( fn({x,y,c}) -> "#{x} #{y} #{c}" end )
#|> Enum.join( ";" )
#|> IO.puts

