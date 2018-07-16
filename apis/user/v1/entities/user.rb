module V1
  module Entities
    module User
      class SimpleUser < Grape::Entity
        expose :name
        expose :image do |m, o|
          m.picture.image.style_url('120w') rescue "#{ENV['IMAGE_DOMAIN']}/app/head.png?x-oss-process=style/160w"
        end
      end  
      class UserForLogin < Grape::Entity
        expose :uuid
        expose :token do |m, o|
          o[:token]
        end
        expose :image do |m, o|
          m.picture.image.style_url('120w') rescue "#{ENV['IMAGE_DOMAIN']}/app/head.png?x-oss-process=style/160w"
        end
        expose :nickname
        expose :im_user_name
        expose :im_password
        expose :user_info_scheme do |m, o|
          "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/backdoor")
        end  
      end
      
      class PersonalCenter < Grape::Entity
        expose :nickname, if: lambda {|m, o| m[:user].present?} do |m, o|
          m[:user].nickname
        end  
        expose :image, if: lambda {|m, o| m[:user].present?} do |m, o|
          m.picture.image.style_url('120w') rescue "#{ENV['IMAGE_DOMAIN']}/app/head.png?x-oss-process=style/160w"
        end
        expose :member_tags, if: lambda {|m, o| m[:user].present?} do |m, o|
          if m[:user].is_vip
            'VIP社员'
          else
            '社员'  
          end  
        end
        expose :is_vip, if: lambda {|m, o| m[:user].present?} do |m, o|
          m[:user].is_vip
        end    
        expose :sex, if: lambda {|m, o| m[:user].present?} do |m, o|
          m[:user].sex
        end  
        expose :birthday, if: lambda {|m, o| m[:user].present?} do |m, o|
          m[:user].birthday
        end  
        expose :motto, if: lambda {|m, o| m[:user].present?} do |m, o|
          m[:user].motto
        end  
        expose :top_background, if: lambda {|m, o| m[:user].present?} do |m, o|
          nil
        end
        expose :account_infos do |m, o|
          ::Account::Account.account_and_lottery_infos m[:user]
        end
        expose :to_be_paid_count, if: lambda {|m, o| m[:user].present?} do |m, o|
          
        end
        expose :waiting_delivery_count, if: lambda {|m, o| m[:user].present?} do |m, o|
          
        end
        expose :waiting_receive_count, if: lambda {|m, o| m[:user].present?} do |m, o|
          
        end
        expose :waiting_evaluate_count, if: lambda {|m, o| m[:user].present?} do |m, o|
          
        end
        expose :customer_service_count, if: lambda {|m, o| m[:user].present?} do |m, o|
          
        end
        expose :refund_service_scheme, if: lambda {|m, o| m[:user].present?} do |m, o|
          "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/services")
        end
        expose :vip_infos do
          expose :title_tips do |m, o|
            "VIP社员专区"
          end
          expose :tips do |m, o|
            "成为VIP社员将享受全额返现的超级福利"
          end
          expose :background do |m, o|
            "#{ENV['IMAGE_DOMAIN']}/app/vip_member_background.png"  
          end
          expose :section do |m, o|
            [
              {image: "#{ENV['IMAGE_DOMAIN']}/app/cashback.png", tips: '全额返', scheme:'lvsent://gogo.cn/vip/right'},
              {image: "#{ENV['IMAGE_DOMAIN']}/app/work_score.png", tips: '工分', scheme:'lvsent://gogo.cn/vip/right'},
              {image: "#{ENV['IMAGE_DOMAIN']}/app/discount.png", tips: '社员专享', scheme:'lvsent://gogo.cn/vip/right'},
              {image: "#{ENV['IMAGE_DOMAIN']}/app/peer_mutual_assistance.png", tips: '互助惠', scheme:'lvsent://gogo.cn/vip/right'},
              {image: "#{ENV['IMAGE_DOMAIN']}/app/customer_service.png", tips: '专属客服', scheme:'lvsent://gogo.cn/vip/right'}
            ]
           end         
        end  
        expose :section, if: lambda {|m, o| m[:user].present?} do |m, o|
          [
          {name: "地址管理", scheme: "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/account/addresses?from=personal_center"), icon: "#{ENV['IMAGE_DOMAIN']}/app/address_icon.png", dot_display: false },
          {name: "足迹", scheme: "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/footprints"), icon: "#{ENV['IMAGE_DOMAIN']}/app/history_icon.png", dot_display: false },
          {name: "官方客服", scheme: "lvsent://gogo.cn/im/chats?im_user_name=#{::Mall::Shop.first.im_user_name}", icon: "#{ENV['IMAGE_DOMAIN']}/app/official_service_icon.png", dot_display: false },
          {name: "收藏", scheme: "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/collections"), icon: "#{ENV['IMAGE_DOMAIN']}/app/collect_icon.png", dot_display: false },
          {name: "卡券", scheme: "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/raffletickets"), icon: "#{ENV['IMAGE_DOMAIN']}/app/lottery.png", dot_display: false }
        ]
        end  
      end
      class UserInfo < Grape::Entity
        expose :uuid,:token,:im_user_name,:umeng_token,:wx_open_id,:wx_unionid, if: lambda {|m,o| m.is_developer?}
        private
        def token
          token= object.phone_tokens.last.token if object.wx_open_id.blank?
          token=object.wechat_tokens.last.token unless object.wx_open_id.blank?
          token
        end
      end
      class VipMember < Grape::Entity
        expose :user_image do |m, o|
          m[:user].picture.image.style_url('120w') rescue "#{ENV['IMAGE_DOMAIN']}/app/head.png?x-oss-process=style/160w"
        end
        expose :title_tips do |m, o|
          "8.8元开通VIP社员" unless m[:user].present? && m[:user].is_vip
        end
        expose :is_vip do |m, o|
          m[:user].present? && m[:user].is_vip
        end
        expose :become_vip_button do |m, o|
          {scheme: "lvsent://gogo.cn/vip/right", tips: '开通VIP社员' } unless m[:user].present? && m[:user].is_vip
        end
        expose :tips do |m, o|
          "VIP社员全额返现/5折优惠/更有机会将奔驰开回家" unless m[:user].present? && m[:user].is_vip
        end
        expose :account_infos do |m, o|
          ::Account::Account.account_infos m[:user] if m[:user].present? && m[:user].is_vip
        end
        expose :background do |m, o|
          if m[:user].present? && m[:user].is_vip
            "#{ENV['IMAGE_DOMAIN']}/app/vip_member_background.png"
          else  
            "#{ENV['IMAGE_DOMAIN']}/app/common_member_background.png"
          end  
        end
        expose :section do |m, o|
          [
            {image: "#{ENV['IMAGE_DOMAIN']}/app/cashback.png", tips: '全额返', scheme:'lvsent://gogo.cn/vip/right'},
            {image: "#{ENV['IMAGE_DOMAIN']}/app/work_score.png", tips: '工分', scheme:'lvsent://gogo.cn/vip/right'},
            {image: "#{ENV['IMAGE_DOMAIN']}/app/discount.png", tips: '社员专享', scheme:'lvsent://gogo.cn/vip/right'},
            {image: "#{ENV['IMAGE_DOMAIN']}/app/peer_mutual_assistance.png", tips: '互助惠', scheme:'lvsent://gogo.cn/vip/right'},
            {image: "#{ENV['IMAGE_DOMAIN']}/app/customer_service.png", tips: '专属客服', scheme:'lvsent://gogo.cn/vip/right'}
          ]
         end   
        expose :styles, using: ::V1::Entities::Mall::SimpleProductByStyle do |m, o|
          o[:styles]
        end                  
      end  
    end
  end
end
