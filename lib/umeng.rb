module Umeng
  class Push

    $umeng_ios = Umeng::Client.new(ENV['UMENG_iOS_APP_KEY'], ENV['UMENG_iOS_SECRET'], 'iOS')
    $umeng_android = Umeng::Client.new(ENV['UMENG_ANDROID_APP_KEY'], ENV['UMENG_ANDROID_SECRET'], 'Android')

    class << self
      # opts{title, body, scheme}
      def android_opts opts={}
        {
          key_value: opts,
          production_mode: true,
          description: opts[:title]
        }
      end
      
      # opts{title, body, scheme}
      def ios_opts opts={}
        {
          key_value: {"content": opts},
          production_mode: false,
          description: opts[:title]
        }
      end
      
      # 广播
      def push_broadcast opts={}
        $umeng_ios.push_broadcast(opts)
        $umeng_android.push_broadcast(opts)
      end

      # 单推
      # token 友盟设备唯一标识, Android的device_token是44位字符串，iOS的device_token是64位 [多特么脑残]
      # opts{title, body, scheme}
      def push_unicast token, opts={}
        $umeng_ios.push_unicast(token, android_opts(opts)) if token.to_s.size==44
        $umeng_android.push_unicast(token, ios_opts(opts)) if token.to_s.size==64
      end

      # tokens 列表推送
      def push_listcast tokens, opts={}
        android_tokens = tokens.find_all{|token| token.to_s.size==44}
        ios_tokens = tokens.find_all{|token| token.to_s.size==64}
        $umeng_ios.push_listcast(android_tokens, android_opts(opts))
        $umeng_android.push_listcast(ios_tokens, ios_opts(opts))
      end
    end
  end
end
