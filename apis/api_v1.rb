module API
  class V1 < Grape::API

    version 'v1', :path

    helpers ::APIHelpers

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
    mount ::V1::User::AddressesAPI
    
    mount ::V1::IM::UsersAPI
    
    mount ::V1::Payment::ModesAPI

    mount ::V1::Mall::ProductsAPI
    mount ::V1::Mall::OrdersAPI
    mount ::V1::Mall::CollectionsAPI
    mount ::V1::Mall::SearchesAPI
    mount ::V1::Mall::FightGroupsAPI
    mount ::V1::Mall::ServicesAPI
    mount ::V1::Mall::ShopsAPI
    mount ::V1::Mall::IndexsAPI
    mount ::V1::Mall::IndexsAPI
    
    mount ::V1::Choice::ArticlesAPI
    mount ::V1::Choice::CollectionsAPI
    mount ::V1::Choice::CommentsAPI
    
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

