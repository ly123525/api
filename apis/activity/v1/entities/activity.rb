module V1
  module Entities
    module Activity
      class Activity < Grape::Entity
        expose :current_foucs_on_count do |m, o|
          o[:focus_count]
        end
        expose :target_focus_on_count do |m, o|
          m.focus_target_count
        end    
        expose :scheme do |m, o|
          "#{ENV['H5_HOST']}/#/expedite_openaward"
        end  
      end
      
      class ActivityTag < Grape::Entity
        expose :scheme do |m, o|
          if o[:inner_app]
            m.app_inner_h5_scheme
          else
            m.app_outer_scheme   
          end
        end  
      end  
      
      class ActivityDetails < Grape::Entity
        expose :explain_scheme do |m, o|
          "#{ENV['H5_HOST']}/#/activity/explain"
        end 
        expose :current_foucs_on_count do |m, o|
          o[:focus_count]
        end
        expose :target_focus_on_count do |m, o|
          m.focus_target_count
        end         
        expose :focus_on_or_not do |m, o|
          o[:user].try(:focus_ons).try(:where,item: m).present?
        end
        expose :share do |m, o|
          {
            url: "#{ENV['H5_HOST']}/#/expedite_openaward",
            image: "https://go-beijing.oss-cn-beijing.aliyuncs.com/app/logo_3x.png",
            title: '奔驰开回家做人生赢家',
            summary: '成功发起5人拼单即可获取奔驰轿车抽奖劵'
          } 
        end
        expose :benzs, using: ::V1::Entities::Activity::ActivityTag do |m, o|
          o[:benzs]
        end
        expose :smarts, using: ::V1::Entities::Activity::ActivityTag do |m, o|
          o[:smarts]
        end    
        expose :histroy_messages do |m, o|
          "暂无历史开奖,本期为第一期开奖"
        end    
      end    
    end  
  end  
end  