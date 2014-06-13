require 'spec_helper'

describe Event do
  before :each do
    @default_tz = ENV['TZ']
    ENV['TZ'] = 'UTC'
  end

  after :each do
    Delorean.back_to_the_present
    ENV['TZ'] = @default_tz
  end

  it 'should respond to friendly_id' do
    Event.new.should respond_to :friendly_id
  end

  it 'should respond to "schedule" method' do
    Event.respond_to?('schedule')
  end

  context 'return false on invalid inputs' do
    before do
      @event = FactoryGirl.create(:event)
    end
    it 'nil :name' do
      @event.name = ''
      expect(@event.save).to be_false
    end

    it 'nil :category' do
      @event.category = nil
      expect(@event.save).to be_false
    end

    it 'nil :repeats' do
      @event.repeats = nil
      expect(@event.save).to be_false
    end
  end

  context 'should create an event that ' do
    it 'is scheduled for one occasion' do
      event = Event.create!(name: 'one time event',
                            category: 'Scrum',
                            description: '',
                            event_date: 'Mon, 17 Jun 2013',
                            start_time: '2000-01-01 09:00:00 UTC',
                            end_time: '2000-01-01 17:00:00 UTC',
                            repeats: 'never',
                            repeats_every_n_weeks: nil,
                            repeat_ends: 'never',
                            repeat_ends_on: 'Mon, 17 Jun 2013',
                            time_zone: 'Eastern Time (US & Canada)')
      expect(event.schedule.first(5)).to eq(['Mon, 17 Jun 2013 09:00:00 EDT -04:00'])
      expect(event.schedule.first(5)).not_to eq(['Sun, 16 Jun 2013 09:00:00 EDT -04:00'])
      expect(event.schedule.first(5)).not_to eq(['Tue, 18 Jun 2013 00:00:00 EDT -04:00'])
    end

    it 'is scheduled for every weekend' do
      event = Event.create!(name: 'every weekend event',
                            category: 'Scrum',
                            description: '',
                            event_date: 'Mon, 17 Jun 2013',
                            start_time: '2000-01-01 09:00:00 UTC',
                            end_time: '2000-01-01 17:00:00 UTC',
                            repeats: 'weekly',
                            repeats_every_n_weeks: 1,
                            repeats_weekly_each_days_of_the_week_mask: 96,
                            repeat_ends: 'never',
                            repeat_ends_on: 'Tue, 25 Jun 2013',
                            time_zone: 'Eastern Time (US & Canada)')
      expect(event.schedule.first(5)).to eq(['Sat, 22 Jun 2013 09:00:00 EDT -04:00', 'Sun, 23 Jun 2013 09:00:00 EDT -04:00', 'Sat, 29 Jun 2013 09:00:00 EDT -04:00', 'Sun, 30 Jun 2013 09:00:00 EDT -04:00', 'Sat, 06 Jul 2013 09:00:00 EDT -04:00'])
      expect(event.schedule.first(7)).not_to eq(['Mon, 17 Jun 2013 09:00:00 EDT -04:00i', 'Tue, 18 Jun 2013 09:00:00 EDT -04:00', 'Wed, 19 Jun 2013 09:00:00 EDT -04:00', 'Thu, 20 Jun 2013 09:00:00 EDT -04:00', 'Fri, 21 Jun 2013 09:00:00 EDT -04:00', 'Mon, 24 Jun 2013 09:00:00 EDT -04:00', 'Tue, 25 Jun 2013 09:00:00 EDT -04:00'])
    end

    it 'is scheduled for every Sunday' do
      event = Event.create!(name: 'every Sunday event',
                            category: 'Scrum',
                            description: '',
                            event_date: 'Mon, 17 Jun 2013',
                            start_time: '2000-01-01 09:00:00 UTC',
                            end_time: '2000-01-01 17:00:00 UTC',
                            repeats: 'weekly',
                            repeats_every_n_weeks: 1,
                            repeats_weekly_each_days_of_the_week_mask: 64,
                            repeat_ends: 'never',
                            repeat_ends_on: 'Mon, 17 Jun 2013',
                            time_zone: 'Eastern Time (US & Canada)')
      expect(event.schedule.first(5)).to eq(['Sun, 23 Jun 2013 09:00:00 EDT -04:00', 'Sun, 30 Jun 2013 09:00:00 EDT -04:00', 'Sun, 07 Jul 2013 09:00:00 EDT -04:00', 'Sun, 14 Jul 2013 09:00:00 EDT -04:00', 'Sun, 21 Jul 2013 09:00:00 EDT -04:00'])
      expect(event.schedule.first(5)).not_to eq(['Mon, 17 Jun 2013 09:00:00 EDT -04:00', 'Mon, 24 Jun 2013 09:00:00 EDT -04:00', 'Mon, 01 Jul 2013 09:00:00 EDT -04:00', 'Mon, 08 Jul 2013 09:00:00 EDT -04:00', 'Mon, 15 Jul 2013 09:00:00 EDT -04:00'])
    end

    it 'is scheduled for every Monday' do
      event = Event.create!(name: 'every Monday event',
                            category: 'Scrum',
                            description: '',
                            event_date: 'Mon, 17 Jun 2013',
                            start_time: '2000-01-01 09:00:00 UTC',
                            end_time: '2000-01-01 17:00:00 UTC',
                            repeats: 'weekly',
                            repeats_every_n_weeks: 1,
                            repeats_weekly_each_days_of_the_week_mask: 1,
                            repeat_ends: 'never',
                            repeat_ends_on: 'Mon, 17 Jun 2013',
                            time_zone: 'UTC')
      expect(event.schedule.first(5)).to eq(['Mon, 17 Jun 2013 09:00:00 GMT +00:00', 'Mon, 24 Jun 2013 09:00:00 GMT +00:00', 'Mon, 01 Jul 2013 09:00:00 GMT +00:00', 'Mon, 08 Jul 2013 09:00:00 GMT +00:00', 'Mon, 15 Jul 2013 09:00:00 GMT +00:00'])
    end
  end

  context 'Event url' do
    before (:each) do
      @event = {name: 'one time event',
               category: 'Scrum',
               description: '',
               event_date: 'Mon, 17 Jun 2013',
               start_time: '2000-01-01 09:00:00 UTC',
               end_time: '2000-01-01 17:00:00 UTC',
               repeats: 'never',
               repeats_every_n_weeks: nil,
               repeat_ends: 'never',
               repeat_ends_on: 'Mon, 17 Jun 2013',
               time_zone: 'Eastern Time (US & Canada)'}
    end

    it 'should be set if valid' do
      event = Event.create!(@event.merge(:url => 'http://google.com'))
      expect(event.save).to be_true
    end

    it 'should be rejected if invalid' do
      event = Event.create(@event.merge(:url => 'http:google.com'))
      event.should have(1).error_on(:url)
    end
  end

  describe 'Event#next_occurence' do
    let(:event) do
      stub_model(Event,
                 name: 'Spec Scrum',
                 event_date: '2014-03-07',
                 start_time: '10:30:00',
                 time_zone: 'UTC',
                 end_time: '11:00:00',
                 repeats: 'weekly',
                 repeats_every_n_weeks: 1,
                 repeats_weekly_each_days_of_the_week_mask: 0b1111111,
                 repeat_ends: 'never',
                 repeat_ends_on: 'Tue, 25 Jun 2015',
                 friendly_id: 'spec-scrum')
    end

    let(:options) { {} }
    let(:next_occurrences) { event.next_occurrences(options) }
    let(:next_occurrence_time) { next_occurrences.first[:time].time }

    it 'should return the next occurence of the event' do
      Delorean.time_travel_to(Time.parse('2014-03-07 09:27:00 UTC'))
      expect(next_occurrence_time).to eq(Time.parse('2014-03-07 10:30:00 UTC'))
    end

    context 'with input arguments' do
      context ':limit option' do
        let(:options) { { limit: 2 } }

        it 'should limit the size of the output' do
          Delorean.time_travel_to(Time.parse('2014-03-08 09:27:00 UTC'))
          expect(next_occurrences.count).to eq(2)
        end
      end

      context ':start_time option' do
        let(:options) { { start_time: Time.parse('2014-03-09 9:27:00 UTC') } }

        it 'should return only occurrences after a specific time' do
          Delorean.time_travel_to(Time.parse('2014-03-05 09:27:00 UTC'))
          expect(next_occurrence_time).to eq(Time.parse('2014-03-09 10:30:00 UTC'))
        end
      end
    end
  end

  describe 'Event.next_event_occurence' do
    let(:event) do
      stub_model(Event,
                 name: 'Spec Scrum',
                 event_date: '2014-03-07',
                 start_time: '10:30:00',
                 time_zone: 'UTC',
                 end_time: '11:00:00',
                 friendly_id: 'spec-scrum')
    end

    before(:each) do
      Event.stub(:exists?).and_return true
      Event.stub(:where).and_return [ event ]
    end

    it 'should return the next event occurence' do
      Delorean.time_travel_to(Time.parse('2014-03-07 09:27:00 UTC'))
      expect(Event.next_event_occurrence).to eq event
    end

    it 'should have a 15 minute buffer' do
      Delorean.time_travel_to(Time.parse('2014-03-07 10:44:59 UTC'))
      expect(Event.next_event_occurrence).to eq event
    end

    it 'should not return events that occured more than 15 minutes ago' do
      Delorean.time_travel_to(Time.parse('2014-03-07 10:45:01 UTC'))
      expect(Event.next_event_occurrence).to be_nil
    end
  end

  it 'should raise error if there are no repeats weekly each days of the week' do
    @event = stub_model(Event)
    @event.stub(repeats_weekly_each_days_of_the_week: [])
    @event.errors.should_receive(:add).with(:base, 'You must have at least one repeats weekly each days of the week')
    @event.instance_eval { must_have_at_least_one_repeats_weekly_each_days_of_the_week }
  end

  describe "#repeats_weekly_each_days_of_the_week=" do
    it 'sets the repeats weekly mask' do
      event = FactoryGirl.build(:event)
      event.should_receive(:repeats_weekly_each_days_of_the_week_mask=)
      event.repeats_weekly_each_days_of_the_week = ["monday", "tuesday", ""]
    end

    it "sets proper mask for all days of the week" do
      event = FactoryGirl.build(:event)
      event.repeats_weekly_each_days_of_the_week = %w[monday tuesday wednesday thursday friday saturday sunday]
      event.repeats_weekly_each_days_of_the_week_mask.to_s(2).should eq "1111111"
    end

    it 'sets the correct mask for some days of the week' do
      event = FactoryGirl.build(:event)
      event.repeats_weekly_each_days_of_the_week = %w[monday wednesday friday saturday]
      event.repeats_weekly_each_days_of_the_week_mask.to_s(2).should eq "110101"
    end
  end
end
