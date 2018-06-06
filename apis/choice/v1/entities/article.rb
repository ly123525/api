module V1
  module Entities
    module Choice
      class Article < Grape::Entity
        expose :uuid
        expose :title
        expose :details do |m, o|
          m.details.gsub('lvsent://gogo.cn/mall/products', "#{ENV['H5_HOST']}/#/mall/details") unless o[:inner_app]
        end  
        expose :comments, using: ::V1::Entities::Choice::Comments do |m, o|
          m.comments.limit(2)
        end
        expose :comments_count do |m, o|
          m.comments.count
        end
        expose :laud_good_count do |m, o|
          m.good_lauds.count
        end
        expose :laud_good_tip do |m, o|
          "靠谱"
        end  
        expose :laud_good do |m, o|
          o[:good_article_ids].include?(m.id)
        end
        expose :laud_bad_count do |m, o|
          m.bad_lauds.count
        end
        expose :collection_tip do |m, o|
          "收藏"
        end  
        # expose :laud_bad do |m,o|
        #   o[:bad_article_ids].include?(m.id)
        # end
        expose :images do |m, o|
          m.pictures.map{|picture| picture.image.style_url('480w') } rescue nil
        end
        expose :shop, using: ::V1::Entities::Mall::SimpleShopForH5
        expose :collection_or_not do |m, o|
          o[:user_ids].include?(o[:user_id])
        end
        expose :resource_uuid do |m, o|
          m.uuid
        end
        expose :resource_type do |m, o|
          m.class.to_s
        end 
        expose :share do |m, o|
          {
            url: "#{ENV['H5_HOST']}/#/choice/article?uuid=#{m.uuid}",
            # image: (m.pictures.sorted.last.image.style_url('480w') rescue nil),
            image: "#{ENV['IMAGE_DOMAIN']}/app/product_bg_square.png?x-oss-process=style/300w",
            title: m.title,
            summary: m.summary
          }
        end
      end

      class ChoiceArticles < Grape::Entity
        expose :uuid
        expose :title
        expose :summary
        expose :shop, using: ::V1::Entities::Mall::Shop
        expose :image do |m, o|
          m.pictures.first.image.style_url('480w') rescue nil
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/choice/article?uuid=#{m.uuid}")
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
        expose :shop, using: ::V1::Entities::Mall::SimpleShopForChoice
        expose :resource_uuid do |m, o|
          m.uuid
        end
        expose :resource_type do |m, o|
          m.class.to_s
        end 
        expose :share do |m, o|
          {
            url: "#{ENV['H5_HOST']}/#/choice/article?uuid=#{m.uuid}",
            # image: (m.pictures.sorted.last.image.style_url('480w') rescue nil),
            image: "#{ENV['IMAGE_DOMAIN']}/app/product_bg_square.png?x-oss-process=style/300w",
            title: m.title,
            summary: m.summary
          }
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/choice/article?uuid=#{m.uuid}")
        end
        expose :comments_scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/choice/articles/comment?article_uuid=#{m.uuid}")
        end
      end
    end
  end
end
