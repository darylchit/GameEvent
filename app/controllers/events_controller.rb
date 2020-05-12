# coding: utf-8
class EventsController < InheritedResources::Base
  include SortsAndFilters
  defaults :resource_class => Contract
  before_filter :authenticate_user! 
  before_filter :get_collection, only: [:index]
  before_filter :filter_params, only: [:index]
  before_filter  :set_search, only: [:index]

  respond_to :html, :js

  def index
    @invited_rosters = current_user.invites.where('status' => 0).map{|r| [r.contract_id]}
    @invites = Roster.where('id' => @invited_rosters).where('start_date_time > now()').order("start_date_time ASC")


    @resource.order(start_date_time: :asc)
    @recent_events = @resource.page(params[:page])

  end

  def view_all
    # Set default params for the grid to show more relevant data
    # ACtually, don't
    # params[:utf8] ||= '✓'
    # params[:grid] ||= {}
    # params[:grid][:f] ||= {}
    # params[:grid][:f][:status] ||= ["Claimed", "Complete", "Invoiced", "Open", "Payment Complete"]

    @all = initialize_grid(current_user.all_contracts,
      order: 'start_date_time',
      order_direction: 'desc',
      per_page: 120,
      name: 'grid',
        # Wice Grid support only DB ordering, create a custom filter to order contract types
        # internally known as Contract, Bounty, and Roster which map to 'LFP' and 'GR'
      custom_order: {
        'contracts.contract_type' => "CASE contracts.contract_type WHEN 'Roster' THEN 'GR' ELSE 'LFP' END"
      }
    )

  end

  def show
    event = resource
      # This will include social sharing crawl of meta
      if current_user.nil?
        if resource.contract_type == "Roster"
          @public_event = 'roster'
          @event = Roster.find(resource.id)
          @roster_users = @event.confirmed_users
              @waitlist_users = @event.waitlist_users
              render file: "app/views/events/public_roster.html.erb"
          elsif resource.contract_type == "Contract" || event.contract_type == "Bounty"
            @public_event = 'availability'
          @event = Contract.find(resource.id)
            render file: "app/views/events/public_availability.html.erb"
          end
      else
        if resource.contract_type == "Roster"
          redirect_to(roster_path resource.id)
        elsif resource.contract_type == "Contract" || event.contract_type == "Bounty"
          if resource.buyer_id != nil && current_user.id == resource.buyer_id
            redirect_to(claimed_contract_path resource.id)
          elsif resource.seller_id != nil && current_user.id == resource.seller_id
            redirect_to(posted_contract_path resource.id)
          else
            @event = Contract.find(resource.id)
            render file: "app/views/events/public_availability.html.erb"
          end
        else
          redirect_to(new_user_session_path)
        end
      end

  end

  protected

  def get_collection
    # @upcoming_events = current_user.active_contracts.where('start_date_time > now()')
    @resource = current_user.all_contracts.where(["'status' != ? AND 'status' != ? AND 'status' != ?", 'Closed', 'Expired', 'Cancelled'])

  end

end
