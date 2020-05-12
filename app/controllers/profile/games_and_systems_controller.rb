class Profile::GamesAndSystemsController < InheritedResources::Base
  defaults :resource_class => User
  # before_filter :authenticate_user!
  respond_to :html

  def show
    @games = Game.active.order(:title)
    @my_games = current_user.games.uniq if current_user
    if @my_games.kind_of?(Array)
      @my_games = Kaminari.paginate_array(@my_games)
    end
    @new_releases = Game.new_releases.limit(10)
  end

  def games
    @games = Game.active.order(:title).page(params[:page]).per(10)
  end

  def my_games
    @my_games = current_user.games.uniq
    if @my_games.kind_of?(Array)
      @my_games = Kaminari.paginate_array(@my_games).page(params[:page]).per(10)
    end
  end

  def update
    resource.validate_game = true
    update!{edit_games_and_systems_path}
  end

  def create
    redirect_to edit_games_and_systems_path
  end

  def destroy
    redirect_to edit_games_and_systems_path
  end

  def add_game
    @ign_duplicate = false
    if params[:user].present? && params[:user][:ign_duplicate] == 'true'
      #allow dublicate IGN
      ign = params_ign?
      current_user.assign_attributes(ign)
      current_user.save
      add_new_game
    else
      ign = params_ign?
      if ign
        if duplicate_ign?(ign)
          @ign_duplicate = true
        else
          current_user.assign_attributes(ign)
          current_user.save
          add_new_game
        end
      else
        add_new_game
      end
    end

    respond_to do |format|
      format.js
      format.html{ redirect_to dashboard_path }
    end

  end

  def check_game
    @game_system = GameSystem.find(params[:sys])
    game = Game.find(params[:game_id])
    game_system_join = GameGameSystemJoin.where(game_id: game.id).where(game_system_id: @game_system.id).first
    if game_system_join.present?
      @already_added_game = GameGameSystemUserJoin.where(game_game_system_join_id: game_system_join.id)
        .where(user_id: current_user.id).present?
      @already_added_game
    end

    @ign_filed =  case @game_system.title
      when 'Xbox One', 'Xbox 360'
        :xbox_live_user_name
      when 'PlayStation 4', 'PlayStation 3'
        :psn_user_name
      when 'Nintendo Wii U'
        :nintendo_user_name
      when 'Nintendo Switch'
        :nintendo_user_name
      when 'PC'
        if params[:title].include?('Steam')
          :steam_user_name
        elsif params[:title].include?('Battle')
          :battle_user_name
        elsif params[:title].include?('Origin')
          :origins_user_name
        end
    end
  end

  private
  def permitted_params
    params.permit(:user => [:psn_user_name, :xbox_live_user_name, :game_game_system_join_ids => []])
  end

  protected
  def resource
    current_user
  end

  #action add_game
  def params_ign?
    if params[:user].present?
      if params[:user][:psn_user_name].present?
        { psn_user_name: params[:user][:psn_user_name] }
      elsif params[:user][:xbox_live_user_name].present?
        { xbox_live_user_name: params[:user][:xbox_live_user_name] }
      elsif params[:user][:nintendo_user_name].present?
        { nintendo_user_name: params[:user][:nintendo_user_name] }
      elsif params[:user][:battle_user_name].present?
        { battle_user_name: params[:user][:battle_user_name] }
      elsif params[:user][:origins_user_name].present?
        { origins_user_name: params[:user][:origins_user_name] }
      elsif params[:user][:steam_user_name].present?
        { steam_user_name: params[:user][:steam_user_name] }
      else
        false
      end
    else
      false
    end
  end

  #action add_game
  def duplicate_ign?(ign_hash)
    User.where.not(id: current_user.id).exists?(["lower(#{ign_hash.keys.first}) = ?", ign_hash.values.first.downcase])
  end

  #action add_game
  def add_new_game
    game = Game.find(params[:game][:id])
    game_system = GameSystem.find(params[:user][:game_system_ids])
    game_system_join = GameGameSystemJoin.where(game_id: game).where(game_system_id: game_system).first
    if GameGameSystemUserJoin.where(game_game_system_join_id: game_system_join.id)
           .where(user_id: current_user.id).empty?
      unless GameGameSystemUserJoin.create(game_game_system_join_id: game_system_join.id, user_id: current_user.id)
        # @errors << 'An error has occurred. Please try again later.'
      end
    else
      # @errors << "#{ game.title } is already in your profile for #{game_system.title}."
    end

  end

end
