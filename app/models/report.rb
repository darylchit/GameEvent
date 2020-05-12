class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :admin
  belongs_to :reportable, polymorphic: true

  validates_presence_of :reportable, :message => "Required"

  scope :created_by_user, -> (user) { where(:user => user) }
  # Gives a human-readable name for the reportable type
  #
  # @return [String] the name of the reportable type
  def reportable_type_name
    case reportable
    when User
      'User'
    when Roster
      'Roster'
    when Bounty
      'Bounty'
    when Contract
      'Contract'
    else
      r.reportable_type
    end
  end
end
