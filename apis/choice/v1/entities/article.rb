module V1
  module Entities
    module Choice   
      class Articles < Grape::Entity
        expose :title
        expose :summary
        expose :created_at, format_with: :timestamp
        expose :images do |m, o|
          m.pictures.map{|picture| picture.image.style_url('480w') } rescue nil
        end
        expose :share_count do |m, o|
          m.share_statistics.count
        end
        expose :comment_count do |m, o|
          m.comments.count
        end
        expose :laud_good_count do |m, o|
          m.good_lauds.count
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://39.107.86.17:8080/#/choice/articles?uuid=#{m.uuid}")
        end
      end
    end
  end
end
