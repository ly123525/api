class Cache
  attr_reader :cache

  # 使用默认配置初始化
  def initialize(redis_url, namespace)
    @cache = Redis.new(:url => redis_url, namespace: namespace)
  end
  
  # 缓存是否存活
  def alive?
    return !!@cache.ping rescue false
  end
  
  #读取数据
  #反序列化失败时返回不反序列化的结果，因为存储时String和Numeric类型对象不序列化
  def read(key)
    val = @cache.get(key)
    Marshal.load val
  rescue Redis::CannotConnectError => ex
    puts "[ERROR] #{ex.message}".red
    return nil
  rescue TypeError, ArgumentError
    return val
  end
  
  #批量读取数据
  def mread(keys)
    results = @cache.mget(keys)
    results.compact.map{|result| Marshal.load(result)} rescue nil
  rescue TypeError, ArgumentError
    nil
  end
  
  # 保存数据
  def write(key, val, expire = nil)
    if val.is_a?(String) || val.is_a?(Numeric)
      @cache.set(key, val)
    else
      @cache.set(key, Marshal.dump(val))
    end
    @cache.expire(key, expire) if expire
    
    return true;
  rescue Redis::CannotConnectError => ex
    puts "[ERROR] #{ex.message}".red
  rescue
    nil
  end
  
  # 批量保存数据
  def mwrite(vals, expire = nil)
    return false unless vals.is_a?(Array) || vals.blank? || vals.size%2!=0
    items = vals.map{|val|
      [val[0], val[1].is_a?(String) ? val[1] : Marshal.dump(val[1])]
    }
    @cache.mset(*items.flatten)
    vals.each do |val|
      @cache.expire(val[0], expire)
    end if expire
  rescue Redis::CannotConnectError => ex
    puts "[ERROR] #{ex.message}".red
  rescue
    nil
  end
  
  #判断是否存在
  def exists?(key)
    @cache.exists(key)
  rescue Redis::CannotConnectError => ex
    puts "[ERROR] #{ex.message}".red
  end
  
  #判断是否存在
  def del(key)
    @cache.del(key)
  rescue Redis::CannotConnectError => ex
      puts "[ERROR] #{ex.message}".red
      false
  rescue Redis::CommandError => ex
      puts "[ERROR] #{ex.message}".red
      false
  end
  
  def fetch(key, expire = nil)
    unless result = self.read(key)
      if block_given?
        result = yield
        self.write(key, result, expire)
      end
    end
    return result
  end
  
  # 转发缓存调用方法
  def method_missing(method, *args, &block)
    @cache.send(method, *args, &block) if alive?
  end
end
