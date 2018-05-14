module V1
  module Entities
    module Activity
      class Activity < Grape::Entity
        expose :current_foucs_on_count do |m, o|
          o[:focus_count]
        end
        expose :target_focus_on_count do |m, o|
          m.focus_target_count
        end    
        expose :scheme do |m, o|
          "#{ENV['H5_HOST']}/#/expedite_openaward"
        end  
      end  
    end  
  end  
end  