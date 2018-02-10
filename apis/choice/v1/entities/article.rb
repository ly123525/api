module V1
  module Entities
    module Choice
      class Articles < Grape::Entity
        expose :title
        expose :summary
        with_options(format_with: :timestamp) {expose :created_at}
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
        expose :shop, using: ::V1::Entities::Mall::SimpleShop
        expose :share do |m, o|
          {
            url: "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://39.107.86.17:8080/#/choice/articles?uuid=#{m.uuid}"),
            image: (m.pictures.sorted.last.image.style_url('480w') rescue nil),
            title: m.title,
            summary: m.summary
          }
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://39.107.86.17:8080/#/choice/articles?uuid=#{m.uuid}")
        end
        expose :comments_scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://39.107.86.17:8080/#/choice/articles?uuid=#{m.uuid}")
        end
      end
    end
  end
end
