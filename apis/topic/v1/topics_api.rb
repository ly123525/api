module V1
  module Topic
    class TopicsAPI < Grape::API
      namespace :topic do
        resource :topics do
          desc "专题"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            requires :uuid, type: String, desc: '专题 UUID'
            optional :page, type: Integer, default: 1,desc: '分页页码'
          end
          get do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              topic = ::Topic::Topic.find_uuid(params[:uuid])
              styles = ::Mall::Style.on_sale(topic.styles).page(params[:page]).per(10)
              present topic, with: ::V1::Entities::Topic::Topic, styles: styles
            rescue Exception => ex
              server_error(ex)
            end                          
          end    
        end
      end
    end  
  end  
end  