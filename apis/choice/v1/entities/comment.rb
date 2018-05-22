module V1
  module Entities
    module Choice                  
      class Comments < Grape::Entity
        expose :uuid
        expose :nickname do |m, o|
          m.user.nickname
        end
        expose :head_image do |m, o|
          m.user.picture.image.style_url('120w') rescue "https://go-beijing.oss-cn-beijing.aliyuncs.com/app/head.png?x-oss-process=style/120w"
        end
        expose :content
        expose :created_at do |m, o|
          m.created_at.localtime.strftime('%y/%m/%d')
        end
      end
    end
  end
end
