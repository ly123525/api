module V1
  class Base < Grape::API

    version 'v1', :path

    helpers ::Helpers

    content_type :json, 'application/json; charset=utf8'
    content_type :xml, "text/xml"
    content_type :txt, "text/plain"
    content_type :binary, 'application/octet-stream'
    formatter :binary, ->(object, env) { object }

    default_format :json
    rescue_from :all, backtrace: true do |e|
      puts e.backtrace.join("\n\t")
      {code: 503, tips: "服务器不给力，请重试!", error: e.message, location: e.backtrace.join("\n")}
    end

    mount ::V1::User::UsersAPI
    mount ::V1::User::SessionsAPI
    mount ::V1::Shop::ProductsAPI
    mount ::V1::User::AddressesAPI
    
    if ENV['SERVER_ENV']=='development'
      namespace :doc do
        formatter :json, ::API::Base::DOCFormatter
        add_swagger_documentation doc_version: 'v1',
        info: {
          title: 'API 文档'
        }
        before do
          header "Cache-control", "maxage=0"
        end
      end
    end
  end
end

