module V1
  module Statistic
    class StatisticsAPI < Grape::API
      namespace :statistic do
        resources :statistics do
          desc "分享统计"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            requires :resource_uuid, type: String, desc: '资源 UUID'
            requires :resource_type, type: String, desc: '资源类型'
          end
          post :share_statistic do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              resource = params[:resource_type].constantize.find_uuid params[:resource_uuid]
              ::ShareStatistic.find_or_create_by(item: resource, user: user)
              true
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