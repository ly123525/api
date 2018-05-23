module V1
  module Entities
    module Activity
      class Lottery < Grape::Entity
        expose :name do |m, o|
          m.lottery_name
        end
        expose :categoty do |m, o|
          m.class.to_s.split("::").last
        end  
        expose :color_status do |m ,o|
          m.not_winning?
        end  
        expose :status_tips do |m, o|
          if m.not_lottery?
            "未开奖"
          elsif m.the_winning?
            "中奖"
          elsif m.not_winning?
            "未中奖"  
          end  
        end
        expose :number
        expose :nper do |m, o|
          "第一期"
        end 
      end  
      
      class Lotteries < Lottery
     
      end  
    end
  end
end      