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
              app_error('活动已经结束', 'The activity is over') unless activity.present?
              focus_count = activity.focus_ons.count rescue 1000000
              benzs = ::Topic::Topic.where(activity_tags: 'benz').limit(3)
              smarts = ::Topic::Topic.where(activity_tags: 'smart').limit(3)
              activities = ::Activity.where(status: true).order(id: :desc).limit(3)
              inner_app = inner_app? request
              present activity, with: ::V1::Entities::Activity::ActivityDetails, focus_count: focus_count, user: user, benzs: benzs, smarts: smarts, inner_app: inner_app, activities: activities 
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
              app_error('已经开奖了,不能再关注了', 'No more attention') unless activity.present?
              app_error('您已经关注过了', "You are looked at it") if @session_user.focus_ons.where(item: activity).present?
              app_error('活动已经关闭,等待开奖', "No more attention") unless activity.start_at <= Time.now && Time.now <= activity.end_at
              inner_app = inner_app? request
              focus_on = activity.focus_ons.create! user: @session_user, inner_app: inner_app
              lottery =::Lotteries::Smart.create!(user: @session_user)   #不应该是smart类,应该灵活些，下次活动还要改
              lottery.send_to_message_fight_group_complete
              ::ActivityItem.create!(activity: activity, target: focus_on, result: lottery )
              logger.info "========================lottery=============#{lottery.uuid}"
              {lottery_scheme:  "#{ENV[H5_HOST]}/#/openaward?lottery_uuid=#{lottery.uuid}"}
            rescue ActiveRecord::RecordNotFound
              app_uuid_error              
            rescue Exception => ex
              server_error(ex)
            end              
          end
          desc "中奖历史"
          params do
            optional :user_uuid, type: String, desc: '用户UUID'            
          end
          get :history do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              activities = ::Activity.where(status: true).order(id: :desc)
              present activities, with: ::V1::Entities::Activity::LotteryResultHistory                
            rescue Exception => ex
              server_error(ex)
            end                        
          end
          desc "进入活动详情页统计"
          params do 
            optional :target, type: String, values: ['banner', 'web_view'], default: 'banner', desc: '进入的来源'
            requires :target_id, type: String, desc: '来源 ID'
            optional :user_uuid, type: String, desc: '用户 UUID'
          end
          post :statistical do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              ::ActivityItem.generate_by_target! params[:target], params[:target_id]
              true                 
            rescue Exception => ex
              server_error(ex)
            end               
          end
          desc "分享统计"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
          end
          post :share_statistic do 
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              activity = ::Activity.where(status: false).first
              ::ShareStatistic.create!(item: activity, user: user) if activity.present?
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