module API
  class Base < Grape::API
    
    module JSONFormatter
      def self.call object, env
        tips = object.delete(:tips) || object.delete('tips') rescue nil
        data = object[:data] || object['data'] || object rescue object
        data = nil if data.blank?
        {code: 200, data: data, tips: tips}.to_json
      end
    end
    
    module ErrorFormatter
      def self.call message, backtrace, options, env, original_exception
        {code: message[:code], tips: message[:tips], error: message[:error], location: env["PATH_INFO"]}.to_json
      end
    end
    
    module DOCFormatter
      def self.call object, env
        object.to_json
      end
    end
    
    formatter :json, ::API::Base::JSONFormatter
    error_formatter :json, ::API::Base::ErrorFormatter
    
    use ::API::Auth
    mount ::V1::Base
  end
end
