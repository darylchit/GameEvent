class ContractsPresenter

  def self.for
    :contract
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
      id: @attributes[:id]
    }
  end

  def content
    @content
  end
end
