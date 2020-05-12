module Api
  module V1
    module Searchable

      # sanitize filter params and ensure shipments have corresponding methods to values passed
       def filter_params
        @filter_params = {}
        if params[:filter] && params[:filter].is_a?(Hash)
     
        end
         @filter_params
      end

      #Sanitize the sort params and ensure shipments have corresponding values

      def convert_sort_params
         @sort_params = []
        #convert sort params to database columns
        if params[:sorting] && params[:sorting].is_a?(Array)
          params[:sorting].each do |p|

            sort = sort.reject{|k, v| !@resource.attribute_method?(k) || !['asc', 'desc'].include?(v.downcase)}

            @sort_params.push(sort)
          end
        end
          @sort_params
      end



      def set_search
      
      end

    end
  end
end