module V1
  module Entities
    module User
      class Message < Grape::Entity
        expose :title
        expose :image do |m, o|
          'https://gogo-bj.oss-cn-beijing.aliyuncs.com/app/touxiang.png?x-oss-process=style/160w'
        end
        expose :message_type do |m, o|
          case m.type
            when "Messages::SystemMessage"
              "系统"
            when "Messages::UserMessage"
              "通知"
          end     
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://39.107.86.17:8080/#/messages/destail")
        end
        expose :status do |m, o|
          ::MessageReadRecord.read? m, o[:user]
        end
        expose :time do |m, o|
          m.created_at.localtime.strftime('%y/%m/%d')
        end          
      end
      
      class Messages < Grape::Entity
        expose :title
        expose :image do |m, o|
          m.picture.image.style_url('120w') rescue nil
        end
        expose :body do |m, o|
          m.content
        end
        expose :time do |m, o|
          m.created_at.localtime.strftime('%y/%m/%d') 
        end      
      end    
    end  
  end  
end  