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
        expose :category do |m, o|
          m.class.to_s.split("::").last
        end  
        expose :color_status do |m ,o|
          ！m.not_winning?
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
          m.activity_item.activity.name
        end
        expose :list_url do |m, o|
          "#{ENV['H5_HOST']}/#/raffletickets" if o[:inner_app]
        end
        expose :down_load_scheme do |m, o|
          unless o[:inner_app]
            case o[:os]
              when 'Android'
                "http://a.app.qq.com/o/simple.jsp?pkgname=com.lst.go"
              when 'IOS'
                'https://itunes.apple.com/cn/app/id1369799402?mt=8' 
            end     
          end  
        end     
      end  
      
      class Lotteries < Grape::Entity
        expose :name do |m, o|
          m.lottery_name
        end
        expose :category do |m, o|
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
          m.activity_item.activity.name
        end     
      end  
    end
  end
end      