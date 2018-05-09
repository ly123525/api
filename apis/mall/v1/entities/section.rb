module V1
  module Entities
    module Mall
      class Sections < Grape::Entity
        expose :title_bar, unless: lambda {|m, o | m.type == "Mall::Indices::Sections::WebView"} do |m, o|
          {image: m.picture.try(:image).try(:style_url,'400w'), scheme: nil}
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
      end  
    end   
  end  
end  