module V1
  module Entities
    module Activity
      class Lottery < Grape::Entity
        expose :user_image do |m, o|
          m.picture.image.style_url('120w') rescue "#{ENV['IMAGE_DOMAIN']}/app/head.png?x-oss-process=style/160w"  unless o[:inner_app]
        end  
        expose :name do |m, o|
          m.lottery_name
        end
        expose :color do |m, o|
          m.lottery_template.color
        end   
        expose :status_tips do |m, o|
          if m.not_lottery?
            "未开奖"
          elsif m.the_winning?
            "中奖"
          elsif !m.not_winning?
            "未中奖"  
          end  
        end
        expose :number do |m, o|
          m.number.join('')
        end 
        expose :nper do |m, o|
          m.lottery_template.activity.sub_name
        end
        expose :list_url do |m, o|
          "#{ENV['H5_HOST']}/#/raffletickets" if o[:inner_app]
        end     
      end 
      
      class Lotteries < Grape::Entity
        expose :name do |m, o|
          m.lottery_name
        end
        expose :color do |m, o|
          m.lottery_template.color
        end  
        expose :color_status do |m ,o|
          m.not_winning?
        end  
        expose :status_tips do |m, o|
          if m.not_lottery?
            "未开奖"
          elsif m.the_winning?
            "中奖"
          elsif !m.not_winning?
            "未中奖"  
          end  
        end
        expose :number do |m, o|
          m.number.join('')
        end  
        expose :nper do |m, o|
          m.lottery_template.activity.sub_name
        end                     
      end   
      
      class Lotteries_list < Grape::Entity
        expose :waiting_lottery_count do |m, o|
          m
        end  
        expose :lotteries, using: ::V1::Entities::Activity::Lotteries do |m, o|
          o[:lotteries]
        end  
      end  
    end
  end
end      