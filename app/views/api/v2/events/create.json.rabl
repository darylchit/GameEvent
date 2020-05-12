object event
if event.persisted?
  attributes :id
  node(:copy_details) do
    event.event_share_details
  end
  node(:copy_token) do
    event.token
  end
  node(:image) do
    image_path event.game.game_jumbo_mobile.url
  end
else
  attributes :errors
end
