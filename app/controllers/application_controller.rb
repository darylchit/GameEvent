class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	before_filter :login_from_web_token
	# before_filter :beta_code!
	protect_from_forgery with: :exception
	before_filter :store_location,  unless: :devise_controller?
	before_action :configure_permitted_parameters, if: :devise_controller?
	before_filter :interrupt_user, unless: :devise_controller?
	#before_action :check_site_password
	around_filter :set_timezone
	helper_method :is_mobile_app?
	helper_method :mobile_request?
	helper_method :current_subscription

	#badges
	include HomeQuery
	expose :message_count, :build_message_count
	expose :clan_events, :build_clan_events
	expose :invitations, :build_invitations
  expose :upcoming_events, :build_upcoming_events

	def is_mobile_app?
		request.headers["X-Mobile-App"].present? && request.headers["X-Mobile-App"] == "true"
	end

	def mobile_request? # has to be in here because it has access to "request"
		request.user_agent =~ /\b(Android|iPhone|iPad|Windows Phone|Opera Mobi|Kindle|BackBerry|PlayBook)\b/i
	end

	def current_subscription
		if current_user.present?
			current_user.active_subscription
		end
	end

	protected

		def configure_permitted_parameters
			devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(
					:username,
					:email,
					:password,
					:password_confirmation,
					:remember_me,
					:first_name,
					:last_name,
					:address_1,
					:address_2,
					:country,
					:city,
					:state,
					:zipcode,
					:avatar,
					:timezone
				) }
			devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
			devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
		end

		def after_sign_in_path_for(resource)
			# Check if the user tried to get into a public event first
			# ignore some paths that we do not want to return to after signin
			# root_path
			#ignore_paths = []
			# session.delete(:previous_url) if ignore_paths.include?(session[:previous_url])
			session[:previous_url] || root_path
		end

		def after_sign_out_path_for(resource_or_scope)
			root_path
		end

		def store_location
			# save location of unauthenticated user location to return them here after login
			session[:previous_url] = request.fullpath
		end

		helper_method :get_resource
		def get_resource
			self.send(:get_resource_ivar) rescue nil
		end

		def set_timezone
			if current_user.present?
				Time.use_zone(current_user.timezone) { yield }
			elsif current_admin.present?
				Time.use_zone('Eastern Time (US & Canada)') { yield }
			else
				yield
			end
		end

		def check_site_password
			has_password = Rails.configuration.site_password.present? rescue false
			redirect_to site_password_path unless !has_password || cookies[:site_password] == Rails.configuration.site_password
		end

    def interrupt_user
      # NOTE: this will be run on every get request for logged in user, can be expensive.
      # if the user is logged in and does not have a country set, then redirect to set
      #
			return unless !admin_signed_in?
      # only interrupt get requests
      return unless request.get?

      # only interrupt if user is logged in
      return unless user_signed_in?

      # leave ajax alone
      return if request.xhr?

      # prevent looping since this is our destination
      return if controller_path.eql?('profile/country')



			#after sign up for builld profile
			return redirect_to users_profile_path unless current_user.profile_valid?
			#remove old IGN pc_user_name
			return if request.path.eql?('/profile/edit') && current_user.pc_user_name.present? && current_user.new_ign_empty?
			return redirect_to edit_profile_path if current_user.pc_user_name.present? && current_user.new_ign_empty?
      # return redirect_to edit_profile_country_path unless current_user.valid_country?


			return if controller_path.eql?('subscriptions') && action_name.eql?('promotional')
			return redirect_to subscriptions_promotional_path if current_user.active_subscription.present? && current_user.active_subscription.promotional? && !current_user.active_subscription.read?

			#removed
			#return if controller_path.eql?('announcements')
      #return redirect_to announcements_path if current_user.has_announcements?
    end

		def authenticate_user_from_token!
			user_email = params[:user_email].presence
			user = user_email && User.find_by_email(user_email)
			if user && Devise.secure_compare(user.authentication_token, params[:user_token])
				sign_in user, store: false
			end
		end

		def beta_code!
			unless request.fullpath.include?('api/v2') || Rails.env.development?
				if session[:betacode] != 'btgrn' && !(['/betas/new','/betas'].include?(request.fullpath))
					sign_out current_user if current_user.present?
					p request.fullpath
					redirect_to new_beta_path
				end
			end
		end

		def login_from_web_token
			if params[:a].present? && params[:e].present? && params[:i].present? && params[:o].present? && params[:u].present? && params[:x].present?
				token = params[:e] + params[:o] + params[:a] + params[:i] + params[:u]
				username = params[:x]
				url = request.url
				uri = URI(url)
				params = CGI.parse(uri.query || "")
				params.delete('a')
				params.delete('e')
				params.delete('i')
				params.delete('o')
				params.delete('u')
				params.delete('x')
				uri.query = URI.encode_www_form(params)
				if current_user.present? && request.get?
					redirect_to uri.to_s
				elsif request.get?
					user = User.find_by_username_and_web_token(username, token)
					if user.present?
						sign_in user
						session[:betacode] == 'btgrn'
					end
						redirect_to uri.to_s
				end
			end
		end
end
