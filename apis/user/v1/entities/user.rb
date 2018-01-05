module V1
  module Entities
    module User 
      class PersonalCenter < Grape::Entity
        expose :nickname
        expose :image
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
          [{name: "优惠券", scheme: nil, icon: 'http://img.zcool.cn/community/01bc79594e5a9ba8012193a32be580.jpg', dot_display: true },
          {name: "地址管理", scheme: nil, icon: 'http://img.zcool.cn/community/01bc79594e5a9ba8012193a32be580.jpg', dot_display: false },
          {name: "足迹", scheme: nil, icon: 'http://img.zcool.cn/community/01bc79594e5a9ba8012193a32be580.jpg', dot_display: false },
          {name: "官方客服", scheme: nil, icon: 'http://img.zcool.cn/community/01bc79594e5a9ba8012193a32be580.jpg', dot_display: false },
          {name: "设置", scheme: nil, icon: 'http://img.zcool.cn/community/01bc79594e5a9ba8012193a32be580.jpg', dot_display: false },
          {name: "收藏", scheme: nil, icon: 'http://img.zcool.cn/community/01bc79594e5a9ba8012193a32be580.jpg', dot_display: true }]
        end
      end
    end
  end
end
