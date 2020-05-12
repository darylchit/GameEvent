class Profile::FavoritesController < InheritedResources::Base
	defaults :resource_class => Favorite
	before_filter :authenticate_user!
	respond_to :html, :js

  def new
    @favorited_user = User.find params[:favorited_user_id]

    is_error = !is_valid_favorite(@favorited_user)

    if is_error
      render text: ''
      return
    end

    @favorite = Favorite.new
    @favorite.favorited_user = @favorited_user
    super
  end

	def create
    @favorited_user = User.find params[:favorite][:favorited_user_id]

    # Prebuild the new record so that we can respond with the actual record
    @new_favorite = current_user.favorites.find_or_create_by(user_id: current_user.id, favorited_user_id: @favorited_user.id)


    @favorite = params[:favorite]
    respond_to do |format|
        format.html {
          flash[:notice] = "#{@favorited_user.username} has been added to your favorites"
          redirect_to redirect_path
        }
        format.js {render :layout => false}
    end
	end

	def destroy
    username = resource.favorited_user.username

    @favorite = resource
     destroy! do |format|
      format.html do
        flash[:notice] = "#{username} has been removed from your favorites"
        redirect_to redirect_path
      end
      @total_favorites = current_user.favorites.count
      format.js{}
     end
	end

	private
    def permitted_params
  		params.permit(:favorited_user_id, favorite: [:favorited_user_id])
    end
	
	protected
    def begin_of_association_chain
      current_user
    end

    def is_valid_favorite(favorited_user)
      if favorited_user != current_user && !current_user.favorites.where(:favorited_user_id => favorited_user.id).exists? 
        true
      end
    end

    def redirect_path
			request.referer
    end

    def favorites_path
      profiles_path + '/' + current_user.username + '/favorites'
    end
end
