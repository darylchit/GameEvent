require 'active_support/concern'

module MoneyPenny
  extend ActiveSupport::Concern

  # based on https://github.com/RubyMoney/money-rails

  module ClassMethods
    def dollarize(field, *args)
      options = args.extract_options!

      subunit_name = field.to_s

      # calculate the name of our new virtual attribute
      # representing dollars. 
      # as: :foo will set it to foo
      # if it has _cents, will create a _dollars version
      # if none of the above, then simply slap on _dollars

      name = options[:as] || options[:target_name] || nil

      if name 
        name = name.to_s
      elsif subunit_name =~ /_cents/
        name = subunit_name.sub(/_cents/,"_dollars")
      else
        name = [ subunit_name, "dollars" ].join("_")
      end

      @dollarized_attributes ||= {}
      @dollarized_attributes[name.to_sym] = subunit_name

      class << self
        def dollarized_attributes
          @dollarized_attributes || superclass.dollarized_attributes
         end
      end unless respond_to? :dollarized_attributes

      define_method name do 
        cents = send(subunit_name)
        cents.to_d/100 if cents
      end

      define_method "#{name}=" do |value|
        if value.present?
          write_attribute(subunit_name, value.to_d * 100 )
        end
      end
    end
  end

end
