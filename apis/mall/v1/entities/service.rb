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
      
      class Services < Grape::Entity
        expose :status do |m, o|
          case m.status
            when "service_processing"
              "#{m.service_name} 申请中..."
            when "applied" 
              "#{m.service_name} 卖家已确认"
            when "closed"
              "已取消"
          end       
        end  
        expose :shop, using: ::V1::Entities::Mall::SimpleShop do |m, o|
          m.service_target.try(:shop) || m.service_target.try(:order).try(:shop)
        end
        expose :product, using: ::V1::Entities::Mall::ProductByOrderItem do |m, o|
          m.service_target_type == 'Mall::Order' ? m.service_target.order_items.first : m.service_target
        end
        expose :total_fee do |m, o|
          "￥ "+m.refund_fee.to_s
        end
        expose :cancel_apply_scheme do |m, o|
          m.service_processing? || m.applied?
        end
        expose :express_scheme do |m, o|
          m.service_processing?
        end
        expose :check_details_scheme do |m, o|
          m.service_processing? || m.applied?
        end
        expose :scheme do |m, o|
          "http://39.107.86.17:8080/#/mall/services?uuid=#{m.uuid}"
        end              
      end      
    end  
  end  
end  