module V1
  module Entities
    module Choice
      class Article < Grape::Entity
        expose :uuid
        expose :title
        expose :details
        expose :comments, using: ::V1::Entities::Choice::Comments do |m, o|
          m.comments.limit(2)
        end
        expose :comments_count do |m, o|
          m.comments.count
        end
        expose :laud_good_count do |m, o|
          m.good_lauds.count
        end
        expose :laud_good do |m, o|
          o[:good_article_ids].include?(m.id)
        end
        expose :laud_bad_count do |m, o|
          m.bad_lauds.count
        end
        expose :laud_bad do |m,o|
          o[:bad_article_ids].include?(m.id)
        end
        expose :images do |m, o|
          m.pictures.map{|picture| picture.image.style_url('480w') } rescue nil
        end
        expose :shop, using: ::V1::Entities::Mall::Shop
        expose :collection_or_not do |m, o|
          o[:user_ids].include?(o[:user_id])
        end
        expose :collections_count do |m, o|
            m.collections.count
        end
         expose :share do |m, o|
          {
            url: "http://39.107.86.17:8080/#/choice/articles?uuid=#{m.uuid}",
            # image: (m.pictures.sorted.last.image.style_url('480w') rescue nil),
            image: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/product_bg_square.png?x-oss-process=style/300w',
            title: m.title,
            summary: m.summary
          }
        end
      end

      class ChoiceArticles < Grape::Entity
        expose :uuid
        expose :title
        expose :shop, using: ::V1::Entities::Mall::Shop
        expose :images do |m, o|
          m.pictures.map{|picture| picture.image.style_url('480w') } rescue nil
        end
      end

      class Articles < Grape::Entity
        expose :uuid
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
        expose :laud_good do |m, o|
          o[:article_ids].include?(m.id)
        end
        expose :shop, using: ::V1::Entities::Mall::SimpleShop
        expose :share do |m, o|
          {
            url: "http://39.107.86.17:8080/#/choice/articles?uuid=#{m.uuid}",
            # image: (m.pictures.sorted.last.image.style_url('480w') rescue nil),
            image: 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/product_bg_square.png?x-oss-process=style/300w',
            title: m.title,
            summary: m.summary
          }
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://39.107.86.17:8080/#/choice/articles?uuid=#{m.uuid}").delete("=")
        end
        expose :comments_scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://39.107.86.17:8080/#/choice/articles?uuid=#{m.uuid}").delete("=")
        end
      end
    end
  end
end
