if favorites.present?
  child favorites, root: :favorites, :object_root => false do
    extends "api/v2/favorites/favorite"
  end
else
  node(:favorites)do
    []
  end
end
if clans.present?
  child clans, :object_root => false do
    extends "api/v2/favorites/clan"
  end
else
  node(:clans)do
    []
  end
end
