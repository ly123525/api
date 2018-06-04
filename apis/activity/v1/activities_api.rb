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
              activity = ::Activity.order(id: :desc).first
              current_follows_count = activity.follows.count + activity.fake_follow_count
              present activity, with: ::V1::Entities::Activity::Activity, current_follows_count: current_follows_count
            rescue Exception => ex
              server_error(ex)
            end            
          end
          desc "活动详情页"
          params do
            optional :user_uuid, type: String, desc: '用户UUID'
            requires :uuid, type: String, desc: '活动 UUID'
          end
          get  do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              activity = ::Activity.find_uuid params[:uuid]
              app_error('活动已经结束', "The activity has come to an end") unless activity.start_at < Time.now && Time.now < activity.end_at
              lottery_templates = ::LotteryTemplate.where('end_at < ?', Time.now ).order(id: :desc)
              inner_app = inner_app? request
              binding.pry
              present activity, with: ::V1::Entities::Activity::ActivityDetails, user: user, inner_app: inner_app, lottery_templates: lottery_templates 
            rescue Exception => ex
              server_error(ex)
            end   
          end
          desc "活动关注"
          params do 
            requires :user_uuid, type: String, desc: '用户 UIID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '活动 UUID'
          end
          post :follow do
            begin
              authenticate_user
              activity = ::Activity.find_uuid params[:uuid]
              lottery_template = activity.lottery_templates.where(followed: true).first
              app_error('您已经关注过了', "You are looked at it") if @session_user.followed?(activity)
              app_error('活动已经结束', "The activity has come to an end") unless lottery_template.start_at < Time.now && Time.now < lottery_template.end_at
              inner_app = inner_app? request
              follow = activity.follows.create! user: @session_user, inner_app: inner_app
              lottery = follow.generate_lottery! activity, @session_user, lottery_template
              lottery_scheme = "#{ENV['H5_HOST']}/#/obtain_ticket?lottery_uuid=#{lottery.uuid}" if inner_app
              lottery_scheme = "#{ENV['H5_HOST']}/#/openaward?lottery_uuid=#{lottery.uuid}" if !inner_app
              {lottery_scheme:  lottery_scheme}
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
              lottery_templates = ::LotteryTemplate.where('end_at < ?', Time.now ).order(id: :desc)
              present lottery_templates, with: ::V1::Entities::Activity::LotteryResultHistory                
            rescue Exception => ex
              server_error(ex)
            end                        
          end
          desc "进入活动详情页统计"
          params do 
            optional :target, type: String, values: ['banner', 'web_view'], default: 'banner', desc: '进入的来源'
            requires :target_id, type: String, desc: '来源 ID'
            requires :uuid, type: String, desc: '活动 UUID' 
            optional :user_uuid, type: String, desc: '用户 UUID'
          end
          post :statistical do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              activity = ::Activity.find_uuid params[:uuid]
              ::ActivityItem.generate_by_target! activity, params[:target], params[:target_id]
              true                 
            rescue Exception => ex
              server_error(ex)
            end               
          end                     
        end  
      end    
    end  
  end    
end   