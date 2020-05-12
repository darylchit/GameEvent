class Api::V1::DevicesController < Api::BaseController
  respond_to :json
  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User

	def create
    resource = build_resource

    if resource.valid?
      if ENV["PARSE_ENABLED"].present? and ENV["PARSE_ENABLED"].eql?('true')
        # if the user does not already have this device lets create it
        unless current_user.devices.exists?( device_token: resource.device_token, device_type: resource.device_type )

          # if this device is associated with another user, lets take it back
         
          Device.destroy_all( device_token: resource.device_token, device_type: resource.device_type )

          resource.save
        end

  			# TODO create fallback on failure
				new_device = Parse::Installation.new
				new_device['deviceType'] = resource.device_type
				new_device['deviceToken'] = resource.device_token
				new_device.save
        
      end
      
      render json: {
        success: true
      }
    else
      render json: {
        success: false
      }
    end
	end

	def show
		super
	end

	def update
		success.json{
			render :show
		}
		failure.json{
			render :failure
		}
	end

	protected
    def begin_of_association_chain
		current_user
    end

  	def permitted_params
  		params.permit(
  			device: [:device_token, :device_type]
  		)
    end
end
