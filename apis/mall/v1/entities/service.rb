module V1
  module Entities
    module Service
      class DetailService < Grape::Entity
        expose :status do |m, o|
          case m.status
            when "created"
              "#{m.service_name}等待卖家确认"
            when "applied" 
              if m.class.to_s == 'Mall::Services::ReturnAllService' && !m.express_number.present? && !m.express.present?
                "#{m.service_name} 卖家已确认,请填写快递信息" 
              else
                "#{m.service_name} 等待卖家退款" 
              end
            when "refunded"
              "#{m.service_name} 已退款"
            when "closed"
              "#{m.service_name} 申请已取消"
          end 
        end
        expose :status_image do |m, o|
          "#{ENV['IMAGE_DOMAIN']}/app/my_tuihuanhuo_icon_white.png?x-oss-process=style/120w" if m.created? || m.applied?
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
      
      class EditService < Grape::Entity
        expose :type_of do |m, o| 
          case m.class.to_s
            when 'Mall::Services::RefundService'
              "退款"
            when 'Mall::Services::ReturnAllService' 
              "退货退款" 
          end      
        end  
        expose :refund_cause
        expose :refund_cause_tips do |m, o|
          ['买错了', '不想买了', '其他']
        end         
        expose :description
        expose :mobile
        expose :images do |m, o|
          m.pictures.map{|picture| picture.image.url}
        end
        expose :refund_fee  
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
          if m.created?
            "7日后未确认，平台将接入帮您处理"
          end  
        end  
        expose :product_details do |m, o|
          m.product_details
        end
        expose :cancel_apply do |m, o|
          m.created?
        end
        
        expose :modify_apply do |m, o|
          m.created?
        end  
        
        expose :platform_appeal do |m, o|
          "lvsent://gogo.cn/im/chats?im_user_name=#{::Mall::Shop.first.im_user_name}" if m.created?
        end    
      end
      
      class Services < Grape::Entity
        expose :status do |m, o|
          case m.status
            when "created"
              "#{m.service_name}等待卖家确认"
            when "applied" 
              if m.class.to_s == 'Mall::Services::ReturnAllService' && !m.express_number.present? && !m.express.present?
                "#{m.service_name} 卖家已确认,请填写快递信息" 
              else
                "#{m.service_name} 等待卖家退款" 
              end
            when "refunded"
              "#{m.service_name} 已退款"
            when "closed"
              "#{m.service_name} 申请已取消"
          end       
        end
        expose :uuid  
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
          m.created? || m.applied?
        end
        expose :express_scheme do |m, o|
         "#{ENV['H5_HOST']}/#/services/need_delivery?uuid=#{m.uuid}" if m.class.to_s == "Mall::Services::ReturnAllService" && m.applied? && !m.express_number.present? && !m.service_message.present?
        end
        expose :detail_scheme do |m, o|
          if m.refunded? && m.closed?
            if m.class.to_s == "Mall::Services::ReturnAllService" && m.applied? && !m.express_number.present? && !m.service_message.present?
              "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/services/need_delivery?uuid=#{m.uuid}")
            else  
              "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/service?uuid=#{m.uuid}")
            end
          end  
        end
        expose :detail_url do |m, o|
          if m.class.to_s == "Mall::Services::ReturnAllService" && m.applied? && !m.express_number.present? && !m.service_message.present?
            "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/services/need_delivery?uuid=#{m.uuid}")
          else  
            "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/service?uuid=#{m.uuid}")
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
        expose :mobile    
      end
      
      class CreateServiceResult < Grape::Entity
        expose :detail_scheme do |m, o|
          if m.class.to_s == "Mall::Services::ReturnAllService" && m.applied?
            "#{ENV['H5_HOST']}/#/services/need_delivery?uuid=#{m.uuid}"
          else  
            "#{ENV['H5_HOST']}/#/service?uuid=#{m.uuid}"
          end
        end         
      end
              
    end  
  end  
end  