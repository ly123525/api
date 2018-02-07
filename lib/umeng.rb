# module Umeng
#   class Push
#
#     $umeng_ios = Umeng::Client.new(ENV['UMENG_iOS_APP_KEY'], ENV['UMENG_iOS_SECRET'], 'iOS')
#     $umeng_android = Umeng::Client.new(ENV['UMENG_ANDROID_APP_KEY'], ENV['UMENG_ANDROID_SECRET'], 'Android')
#
#     class << self
#       # 广播
#       def push_broadcast opts={}
#         queue = {plantform_type: 'iOS', data: {title: 'title',content: 'content',information_id: 'information_id',paragraph_id: 'paragraph_id',notification_type: 'information',information_type: 'editor_chosen'}}
#         abs = {
#           production_mode: queue_hash[:queue_hash],
#           display_type: queue_hash[:display_type],
#           content: queue_hash[:data][:content],
#           key_value: queue_hash[:data]
#         }
#         $umeng_ios.push_broadcast(abs)
#         $umeng_android.push_broadcast(abs)
#       end
#
#       # 单推
#       def push_unicast token, opts={}
#         umeng_ios.push_unicast(token, opts)
#         umeng_android.push_unicast(token, opts)
#       end
#
#       # tokens 列表推送
#       def push_listcast token, opts={}
#         umeng_ios.push_listcast(token, opts)
#         umeng_android.push_listcast(token, opts)
#       end
#     end
#   end
# end
