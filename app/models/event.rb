class Event < ActiveRecord::Base
  has_one :hangout

  extend FriendlyId
  friendly_id :name, use: :slugged

  include IceCube
  validates :name, :event_date, :start_time, :end_time, :time_zone, :repeats, :category, presence: true
  validates :url, uri: true, :allow_blank => true
  validates :repeats_every_n_weeks, :presence => true, :if => lambda { |e| e.repeats == 'weekly' }
  validate :must_have_at_least_one_repeats_weekly_each_days_of_the_week, :if => lambda { |e| e.repeats == 'weekly' }
  #validate :from_must_come_before_to   // prevents events from bridging UTC midnight
  attr_accessor :next_occurrence_time

  #before_save :convert_event_date_to_utc # not necessary any more
  RepeatsOptions = %w[never weekly]
  RepeatEndsOptions = %w[never on]
  DaysOfTheWeek = %w[monday tuesday wednesday thursday friday saturday sunday]

  def self.next_event_occurrence
    if Event.exists?
      @events = []
      Event.where(['category = ?', 'Scrum']).each do |event|
        next_occurences = event.next_occurrences(start_time: 15.minutes.ago,
                                                 limit: 1)
        @events << next_occurences.first unless next_occurences.empty?
      end

      return nil if @events.empty?

      @events = @events.sort_by { |e| e[:time] }
      @events[0][:event].next_occurrence_time = @events[0][:time]
      return @events[0][:event]
    end
    nil
  end

  def next_occurrences(options = {})
    start_time = (options[:start_time] or 30.minutes.ago)
    end_time = (options[:end_time] or start_time + 10.days)
    limit = (options[:limit] or 100)

    [].tap do |occurences|
      occurrences_between(start_time, end_time).each do |time|
        occurences << { event: self, time: time }

        return occurences if occurences.count >= limit
      end
    end
  end

  def occurrences_between(start_time, end_time)
    schedule.occurrences_between(start_time, end_time)
  end

  def repeats_weekly_each_days_of_the_week=(repeats_weekly_each_days_of_the_week)
    self.repeats_weekly_each_days_of_the_week_mask = (repeats_weekly_each_days_of_the_week & DaysOfTheWeek).map { |r| 2**DaysOfTheWeek.index(r) }.inject(0, :+)
  end

  def repeats_weekly_each_days_of_the_week
    DaysOfTheWeek.reject do |r|
      ((repeats_weekly_each_days_of_the_week_mask || 0) & 2**DaysOfTheWeek.index(r)).zero?
    end
  end

  def from
      ActiveSupport::TimeZone[time_zone].parse(event_date.to_datetime.strftime('%Y-%m-%d')).beginning_of_day + start_time.seconds_since_midnight
  end

  def to
      ActiveSupport::TimeZone[time_zone].parse(event_date.to_datetime.strftime('%Y-%m-%d')).beginning_of_day + end_time.seconds_since_midnight
  end

  def duration
    d = to - from - 1
  end

  def schedule(starts_at = nil, ends_at = nil)
    starts_at ||= from
    ends_at ||= to
    if duration > 0
      s = IceCube::Schedule.new(starts_at, :ends_time => ends_at, :duration => duration)
    else
      s = IceCube::Schedule.new(starts_at, :ends_time => ends_at)
    end
    case repeats
      when 'never'
        s.add_recurrence_time(starts_at)
      when 'weekly'
        days = repeats_weekly_each_days_of_the_week.map {|d| d.to_sym }
        s.add_recurrence_rule IceCube::Rule.weekly(repeats_every_n_weeks).day(*days)
    end
    s
  end

  def start_time_with_timezone
    DateTime.parse(start_time.strftime('%k:%M ')).in_time_zone(time_zone)
  end


  def self.hookups
    Event.where(category: "PairProgramming")
  end


  def self.pending_hookups
    hookups.select(&:pending?)
  end

  def self.active_hookups
    hookups.select(&:active?)
  end

  #Started?:  A One-time event is started when it has an active hangout... in the current implementation, when it has a hangout which has started.  What about a repeating event?  With the current implementation, this is tricky, because it will always have a hookup which has started.
  def started?
    hangout.try!(:started?)
  end

  def pending?
    !started? && !expired?
  end

  def active?
    started? && !expired?
  end

  # Expired?:  A One-time event expires when the end_datetime is past.  But for repeating events, there are two expired concepts, one for a single instance (e.g. this morning's scrum) expiring, and one for the whole set of repeating events expiring.
  def expired?
    if repeats == 'never'
      Time.now.utc > end_datetime_utc
    else
      Time.now.utc > repeat_ends_on
    end
  end

  def start_date
    start_datetime_utc.to_date
  end

  def end_date
    if (end_time < start_time)
      #if (convert_time(end_time) < convert_time(start_time))
      return (event_date.to_datetime + 1.day).strftime('%Y-%m-%d').to_date
    else
      return event_date
    end
  end

  def start_datetime_utc
    start_date_time = Time.utc(event_date.year,
                               event_date.month,
                               event_date.day,
                               start_time.hour,
                               start_time.min,
                               start_time.sec)
  end

  def end_datetime_utc
    end_date_time = Time.utc(end_date.year,
                             end_date.month,
                             end_date.day,
                             end_time.hour,
                             end_time.min,
                             end_time.sec)
  end

  def start_time_with_timezone
    DateTime.parse(start_time.strftime('%k:%M ')).in_time_zone(time_zone)
  end

  def time_range_formatted
    start_time_format = start_time.strftime('%H:%M')
    end_time_format = end_time.strftime('%H:%M')
    " #{start_time_format}-#{end_time_format} UTC"
  end

  def date_formatted
    start_date.strftime('%F')
  end

  private
  def must_have_at_least_one_repeats_weekly_each_days_of_the_week
    if repeats_weekly_each_days_of_the_week.empty?
      errors.add(:base, 'You must have at least one repeats weekly each days of the week')
    end
  end

end
