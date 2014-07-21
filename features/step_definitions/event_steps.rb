Given(/^I am on Events index page$/) do
  visit events_path
end

Given(/^following events exist:$/) do |table|
  table.hashes.each do |hash|
    Event.create!(hash)
  end
end

Given(/^following hangouts exist:$/) do |table|
  table.hashes.each do |hash|
    Hangout.create!(hash)
  end
end

Then(/^I should be on the Events "([^"]*)" page$/) do |page|
  case page.downcase
    when 'index'
      current_path.should eq events_path

    when 'create'
      current_path.should eq events_path

    else
      pending
  end
end

Then(/^I should see multiple "([^"]*)" events$/) do |event|
  #puts Time.now
  page.all(:css, 'a', text: event, visible: false).count.should be > 1
end

When(/^the next event should be in:$/) do |table|
  table.rows.each do |period, interval|
    page.should have_content([period, interval].join(' '))
  end
end

Given(/^I am on the show page for event "([^"]*)"$/) do |name|
  event = Event.find_by_name(name)
  visit event_path(event)
end

Then(/^I should be on the event "([^"]*)" page for "([^"]*)"$/) do |page, name|
  event = Event.find_by_name(name)
  page.downcase!
  case page
    when 'show'
      current_path.should eq event_path(event)

    else
      current_path.should eq eval("#{page}_event_path(event)")

  end
end
Given(/^the date is "([^"]*)"$/) do |jump_date|
  Delorean.time_travel_to(Time.parse(jump_date))
end


Given(/^the events are all active$/) do
  allow_any_instance_of(Event).to receive(:active?).and_return(true)
end

When(/^I follow "([^"]*)" for pending hookup "([^"]*)"$/) do |linkid, hookup_number|
  links=page.all(:css, "table#pending_hookups td##{linkid} a")
  link= links[hookup_number.to_i() -1]
  link.click
end

When(/^I follow "([^"]*)" for active hookup "([^"]*)"$/) do |linkid, hookup_number|
  links=page.all(:css, "table#active_hookups td##{linkid} a")
  link= links[hookup_number.to_i() -1]
  link.click
end

Then(/^I should be on the Edit Events page for "([^"]*)"$/) do |arg|
  expect(current_path).to eq "/events/#{arg}/edit"
end
Then(/^I should be on the Create Events page for "([^"]*)"$/) do |arg|
  expect(current_path).to eq "/events/#{arg}"
end
