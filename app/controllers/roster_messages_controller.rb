class RosterMessagesController < ApplicationController

    before_action :check_if_owner, except: [:create]
    before_action :ensure_user_can_post, only: [:create]

   def create
       message = params[:roster_message][:message]

       @roster_message = current_user.roster_messages.new(message: message, roster_id: params[:roster_id])
       if @roster_message.save
          notify_users @roster_message
          respond_to do |format|
              format.html {redirect_to roster_path(params[:roster_id]) + '#roster-messages' }
              format.js {render :layout => false}
          end
      else
         respond_to do |format|

              format.html { return redirect_to(roster_path(params[:roster_id]) + '#roster-messages', notice: @roster_message.errors.full_messages.join(' '))}
              format.js {render :layout => false}
          end
      end
   end

    def edit
        @roster_message = RosterMessage.find(params[:id])
            respond_to do |format|
                format.html {}
                format.js {render :layout => false}
            end
    end

    def update
        @roster_message = RosterMessage.find(params[:id])
        if @roster_message.update(roster_message_params)
            respond_to do |format|
                format.html {redirect_to roster_path(@roster_message.roster) + '#roster-messages'}
                format.js {render :layout =>false}
            end
        else
            respond_to do |format|
                format.html {render "edit"}
                format.js {render :layout => false, :status => 422 }
            end
        end

    end

    def destroy
      @roster_message = RosterMessage.find(params[:id])

            @roster_message.destroy
            respond_to do |format|
                format.html {redirect_to roster_path(@roster_message.roster.id) + '#roster-messages'}
                format.js {render :layout => false}
            end
     end

    private
    def check_if_owner
        message = RosterMessage.find(params[:id])
        unless current_user == message.user
            redirect_to roster_path(message.roster)
        end

    end
      def roster_message_params
          params.require(:roster_message).permit(:message, :roster_id)
      end

    def valid_roster?(roster_id)
        Roster.exists?(id: roster_id)

    end
    def ensure_user_can_post
        if valid_roster?(params[:roster_id])
            roster = Roster.find(params[:roster_id])
            unless roster.invited?(current_user) || current_user == roster.owner
                redirect_to(:back, notice: 'Unauthorized to post on this roster')
            end
        else
            head(403)
        end

    end

    def notify_users(message)
      NotificationWorker.perform_async(message.id, 'RosterMessage', 'Notifications::RosterMessageNotification', 'created')
    end

end
