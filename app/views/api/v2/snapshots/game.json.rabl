attributes :id, :title
node(:release_date) do |game|
  if game.release_date.present?
    short_date(game.release_date)
  else
    game.release_date
  end
end
node(:image) do |game|
  image_path game.game_jumbo.url
end
node(:image_mobile) do |game|
  image_path game.game_jumbo_mobile.url
end
