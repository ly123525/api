module Grape
  class Entity
    format_with :timestamp do | datetime |
      case datetime.beginning_of_day
      when Time.now.beginning_of_day then datetime.localtime.strftime('%H:%M')
      when Time.now.beginning_of_day-1.day then '昨天'+datetime.localtime.strftime('%H:%M')
      when Time.now.beginning_of_day-2.day then '前天'+datetime.localtime.strftime('%H:%M')
      else
        datetime.localtime.strftime(datetime.year==Time.now.year ? '%m-%d' : '%Y-%m-%d')
      end
    end
    
    format_with :zh_timestamp do | datetime |
      case datetime.localtime.beginning_of_day
      when Time.now.beginning_of_day
        case datetime.localtime.strftime("%P")
        when "am"
          "上午 " + datetime.localtime.strftime('%H:%M')
        when "pm"
          "下午 " + (datetime - 12.hour).localtime.strftime('%H:%M')
        end 
      else
        case datetime.localtime.strftime("%P")
        when "am"
           datetime.localtime.strftime(datetime.year==Time.now.year ? '%m月%d日' : '%Y年%m月%d日') + " 上午 " + datetime.localtime.strftime("%H:%M")
        when "pm"
          datetime.localtime.strftime(datetime.year==Time.now.year ? '%m月%d日' : '%Y年%m月%d日') + " 下午 " + (datetime - 12.hour).localtime.strftime("%H:%M")
        end                    
      end  
    end  
  end
end
