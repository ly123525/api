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
            # {
            #   current_focus_on_count: 888000,
            #   target_focus_on_count: 1000000,
            #   focus_on_or_not: false,
            #   benz: [
            #       {image: 'https://image.ggoo.net.cn/201804/2018041517512699189b7b188-375-375.jpg', scheme: 'www.baidu.com'},
            #       {image: 'https://image.ggoo.net.cn/201804/2018041517521238967d60ef5-375-375.jpg', scheme: 'www.baidu.com'},
            #       {image: 'https://image.ggoo.net.cn/201804/2018041517521238967d60ef5-375-375.jpg', scheme: 'www.baidu.com'}
            #   ],
            #   smart: [
            #       {image: 'https://image.ggoo.net.cn/201804/20180415175356219b47a1ef7-375-375.jpg', scheme: 'www.baidu.com'},
            #       {image: 'https://image.ggoo.net.cn/201804/201804151755114636aa84c0a-375-375.jpg', scheme: 'www.baidu.com'},
            #       {image: 'https://image.ggoo.net.cn/201804/2018041517544253688e1eff5-375-375.jpg', scheme: 'www.baidu.com'}
            #   ],
            #   share: {
            #     url: "#{ENV['H5_HOST']}/#/",
            #     image: "https://go-beijing.oss-cn-beijing.aliyuncs.com/app/logo_3x.png",
            #     title: '奔驰开回家做人生赢家',
            #     summary: '成功发起5人拼单即可获取奔驰轿车抽奖劵'
            #   },
            #   histroy_messages: [
            #     {nikename: '张**', prize: '奔驰E', tikets_number: 'ADXJFLEVMJSO97X8DA'},
            #     {nikename: '刘**', prize: 'Smart', tikets_number: 'S0X8DMS9XLS8SMD9X8'}
            #   ]
            #
            # }
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