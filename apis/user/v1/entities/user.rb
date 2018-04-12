module V1
  module Entities
    module User
      class SimpleUser < Grape::Entity
        expose :name
        expose :image do |m, o|
          m.picture.image.style_url('120w') rescue 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/head.png?x-oss-process=style/160w'
        end
      end  
      class UserForLogin < Grape::Entity
        expose :uuid
        expose :token do |m, o|
          o[:token]
        end
        expose :image do |m, o|
          m.picture.image.style_url('120w') rescue 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/head.png?x-oss-process=style/160w'
        end
        expose :nickname
        expose :im_user_name
        expose :im_password
      end
      
      class PersonalCenter < Grape::Entity
        expose :nickname
        expose :image do |m, o|
          m.picture.image.style_url('120w') rescue 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/head.png?x-oss-process=style/160w'
        end
        expose :sex
        expose :birthday
        expose :motto
        expose :top_background do |m, o|
          nil
        end
        expose :to_be_paid_count do |m, o|
          
        end
        expose :waiting_delivery_count do |m, o|
          
        end
        expose :waiting_receive_count do |m, o|
          
        end
        expose :waiting_evaluate_count do |m, o|
          
        end
        expose :customer_service_count do |m, o|
          
        end
        expose :section do |m, o|
          [
          {name: "地址管理", scheme: "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("http://39.107.86.17:8080/#/account/addresses?type='personal'"), icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/address_icon.png', dot_display: false },
          {name: "足迹", scheme: "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("http://39.107.86.17:8080/#/footprint"), icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/history_icon.png', dot_display: false },
          {name: "官方客服", scheme: "lvsent://gogo.cn/im/chats?im_user_name=#{::Mall::Shop.first.im_user_name}", icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/official_service_icon.png', dot_display: false },
          {name: "收藏", scheme: "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("http://39.107.86.17:8080/#/good_goods"), icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/collect_icon.png', dot_display: false },
          {name: "设置", scheme: 'lvsent://gogo.cn/settings', icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/setting_icon.png', dot_display: false }]
        end
      end
    end
  end
end
