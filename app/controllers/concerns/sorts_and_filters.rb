
module SortsAndFilters

  # sanitize filter params and ensure shipments have corresponding methods to values passed
  def filter_params
    @filter_params = {}
    @select_params = {}
    @range_params = {}
    @in_params = {}
    @sort_params = {}
    if params[:filter] && params[:filter].is_a?(Hash)
      @filter_params = params[:filter]
      @filter_params = @filter_params.reject{|k, v| !@resource.respond_to?('has_'.concat(k.to_s).concat('_like').to_sym)}
    end

    if params[:select_filter] && params[:select_filter].is_a?(Hash)
      @select_params = params[:select_filter]
      @select_params.reject{|k, v| !@resource.respond_to?('has_'.concat(k.to_s).to_sym)}
    end 

    if params[:range_filter] && params[:range_filter].is_a?(Hash)
      @range_params = params[:range_filter]
      @range_params.reject{|k, v| !@resource.respond_to?('has_'.concat(k.to_s).concat('_between').to_sym)}
      @range_params.map{|k,v| 

         #remove parsing of date types for now, makes it easier to do range search on association
         # data_type = @resource.type_for_attribute(k).type  rescue nil 

         # case data_type 
         # when :date
         #    data_method = :to_date
         # when :integer
         #    data_method  = :to_i
         # when :datetime
         #    data_method = :to_datetime
         # else 
         #    data_method = :to_i
         # end

        unless @range_params[k].is_a?(Array)
          @range_params[k] = @range_params[k].split(' - ')#.map(&data_method)  
        else 
          @range_params[k] = @range_params[k]#.map(&data_method)
        end
      }
    end
    if params[:sort_filter] && params[:sort_filter].is_a?(Hash)
      @sort_params = params[:sort_filter]
    end

    if params[:in_filter] && params[:in_filter].is_a?(Hash)
      @in_params = params[:in_filter]
      @in_params.reject{|k, v| !@resource.respond_to?('has_'.concat(k.to_s).to_sym)}
      @in_params.each do |k,v|
        @in_params[k] = v.split(',')
      end
    end
  end

  #Sanitize the sort params and ensure shipments have corresponding values

  # def convert_sort_params

  # end

  def set_search
    @resource = @resource.search(@filter_params, 'text')  #text searches  
    @resource = @resource.search(@select_params, 'select') #definitive select box based searches
    @resource = @resource.search(@range_params, 'range')  #range searches, dates, etc..
    @resource = @resource.search(@in_params, 'in') if @in_params.present?
  # @resource = @resource.define_order(@sort_params["alphabetical_sort"], @resource)
  end

  def set_sort
    @resource = @resource.define_order(@sort_params["alphabetical_sort"], @resource)
  end

  def set_join_params
  end

end
