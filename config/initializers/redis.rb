def redis_client
  if ENV["REDISCLOUD_URL"]
    Redis.new(:url => ENV["REDISCLOUD_URL"])
  else
    Redis.new
  end
end