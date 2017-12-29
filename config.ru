require 'active_record'
require 'active_support'
require 'grape'
require 'grape-entity'
require 'require_all'
require 'grape-swagger'
require 'rack/cors'
require 'pry_debug'
require 'pry-nav'

# I18n
I18n.load_path += Dir[File.expand_path(File.dirname(__FILE__)) + "/config/locales/*.{rb,yml}"]
# I18n.config.enforce_available_locales = false
I18n.config.available_locales += ["zh-CN"]
I18n.default_locale = :"zh-CN"

# 加载
require_all 'apis', 'lib', 'middleware'
# 缓存机制
use Rack::ETag
# 静态文件
use Rack::Static, :urls => ["/docs/"], :root => "public"
# grape-swagger配置，启用 CORS 来支持外部请求
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [ :get, :post, :put, :delete, :options ]
  end
end
# 连接池
use ActiveRecord::ConnectionAdapters::ConnectionManagement
# Grape 运行
run API::Base
