defmodule Pleroma.Bots.PixelBot.PostStatus do

  # I can use CommonAPI.post to create the activity from the simple status
  # For the user I can use  Repo.get(User, 2599)
  # post() returns an activity but the attachment is not there
  # But likely I can put this easily enough into the activity 

  def pixelbot_post_status() do
    now = DateTime.to_string(DateTime.utc_now())
    nickname="pixelbot"
    user = Pleroma.User.get_cached_by_nickname(nickname)
    visibility = "public" #get_visibility(data)

    
    to =  ["https://www.w3.org/ns/activitystreams#Public"]
    cc =  ["https://pynq.limited.systems/users/pixelbot/followers"]
    #IO.inspect({to,cc})

    #context = "https://pynq.limited.systems/contexts/9081f11a-a310-4bb9-9a1c-176d32ba239a"
    context = "https://pynq.limited.systems/contexts/pixelbot-dummy-context"
    object = %{"actor" => "https://pynq.limited.systems/users/pixelbot",
            "attachment" => [%{"name" => "canvas_512x512.png", "type" => "Image",
              "url" => [%{"href" => "https://pynq.limited.systems/pixelbot/canvas_512x512.png",
                "mediaType" => "image/png", "type" => "Link"}],
              #"uuid" => "fe581bfd-bdf3-4969-84ee-c5e5ed26a6c7"
              "uuid" => "pixelbot-dummy-uuid"
            }],
            "cc" => ["https://pynq.limited.systems/users/pixelbot/followers"],
            "content" => "Canvas at "<>now<>"<br><a href=\"https://pynq.limited.systems/pixelbot/canvas_512x512.png\" class='attachment'>canvas.png</a>",
      #"context" => "https://pynq.limited.systems/contexts/9081f11a-a310-4bb9-9a1c-176d32ba239a",
            "context" => context,
            "emoji" => %{}, "summary" => nil, "tag" => [],
            "to" => ["https://www.w3.org/ns/activitystreams#Public"], "type" => "Note"
          }

    res =
            Pleroma.Web.ActivityPub.ActivityPub.create(%{
              to: to,
              actor: user,
              context: context,
              object: object,
              additional: %{"cc" => cc}
            })
    Pleroma.User.increase_note_count(user)
    res
  end  

end

