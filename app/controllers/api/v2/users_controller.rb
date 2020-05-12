class Api::V2::UsersController < Api::V2::BaseController

  expose :players do
    if params[:term].present? && params[:term].size > 2
      search_key = "%#{params[:term]}%"
      User.where(show_on_playerlist: true)
      .where('id NOT IN (?)', current_user.blocked_by_users.ids << 0)
      .where('username ILIKE ? ' +
            'OR psn_user_name ILIKE ? '+
            'OR xbox_live_user_name ILIKE ? '+
            'OR nintendo_user_name ILIKE ? '+
            'OR battle_user_name ILIKE ? '+
            'OR origins_user_name ILIKE ?'+
            'OR steam_user_name ILIKE ?', search_key, search_key, search_key, search_key, search_key, search_key, search_key)
    end
  end
end
