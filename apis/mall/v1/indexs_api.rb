module V1
  module Mall
    class IndexsAPI < Grape::API
      namespace :mall do
        resources :indexs do
          desc "商城首页"
          params do 
            optional :user_uuid, type: String, desc: '用户UUID'
            optional :page, type: Integer, default: 1, desc: '分页页码'
          end  
          get do
            begin 
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              app_version_code=app_version_code(request).to_i
              mall_index = ::Mall::Indices::Index.where("version_code > ? ", app_version_code).last || ::Mall::Indices::Index.where("version_code <= ? ", app_version_code).first
              styles = ::Mall::Style.recommended.sorted.page(params[:page]).per(10)
              present mall_index, with: ::V1::Entities::Mall::MallIndex, styles: styles
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