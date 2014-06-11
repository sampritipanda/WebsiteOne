class TimezoneRetrieverJob
  include SuckerPunch::Job

  def perform(user)
    ActiveRecord::Base.connection_pool.with_connection do
      tz = TimezoneRetrieverService.for(user)
      user.update_attributes(tz_name: tz.name, tz_offset: tz.offset)
    end
  end
end
