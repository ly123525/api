require 'aliyun/cloud_sms'

Aliyun::CloudSms.configure do |config|
  config.access_key_secret = ENV['ALI_ACCESS_SECRET']
  config.access_key_id = ENV['ALI_ACCESS_ID']
  config.sign_name = '全民拼'
end