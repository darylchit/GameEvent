class Api::V1::CompactContractSerializer < ActiveModel::Serializer
  include ProfileHelper
  attributes :id, :start_date_time, :duration, :price_in_cents,
             :details, :will_play, :play_type, :seller, :contract_type,
             :buyer, :games, :status,
             # roster
             :title, :waitlist, :confirmed_users_count, :max_roster_size,
             :confirmed_users


  def seller
    if object.contract?
      unless object.seller.nil? || object.seller.deleted_account
        Api::V1::UserSerializer.new object.seller, root: false
      else
        { username: '[deleted]', deleted_account: true }
      end
    end
  end

  def buyer
    if !object.contract? || ( object.contract? && serialization_options[:current_user].present? && (object.seller == serialization_options[:current_user] || object.buyer == serialization_options[:current_user]) )
      if object.contract? && object.status == 'Open'
        nil
      elsif object.buyer.present? && !object.buyer.deleted_account
        Api::V1::UserSerializer.new object.buyer, root: false
      else
        { username: '[deleted]', deleted_account: true }
      end
    end
  end

  def games
    object.game_game_system_joins.map do | ggs |
      Api::V1::GameGameSystemJoinSerializer.new ggs, root: false
    end
  end

  def confirmed_users_count
    Roster.find(object.id).confirmed_users_count if object.roster?
  end

  def confirmed_users
    if object.roster?
      Roster.find(object.id).confirmed_users.map do | u |
        unless u.nil? || u.deleted_account
          Api::V1::UserSerializer.new u, root: false
        else
          { username: '[deleted]', deleted_account: true }
        end
      end
    end
  end
end
