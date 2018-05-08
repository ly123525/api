module V1
  module Activity
    class LotteryTicketsAPI < Grape::API
      namespace :activity do
        resources :lottery_tickets do
          desc "首页抽奖进度"
          params do
            optional :user_uuid, type: String, desc: '用户UUID'
          end
          get :progress_bar do
            begin
              {current_foucs_on_count: 888000, target_focus_on_count: 1000000, scheme: "#{ENV['H5_HOST']}/#/expedite_openaward"}
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end            
          end
          desc "抽奖详情页"
          params do
            
          end
          get  do
            
          end     
        end  
      end    
    end  
  end    
end   