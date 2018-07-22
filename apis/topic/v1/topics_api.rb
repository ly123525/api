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
              styles = ::Mall::Style.on_sale(topic.styles).sorted.page(params[:page]).per(10)
              operate_style_ids = Operate::CommuneHandler.operate_styles.ids
              ::Mall::Style.activity_style_for_tags styles, operate_style_ids
              inner_app = inner_app? request
              present topic, with: ::V1::Entities::Topic::Topic, styles: styles, inner_app: inner_app
            rescue Exception => ex
              server_error(ex)
            end                          
          end    
        end
      end
    end  
  end  
end  