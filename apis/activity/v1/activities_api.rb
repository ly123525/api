module V1
  module Activity
    class ActivitiesAPI < Grape::API
      namespace :activity do
        resources :activities do
          desc "首页活动进度"
          params do
            optional :user_uuid, type: String, desc: '用户UUID'
          end
          get :progress_bar do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              activity = ::Activity.where(status: false).first
              focus_count = activity.focus_ons.count
              present activity, with: ::V1::Entities::Activity::Activity, focus_count: focus_count
            rescue Exception => ex
              server_error(ex)
            end            
          end
          desc "活动详情页"
          params do
            optional :user_uuid, type: String, desc: '用户UUID'
          end
          get  do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              activity = ::Activity.where(status: false).first
              focus_count = activity.focus_ons.count
              benzs = ::Topic::Topic.where(activity_tags: '奔驰').limit(3)
              smarts = ::Topic::Topic.where(activity_tags: 'smart').limit(3)
              present activity, with: ::V1::Entities::Activity::ActivityDetails, focus_count: focus_count, user: user, benzs: benzs, smarts: smarts 
            rescue Exception => ex
              server_error(ex)
            end   
          end
          desc "活动关注"
          params do 
            requires :user_uuid, type: String, desc: '用户 UIID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          post :focus_on do
            begin
              authenticate_user
              activity = ::Activity.where(status: false).first
              app_error('您已经关注过了', "You are looked at it") if @session_user.focus_ons.where(item: activity).present?
              focus_on = activity.focus_ons.create! user: @session_user
              lottery =::Lotteries::Smart.create!(user: @session_user)  #不应该是smart类,应该灵活些，下次活动还要改
              ::ActivityItem.create!(activity: activity, target: focus_on, result: lottery )
              {lottery_uuid: lottery.uuid }
            rescue Exception => ex
              server_error(ex)
            end              
          end         
        end  
      end    
    end  
  end    
end   