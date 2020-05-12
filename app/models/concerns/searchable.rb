require 'active_support/concern'

module Searchable
  extend ActiveSupport::Concern

  #use has to avoid clashing with prexisting scopes

  included do
    #text search scopes
    self.attribute_names.select{|a| [:string, :text].include?(self.type_for_attribute(a).type)}.each do |col|
      scope "has_".concat(col).concat('_like').to_sym, -> (param){where("lower(#{self.table_name}.#{col}) LIKE ?", "%#{param.downcase}%")}
    end

    #association search scopes
    self.reflect_on_all_associations.each do |assoc|
      singularized_assoc = assoc.name.to_s.singularize
      scope "has_".concat(singularized_assoc).to_sym, -> (id){includes(assoc.name.to_sym).where(assoc.name => {id: id})}  

    end


    #select based definitive scopes

    self.attribute_names.each do |col|

      scope "has_".concat(col).to_sym, -> (param){where("#{self.table_name}.#{col} = ?", param)}

    end

    #ranged based scopes
    self.attribute_names.select{|a| [:date, :datetime, :integer].include?(self.type_for_attribute(a).type)}.each do |col|
      scope "has_".concat(col).concat('_between').to_sym, -> (low, high){
        where("#{self.table_name}.#{col} >= ? AND  #{self.table_name}.#{col} <= ?", low, high)}
    end
  end

  def self.extended(base)
    #allows child classes to have searches on their own associations
    #association search scopes
    base.reflect_on_all_associations.map(&:name).each do |assoc|
      singularized_assoc = assoc.to_s.singularize
      define_method "has_".concat(singularized_assoc) do |id|
        base.includes(assoc).where(assoc => {id: id})
      end

    end

    #
    #gives text based searches on an associated attributes and leverages the syntax provided by squeel gem: https://github.com/activerecord-hackery/squeel
    #produces scopes on the model that looks like: Roster.joins(:buyer).where{(users.send(:username).send(:like, '%SomeName%'))}
    base.reflect_on_all_associations.each do |assoc|
      if assoc.class_name
        assoc_class = assoc.class_name.constantize
        assoc_class.attribute_names.select{|ac| [:string, :text, :integer].include?(assoc_class.type_for_attribute(ac).type)}.each do |a|

          define_method "has_".concat(assoc.name.to_s).concat('_with_').concat(a.to_s).concat('_like') do |param|
            base.joins(assoc.name).where{(instance_eval(assoc.name.to_s).send(a).send(:like, "%#{param}%")) }
          end

          define_method "has_".concat(assoc.name.to_s).concat('_with_').concat(a.to_s) do |param|
            base.joins(assoc.name).where{(instance_eval(assoc.name.to_s).send(a).send(:eq, param))}
          end
        end

        #produces range scopes on association attributes
        assoc_class.attribute_names.select{|ac| [:integer, :date, :datetime].include?(assoc_class.type_for_attribute(ac).type)}.each do |a|
          define_method "has_".concat(assoc.name.to_s).concat('_with_').concat(a.to_s).concat('_between') do |low, high|
            base.joins(assoc.name).where{ (instance_eval(assoc.name.to_s).send(a).send(:gteq, low)) & (instance_eval(assoc.name.to_s).send(a).send(:lteq, high))}
          end
        end
      end
    end
  end



  module ClassMethods
    def search(search_params, search_type = 'text')
      #allowed types, 'text', 'select', 'range'
      results = self.where(nil)
      search_params.each  do |k, v|
        case search_type
        when 'text'
          scope = "has_".concat(k.to_s).concat('_like').to_sym
        when 'select'
          scope = "has_".concat(k.to_s).to_sym
        when 'in'
          scope = k.to_sym
        when 'range'
          scope = 'has_'.concat(k.to_s).concat('_between').to_sym
        end

        if v.is_a?(Array) && search_type == 'range'
          results = results.public_send(scope, v[0], v[1]) if self.respond_to?(scope) && v.present?
        elsif v.is_a?(Array) && search_type == 'in'
          results = results.where("#{self.table_name}.#{k} IN (?)", v) if self.column_names.include?(k) && v.present?
        else


          results = results.public_send(scope, v) if self.respond_to?(scope) && v.present? 
        end
      end
        results.uniq
    end
  end

end
