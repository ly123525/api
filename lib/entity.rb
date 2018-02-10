require 'grape-entity'
module API
  module Entities
    Grape::Entity.class_eval do
      format_with :timestamp do | datetime |
        case datetime.beginning_of_day
        when Time.now.beginning_of_day then datetime.localtime.strftime('%H:%M')
        when Time.now.beginning_of_day-1.day then '昨天'+datetime.localtime.strftime('%H:%M')
        when Time.now.beginning_of_day-2.day then '前天'+datetime.localtime.strftime('%H:%M')
        else
          datetime.localtime.strftime(datetime.year==Time.now.year ? '%m-%d' : '%Y-%m-%d')
        end
      end
    end
  end
end
