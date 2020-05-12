class RecurringEvent < ActiveRecord::Base

  acts_as_paranoid

  # enums
  enum frequency: [ :every_sunday, :every_monday, :every_tuesday,  :every_wednesday, :every_thursday, :every_friday ,:every_saturday ]
  enum always_display: {one_event: 1 , two_events: 2, three_events: 3, four_events: 4}

  # relationships
  belongs_to :clan
  belongs_to :user
  belongs_to :game_game_system_join
  has_many   :events

  # delegate

  delegate :game, to: :game_game_system_join
  delegate :game_system, to: :game_game_system_join

  # validations
  validates :title, :start_time, :frequency, :always_display, :play_type, :game_type, :duration, :game_game_system_join_id,  presence: { message: "Required" }
  validates_presence_of :clan_id, :user_id
  validates :maximum_size, numericality: { greater_than_or_equal_to: 2, :message => "Must be greater than or equal to 2" }

  validate :valid_maximum_age

  # callbacks
  after_create :create_events


  def valid_maximum_age
    if maximum_age.present? && minimum_age.present? && maximum_age < minimum_age
      errors.add(:maximum_age, "Maximum Age Must Be Greater Than Minimum Age")
      errors.add(:minimum_age, "Minimum Age Must Be Less Than Maximum Age")
    end
  end

  def date_of_next
    date  = Date.parse(frequency)
    delta = date > Date.today ? 0 : 7
    "#{(date + delta).strftime("%m/%d/%Y")} #{start_time.strftime("%I:%M %p")}"
  end

  def create_event start_at
    event = events.new
    event.event_type = :clan_event
    event.start_at = start_at
    event.clan = clan
    event.user = user
    event.game_type = game_type
    event.play_type = play_type
    event.duration = duration
    event.minimum_age = minimum_age
    event.maximum_age = maximum_age
    event.maximum_size = maximum_size
    event.title = title
    event.game_game_system_join_id = game_game_system_join_id
    event.pc_type = pc_type
    event.add_founder = add_founder
    event
  end

  private

  def create_events
    start_at = date_of_next
    RecurringEvent.always_displays[always_display].times do |index|
      event = create_event start_at
      event.save
      start_at = event.start_at + 1.week
    end
  end



end
