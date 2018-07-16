module V1
  module Entities
    module Mall
      class PayResult < Grape::Entity
        expose :image do |m, o|
          "#{ENV['IMAGE_DOMAIN']}/app/vip_pay_success.png" if m.paid?
        end
        expose :tips do |m, o|
          if m.paid?
            "支付成功"
          else
            "支付失败"  
          end  
        end
        expose :total_fee do |m, o|
         "￥ #{format('%.2f',m.total_fee)}"
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/vip"
        end          
      end
    end
  end
end        