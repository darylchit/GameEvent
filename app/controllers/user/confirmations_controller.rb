class User::ConfirmationsController < Devise::ConfirmationsController
  respond_to :html, :js
  # GET /resource/confirmation/new
  # def new
  #   super
  # end
  # POST /resource/confirmation
   def create
     self.resource = resource_class.send_confirmation_instructions(resource_params)
     yield resource if block_given?
     if successfully_sent?(resource)
       respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
     else
       respond_with(resource)
     end
   end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    # sending a welcome email after first confirmation
    super do | resource |
      if resource.errors.empty? && resource.sign_in_count == 0
        ApplicationMailer.send_welcome_email(resource).deliver_now
        sign_in resource

      end
    end
  end

  def is_flashing_format?
    false
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
