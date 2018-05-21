module V1
  module Mall
    class BrowseRecordAPI < Grape::API
      namespace :mall do
        resources :browse_records do
          desc "足迹列表"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            optional :page, type: Integer, default: 1, desc: '分页页码'            
          end
          get do
            begin
              authenticate_user
              style_ids = @session_user.browse_records.map(&:style_id)
              styles = ::Mall::Style.where(id: style_ids)
              style_ids = ::Mall::Style.on_sale(styles).ids
              records = @session_user.browse_records.where(style_id: style_ids).page(params[:page]).per(10)
              present records, with: ::V1::Entities::Mall::BrowseRecords
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end                          
          end    
        end   
      end
    end  
  end  
end  