module V1
  module Entities
    module User
      class UserForLogin < Grape::Entity
        expose :uuid
        expose :token do |m, o|
          o[:token]
        end
        expose :image do |m, o|
          m.picture.image.style_url('120w') rescue 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/head.png?x-oss-process=style/160w'
        end
        expose :
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
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1515145939529&di=a2e4332a1530d2604c1ea5d94896d438&imgtype=jpg&src=http%3A%2F%2Fonline.sccnn.com%2Fdesk2%2F1208%2Fcolourback_9013.jpg'
        end
        expose :to_be_paid_count do |m, o|
          
        end
        expose :waiting_delivery_count do |m, o|
          1
        end
        expose :waiting_receive_count do |m, o|
          
        end
        expose :waiting_evaluate_count do |m, o|
          
        end
        expose :customer_service_count do |m, o|
          
        end
        expose :section do |m, o|
          [{name: "优惠券", scheme: nil, icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/coupon_icon.png', dot_display: true },
          {name: "地址管理", scheme: 'http://39.107.86.17:8080/#/account/addresses', icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/address_icon.png', dot_display: false },
          {name: "足迹", scheme: 'http://39.107.86.17:8080/#/account/addresses?inner=true', icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/history_icon.png', dot_display: false },
          {name: "官方客服", scheme: 'https://39.107.86.17:8080/#/account/addresses?inner=true', icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/official_service_icon.png', dot_display: false },
          {name: "收藏", scheme: nil, icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/collect_icon.png', dot_display: true },
          {name: "设置", scheme: nil, icon: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/setting_icon.png', dot_display: false }]
        end
      end
    end
  end
end
