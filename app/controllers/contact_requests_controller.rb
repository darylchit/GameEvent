class ContactRequestsController < InheritedResources::Base
  respond_to :html


  def new
    respond_to do |format|
      format.js
    end
  end

  def create
    # normal routes to make this happen were just *not* working out
    @contact_request = ContactRequest.new(permitted_params)
    if current_user.present?
      @contact_request.email = current_user.email
      @contact_request.user_id = current_user.id
      @contact_request.name = current_user.name
    end
    create!{
      if @contact_request.persisted?
        render 'contact_requests/create'
        return
      end
    }
  end

  protected
    def permitted_params
		    # params.permit(contact_request: [:name, :email, :contact_type, :message])
        params.permit(:name,:contact_type,:message,:email)

    end
end
