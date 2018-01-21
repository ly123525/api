require "carrierwave"
require "carrierwave-aliyun"
require "carrierwave/orm/activerecord"

CarrierWave.configure do |config|
  config.storage = :aliyun
  config.aliyun_access_id = ENV['OSS_ACCESS_ID']
  config.aliyun_access_key = ENV['OSS_ACCESS_KEY']
  config.aliyun_bucket = ENV['OSS_BUCKET']
  config.aliyun_internal = false
  config.aliyun_area = ENV['OSS_REGION']
  # config.aliyun_host = "https://foo.bar.com"
end


# 需要解决上传新文件，老文件删除问题