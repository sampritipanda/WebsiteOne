class TimezoneRetrieverJob
  include SuckerPunch::Job

  def perform(user)
    ActiveRecord::Base.connection_pool.with_connection do
      tz = TimezoneRetrieverService.for(user)
      user.tz_name = tz.name
      user.tz_offset = tz.offset
      user.save
    end
  end
end
