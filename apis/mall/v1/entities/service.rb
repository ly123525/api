module V1
  module Entities
    module Service
      class DetailService < Grape::Entity
        expose :status do |m, o|
          case m.status
            when "service_processing"
              "#{m.service_name}等待商家确认"
            when "applied" 
              if m.class.to_s == 'Mall::Services::ReturnAllService' && !m.express_number.present? && !m.service_message.present?
                "#{m.service_name} 卖家已确认,请填写快递信息" 
              else
                "#{m.service_name} 卖家已确认" 
              end
            when "refunded"
              "已退款"
            when "closed"
              "申请已取消"
          end 
        end
        expose :status_image do |m, o|
          "https://gogo-bj.oss-cn-beijing.aliyuncs.com/app/my_tuihuanhuo_icon_white.png?x-oss-process=style/120w" if m.service_processing? || m.applied?
        end
        expose :created_at do |m, o|
          m.created_at.localtime.strftime('%y/%m/%d %H:%M:%S')
        end          
        expose :type_of do |m, o| 
          case m.class.to_s
            when 'Mall::Services::RefundService'
              "退款"
            when 'Mall::Services::ReturnAllService' 
              "退货退款" 
          end      
        end
        expose :refund_fee do |m, o|
          m.refund_fee.to_s
        end  
        expose :refund_cause   
      end
      
      class EditService < DetailService
        expose :description
      end  
      
      class DetailServiceOfExpress < DetailService
        expose :product_name do |m, o|
          m.product_name
        end
        expose :order_number do |m, o|
          m.order_or_item_number
        end
        expose :service_message
        expose :express_tpye do |m, o|
          ['圆通','申通', '中通','顺丰','韵达','EMS', '宅急送', '天天' ]
        end
      end  
      
      class DetailServiceOfProduct < DetailService
        expose :status_tips do |m, o|
          if m.service_processing?
            "7日后未确认，平台将接入帮您处理"
          end  
        end  
        expose :product_details do |m, o|
          m.product_details
        end
        expose :cancel_apply do |m, o|
          m.service_processing?
        end
        
        expose :modify_apply do |m, o|
          m.service_processing?
        end  
        
        expose :platform_appeal do |m, o|
          "lvsent://gogo.cn/im/chats?im_user_name=#{::Mall::Shop.first.im_user_name}" if m.service_processing?
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
        expose :detail_scheme do |m, o|
          if m.class.to_s == "Mall::Services::ReturnAllService" && m.applied? && !m.express_number.present? && !m.service_message.present?
            "http://39.107.86.17:8080/#/mall/services/express?uuid=#{m.uuid}"
          else  
            "http://39.107.86.17:8080/#/mall/services?uuid=#{m.uuid}"
          end
        end              
      end
      class ServiceOfOrder < Grape::Entity
        expose :refund_type do |m, o|
          if m.paid?
              {tips: "仅退款", tip_type: 'RefundService'}
          elsif  m.delivered? || m.received? 
              {tips: "退货退款", tip_type: 'ReturnAllService' } 
          end                  
        end
        expose :express_status_tips do |m, o|
          if m.paid?
              "待发货"
          elsif  m.delivered?
              "已发货"
          elsif m.received?
              "已收货"   
          end    
        end
        expose :refund_casue_tips do |m, o|
          ['买错了', '不想买了', '其他']
        end
        expose :refund_fee do |m, o|
          "￥ #{m.total_fee}"
        end  
        expose :mobile    
      end
      
      class CreateServiceResult < Grape::Entity
        expose :detail_scheme do |m, o|
          if m.class.to_s == "Mall::Services::ReturnAllService" && m.applied?
            "http://39.107.86.17:8080/#/mall/services/express?uuid=#{m.uuid}"
          else  
            "http://39.107.86.17:8080/#/mall/services?uuid=#{m.uuid}"
          end
        end         
      end
              
    end  
  end  
end  