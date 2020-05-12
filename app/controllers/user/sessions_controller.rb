class User::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  def create
    # super
    #TODO PROMOTIONAL ELITE
    # current_user.assign_promotional_elite
    self.resource = warden.authenticate(auth_options)
    if self.resource.present?
      # set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      @redirct_path = after_sign_in_path_for(resource)
      respond_to do |format|
        format.js
        format.html { redirect_to  after_sign_in_path_for(resource)}
      end
      flash.delete(:notice)
    else

      respond_to do |format|
        format.js
        format.html do
          flash[:notice] = 'Invalid Email or Password'
          self.resource = resource_class.new(sign_in_params)
          render :new
        end
      end
    end

  end

  # GET /resource/sign_in
  def new
    if flash[:alert] == "You need to sign in or sign up before continuing."
      flash[:alert] = 'Please sign up or sign in to continue.'
    end
    # super
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    yield resource if block_given?

    respond_to do |format|
      format.js
      format.html
    end
  end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end

end
