module V1
  module Entities
    module Mall
      class Sections < Grape::Entity
        expose :title_bar, unless: lambda {|m, o | m.type == "Mall::Indices::Sections::WebView"} do |m, o|
          {image: m.picture.try(:image).url, scheme: nil}
        end
        expose :style do |m, o|
          m.type.underscore.split('/').last
        end
        expose :items, using: ::V1::Entities::Mall::SectionItems, unless: lambda {|m, o | m.type == "Mall::Indices::Sections::WebView"} do |m, o|
          m.section_items
        end
        expose :url, if: lambda {|m, o | m.type == "Mall::Indices::Sections::WebView"} do |m, o|
          "#{ENV['H5_HOST']}/#/raffle/resourcelocation"          
        end  
        expose :activity_scheme, if: lambda {|m, o | m.type == "Mall::Indices::Sections::WebView"} do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64(m.scheme)
        end
        expose :width, if: lambda {|m, o | m.type == "Mall::Indices::Sections::WebView"} do |m, o|
          3
        end
        expose :hight, if: lambda {|m, o | m.type == "Mall::Indices::Sections::WebView"} do |m, o|
          1
        end            
      end  
    end   
  end  
end  