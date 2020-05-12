class InvitesController < InheritedResources::Base
	before_filter :authenticate_user!
	respond_to :html, :js
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  after_filter :update_waitlist, only: [:destroy, :waitlist, :decline]

  def destroy
    @roster = current_user.rosters.find(resource.roster.id)
    removed_user = resource.user
    destroy! {
      @roster.send_removed_message removed_user
      roster_path(@roster)
    }
  end

  def create
		roster = Roster.find params[:roster_id]
    unless roster.status == 'Open'
      redirect_to @roster || events_path, notice: "This event is no longer available"
      return
    end

		create_new_invite!
    redirect_to roster_path(@roster), notice: t('.notice_html')
  end

  def claim
		roster = resource.roster
    unless roster.status == 'Open'
      redirect_to @roster || events_path, notice: "This event is no longer available"
      return
    end

    claim_spot!
    redirect_to @roster, notice: "Your spot has been claimed"
  rescue
    redirect_to @roster || events_path, notice: "Sorry, we had a problem"
  end

  def decline
    decline_invite!
    redirect_to @roster, notice: "Your spot has been declined"
  rescue
    redirect_to @roster || events_path, notice: "Sorry, we had a problem"
  end

  def waitlist
    # Only the owner can use this
    @invite = resource
    @roster = @invite.roster
    @invite.waitlisted!
    redirect_to @roster, notice: "#{@invite.user.username} has been placed on the waitlist."
  rescue
    redirect_to @roster || events_path, notice: "Sorry, we had a problem"
  end

  def update_position
    @invite = resource
    delta = params[:delta]
    new_position = @invite.position - delta.to_i
    @invite.insert_at(new_position)
    render nothing: true
   end

	def no_show
       #Owner action
		@invite = resource
		@roster = @invite.roster
		if current_user == @roster.owner
				 @invite.no_show!
         @invite.user.update_cancellation_rate!
				 subj = "#{@roster.owner.username} has listed you as a no show for their event"
				 body = "%s. [roster id=\"%d\"]" % [ subj, @roster.id]
				 @invite.user.send_message @invite.user, body, subj, true, nil, Time.now, @roster
				 redirect_to @roster, notice: "#{@invite.user.username} has been marked as a no show."
		else
			redirect_to events_path
		end
	 	rescue
		 redirect_to @roster || events_path, notice: "Sorry, we had a problem"
	 end

	def reconfirm
		#allows owner to undo no show status
		@invite = resource
		@roster = @invite.roster
		if current_user == @roster.owner
			@invite.update!(status: :confirmed)
      @invite.user.update_cancellation_rate!
			redirect_to @roster, notice: "#{@invite.user.username} has been reconfirmed"
		else
			redirect_to events_path
		end
	rescue
       redirect_to @roster || events_path, notice: "Sorry, we had a problem"
	end

	private

	def not_found
      # when scope prevents finding the object, in other words
      # user does not have permission to get view this
      redirect_to events_path, notice: nil
	end

	def update_waitlist
      @roster.update_waitlist!
	end

	# Using params[:roster_id] and current_user, creates a new invite for a user and either confirms
	# the spot, or gets added to the waitlist. This will set @roster and @invite and send the notification
	def create_new_invite!
	  @roster = Roster.find( params[:roster_id] )
	  @invite = @roster.invites.create( user: current_user)

	  unless @roster.full?
	    @invite.confirmed!
	  else
	    @invite.waitlisted!
	  end
		NotificationWorker.perform_async(@invite.id, 'Invite', 'Notifications::EventInviteNotification', 'joined')
	end

	# Claims a spot in a roster from an invite. This will set @roster and @invite, and send the notification
	def claim_spot!
		@invite = current_user.invites.find(params[:id])
		@roster = @invite.roster
		@invite.confirmed!
		NotificationWorker.perform_async(@invite.id, 'Invite', 'Notifications::EventInviteNotification', 'joined')
	end

	# Declines an invitation. This will set @roster and @invite
	def decline_invite!
		@invite = current_user.invites.find(params[:id])
		@roster = @invite.roster
		@invite.declined!
	end

	protected
end
