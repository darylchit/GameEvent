class Api::V1::ReportsController < Api::BaseController
  respond_to :json
  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User

  # Creates a new report and assigns it to the current user as the reporter
  #
  # @param report [Report] required fields: `reportable_type`, `reportable_id`. Optional fields: `comment`
  #
  # @return [Boolean] `201` {success: true} if successful
  # @return [Array] `422` an array of errors keyed on the field name
  #
	def create
    # because a user is a valid reportable type, inherited resources apparently wants to
    # make the reportable be the current user rather than what the user passed in when you use build_resource.
    # to get around this, we just construct it manually
    resource = Report.new
    resource.reportable_type = params[:report][:reportable_type]
    resource.reportable_id = params[:report][:reportable_id]
    resource.comment = params[:report][:comment]

    if resource.valid?
      resource.user = current_user
      resource.save

      render json: {
        success: true
      }
    else
      render json: resource.errors, status: :unprocessable_entity
    end
	end

	protected
    def begin_of_association_chain
		current_user
    end

  	def permitted_params
  		params.permit(
  			report: [:reportable_type, :reportable_id, :comment]
  		)
    end
end
