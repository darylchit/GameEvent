class RostersPresenter

  def self.for
    :roster
  end

  def initialize(attributes, content, additional_attributes)
    @content = content
    @additional_attributes = additional_attributes
    @attributes = attributes
  end

  def attributes
    {
      current_user: @additional_attributes[:current_user],
      email: @additional_attributes[:email],
      id: @attributes[:id],
      invited_user_id: @attributes[:invited_user_id]
    }
  end

  def content
    @content
  end
end
