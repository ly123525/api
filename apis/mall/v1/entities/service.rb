module V1
  module Entities
    module Service
      class DetailService < Grape::Entity
        expose :type_of do |m, o| 
          case m.class.to_s
            when '::Mall::Services::RefundService'
              "退款"
            when '::Mall::Services::ReturnAllService' 
              "退货退款" 
          end      
        end
        expose :refund_fee do |m, o|
          m.refund_fee.to_s
        end  
        expose :refund_cause
        expose :style_name do |m, o|
          m.product_name
        end
        expose :order_number do |m, o|
          m.order_or_item_number
        end 
        with_options(format_with: :timestamp) {expose :created_at}  

        expose :status      
      end
      
      class DetailServiceOfExpress < DetailService
        expose :service_message
        expose :express_tpye do |m, o|
          ['圆通','申通', '中通','顺丰','韵达','EMS', '宅急送', '天天' ]
        end
      end  
      
      class DetailServiceOfProduct < DetailService
        expose :product_details do |m, o|
          m.product_details
        end  
      end    
    end  
  end  
end  