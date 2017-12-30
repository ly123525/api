module API
  class Base < Grape::API
    
    module JSONFormatter
      def self.call object, env
        {code: 200, data: object}.to_json
      end
    end
    
    module ErrorFormatter
      def self.call message, backtrace, options, env
        if message.class == String
          puts backtrace
          {code: 400, data: nil, tips: message, error: nil, location: env["PATH_INFO"], error_message: backtrace }.to_json
        else
          {code: message[:code], data: nil, tips: message[:tips], error: message[:error], location: message[:location], error_message: message[:error_message] || backtrace }.to_json
        end
      end
    end
    
    module DOCFormatter
      def self.call object, env
        object.to_json
      end
    end
    
    use ::API::Auth
    mount ::V1::Base
    
    formatter :json, ::API::Base::JSONFormatter
    error_formatter :json, ::API::Base::ErrorFormatter
  end
end
