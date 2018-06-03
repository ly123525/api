# require "carrierwave"
require "carrierwave-aliyun"
require "carrierwave/orm/activerecord"

CarrierWave.configure do |config|
  config.storage = :aliyun
  config.aliyun_access_id = ENV['ALI_ACCESS_ID']
  config.aliyun_access_key = ENV['ALI_ACCESS_SECRET']
  config.aliyun_bucket = ENV['ALI_OSS_BUCKET']
  config.aliyun_internal = false
  config.aliyun_area = ENV['ALI_OSS_REGION']
  config.aliyun_host = ENV['IMAGE_DOMAIN']
end


# 需要解决上传新文件，老文件删除问题