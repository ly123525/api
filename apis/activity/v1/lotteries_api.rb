module V1
  module Activity
    class LotteriesAPI < Grape::API
      namespace :activity do
        resources :lotteries do
          desc "用户奖券列表"
          params do 
            requires :user_uuid, type: String, desc: '用户 UIID'
            requires :token, type: String, desc: '用户访问令牌'
            optional :status, type: Boolean, default: false, desc: "按状态查询，默认为待开奖，{ '待开奖': false, '已开奖': true}"
            optional :page, type: Integer, default: 1, desc: '分页页面'
          end  
          get do
            begin
              authenticate_user
              lotteries = @session_user.lotteries_list(params[:status]).page(params[:page]).per(10)
              waiting_count = @session_user.lotteries_list(false).count
              present lotteries, with: ::V1::Entities::Activity::Lotteries_list, waiting_count: waiting_count
            rescue Exception => ex
              server_error(ex)                          
            end
          end
          
          desc "领取抽奖卷页,单张抽奖券的展示"
          params do
            requires :user_uuid, type: String, desc: '用户 UIID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :lottery_uuid, type: String, desc: '抽奖券 UUID'
            optional :os, type: String, values: ['IOS', 'Android'], desc: '微信内需要的机型'            
          end    
          get :show do
            begin 
              authenticate_user
              lottery = @session_user.lotteries.find_uuid(params[:lottery_uuid])
              inner_app = inner_app? request
              os = params[:os]
              present lottery, with: ::V1::Entities::Activity::Lottery, inner_app: inner_app, os: os, user: @session_user
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