module V1
  module Entities
    module Activity
      class Activity < Grape::Entity
        expose :current_follows_count do |m, o|
          o[:current_follows_count]
        end   
        # expose :scheme do |m, o|
        #   "#{ENV['H5_HOST']}/#/expedite_openaward"
        # end 
      end
      
      class LotteryResult < Grape::Entity
        expose :number
        expose :user_name do |m, o|
          ::Lottery.find_by_number(m.number).user.nickname
        end
        expose :result_name do |m, o|
          case ::Lottery.find_by_number(m.number).lottery_template.color
           when "black"
             "奔驰E"
           when "green"
             "Smart"
          end      
        end    
      end    
      
      class LotteryResultHistory < Grape::Entity
        expose :nper do |m, o|
          m.activity.sub_name
        end
        expose :time do |m ,o|
          m.end_at.localtime.strftime('%y.%m.%d')
        end    
        expose :infos, using: ::V1::Entities::Activity::LotteryResult do |m, o|
          m.lottery_results
        end  
      end  
      
      class ActivityDetails < Grape::Entity
        expose :explain_scheme do |m, o|
          "#{ENV['H5_HOST']}/#/activity/explain"
        end         
        expose :follow_or_not do |m, o|
          o[:user].followed?(m) if o[:user].present?
        end
        expose :resource_uuid do |m, o|
          m.uuid
        end
        expose :resource_type do |m, o|
          m.class.to_s
        end    
        expose :share do |m, o|
          {
            url: "#{ENV['H5_HOST']}/#/expedite_openaward",
            image: "https://go-beijing.oss-cn-beijing.aliyuncs.com/app/logo_3x.png",
            title: '终极抽奖日',
            summary: '从新定义疯狂，拼单即可参与抽奔驰E与smart'
          } 
        end    
        expose :histroy_messages, using: ::V1::Entities::Activity::LotteryResultHistory do |m, o|
          o[:lottery_templates]
        end    
      end    
    end  
  end  
end  