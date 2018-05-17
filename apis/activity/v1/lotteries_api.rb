module V1
  module Activity
    class LotteriesAPI < Grape::API
      namespace :activity do
        resources :lotteries do
          desc "首页抽奖进度"
          params do
            optional :user_uuid, type: String, desc: '用户UUID'
          end
          get :progress_bar do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              activity = ::Activity.where(status: false).first
              focus_count = activity.focus.count
              present activity, with: ::V1::Entities::Activity::Activity, focus_count: focus_count
            rescue Exception => ex
              server_error(ex)
            end            
          end
          desc "抽奖详情页"
          params do
            optional :user_uuid, type: String, desc: '用户UUID'
          end
          get  do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              activity = ::Activity.where(status: false).first
              focus_count = activity.focus.count
              
            rescue Exception => ex
              server_error(ex)
            end   
            {
              current_focus_on_count: 888000,
              target_focus_on_count: 1000000, 
              focus_on_or_not: false,
              benz: [
                  {image: 'https://image.ggoo.net.cn/201804/2018041517512699189b7b188-375-375.jpg', scheme: 'www.baidu.com'},
                  {image: 'https://image.ggoo.net.cn/201804/2018041517521238967d60ef5-375-375.jpg', scheme: 'www.baidu.com'},
                  {image: 'https://image.ggoo.net.cn/201804/2018041517521238967d60ef5-375-375.jpg', scheme: 'www.baidu.com'}
              ],
              smart: [
                  {image: 'https://image.ggoo.net.cn/201804/20180415175356219b47a1ef7-375-375.jpg', scheme: 'www.baidu.com'},
                  {image: 'https://image.ggoo.net.cn/201804/201804151755114636aa84c0a-375-375.jpg', scheme: 'www.baidu.com'},
                  {image: 'https://image.ggoo.net.cn/201804/2018041517544253688e1eff5-375-375.jpg', scheme: 'www.baidu.com'}
              ],
              share: {
                url: "#{ENV['H5_HOST']}/#/",
                image: "https://go-beijing.oss-cn-beijing.aliyuncs.com/app/logo_3x.png",
                title: '奔驰开回家做人生赢家',
                summary: '成功发起5人拼单即可获取奔驰轿车抽奖劵'
              },
              histroy_messages: [
                {nikename: '张**', prize: '奔驰E', tikets_number: 'ADXJFLEVMJSO97X8DA'},
                {nikename: '刘**', prize: 'Smart', tikets_number: 'S0X8DMS9XLS8SMD9X8'}
              ]
              
            }
          end
          desc "活动关注"
          params do 
            requires :user_uuid, type: String, desc: '用户 UIID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          post :focus_on do
            begin
              authenticate_user
              ::Activity.focus.create! user: @session_user
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