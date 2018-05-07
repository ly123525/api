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
        expose :nickname
        expose :image do |m, o|
          m.picture.image.style_url('120w') rescue "#{ENV['IMAGE_DOMAIN']}/app/head.png?x-oss-process=style/160w"
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
        expose :refund_service_scheme do |m, o|
          "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/services")
        end  
        expose :section do |m, o|
          [
          {name: "地址管理", scheme: "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/account/addressess?type=personal"), icon: "#{ENV['IMAGE_DOMAIN']}/app/address_icon.png", dot_display: false },
          {name: "足迹", scheme: "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/footprints"), icon: "#{ENV['IMAGE_DOMAIN']}/app/history_icon.png", dot_display: false },
          {name: "官方客服", scheme: "lvsent://gogo.cn/im/chats?im_user_name=#{::Mall::Shop.first.im_user_name}", icon: "#{ENV['IMAGE_DOMAIN']}/app/official_service_icon.png", dot_display: false },
          {name: "收藏", scheme: "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/collections"), icon: "#{ENV['IMAGE_DOMAIN']}/app/collect_icon.png", dot_display: false }
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
    end
  end
end
