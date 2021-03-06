require 'active_record'
require 'active_support'
require 'yaml'
require 'grape'
require 'grape-entity'
require './lib/grape_entity'
require 'require_all'
require 'grape-swagger'
require 'rack/cors'
require 'aasm'
require 'paranoia'
require 'rack-console'
require 'mysql2'
require 'easemob'
require 'umeng/client'
require 'kaminari'
require 'colorize'
require "redis"
require "redis-namespace"
require "weixin_authorize"
require "wx_pay"
require './lib/wxpay'
require "acts_as_list"
require "alipay"
require "awesome_nested_set"
if  ENV['SERVER_ENV']=='production' || ENV['SERVER_ENV']=='staging'
  require 'newrelic_rpm'
end
unless ENV['SERVER_ENV']=='production'
  require 'pry_debug'
  require 'pry-nav'
end

# 预加载
require_all 'lib', 'apis', 'middleware'

namespace = "api:base:auth"
$redis = Cache.new(ENV['REDIS'], namespace)

$number_redis = Redis.new(url: ENV['REDIS'])

if ENV['SERVER_ENV']=='development'
  # 静态文件
  use Rack::Static, :urls => ["/docs/"], :root => "public"
end

# 启用 CORS 来支持外部请求
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [ :get, :post, :put, :delete, :options ]
  end
end

# I18n
I18n.load_path += Dir[File.expand_path(File.dirname(__FILE__)) + "/config/locales/*.{rb,yml}"]
# I18n.config.enforce_available_locales = false
I18n.config.available_locales += ["zh-CN"]
I18n.default_locale = :"zh-CN"

# 设置时区
# http://api.rubyonrails.org/classes/ActiveRecord/Timestamp.html
# ActiveRecord::Base.time_zone_aware_attributes = true
# ActiveRecord::Base.default_timezone = :local

# 缓存机制
use Rack::ETag
# 连接池
use ActiveRecord::ConnectionAdapters::ConnectionManagement
# Grape 运行
run API::Base
