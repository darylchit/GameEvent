class Api::V1::ContractSerializer < ActiveModel::Serializer
  include ProfileHelper
  attributes :id, :start_date_time, :duration, :price_in_cents,
             :details, :will_play, :play_type, :seller, :buyer, :games,
             :selected_game_game_system_join, :contract_type, :status,
             # rosters
             :confirmed_users, :waitlist, :confirmed_users_count, :max_roster_size,
             :invites

  def seller
    if object.seller.present?
      Api::V1::UserSerializer.new object.seller, root: false
    end
  end

  def buyer
    if object.buyer.present?
      Api::V1::UserSerializer.new object.buyer, root: false
    end
  end

  def games
    object.game_game_system_joins.map do | ggs |
      Api::V1::GameGameSystemJoinSerializer.new ggs, root: false
    end
  end

  def selected_game_game_system_join
    Api::V1::GameGameSystemJoinSerializer.new(object.selected_game_game_system_join, root: false) if object.selected_game_game_system_join.present?
  end

  def confirmed_users
    if object.roster?
      object.confirmed_users.map do | cu |
        Api::V1::UserSerializer.new cu, root: false
      end
    end
  end

  def confirmed_users_count
    if object.roster?
      object.confirmed_users_count
    end
  end

  def invites
    if object.roster?
      # roster owner. Show all invites
      if object.owner == serialization_options[:current_user]
        object.invites.map do | i |
          Api::V1::InvitedUserSerializer.new i, root: false
        end
      # possibly an invited user. Show their invite if they have one
      else
        invites = object.invites.where(user: serialization_options[:current_user])
        if invites.present?
          invites.map do | i |
            Api::V1::InvitedUserSerializer.new i, root: false
          end
        else
          nil
        end
      end
    end
  end

end
