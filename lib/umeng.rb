# module Umeng
#   class Push
#
#     $umeng_ios = Umeng::Client.new(ENV['UMENG_iOS_APP_KEY'], ENV['UMENG_iOS_SECRET'], 'iOS')
#     $umeng_android = Umeng::Client.new(ENV['UMENG_ANDROID_APP_KEY'], ENV['UMENG_ANDROID_SECRET'], 'Android')
#
#     class << self
#       # 广播
#       def push_broadcast opts={}
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
