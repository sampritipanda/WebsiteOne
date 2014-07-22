require 'spec_helper'

describe "hookups/index", type: :view do
  before do
    @pending_hookups = [FactoryGirl.build(:event, name: "Hookup 1", start_time: "09:00", end_time: "10:00", event_date: "2099-01-01", time_zone: "UTC", category: "PairProgramming")]
    @active_hookups = []
  end

  it "renders pending hookups table" do
    render
    expect(rendered).to have_text("Pending Hookups")
    expect(rendered).to have_text("Title")
    expect(rendered).to have_text("Time range")
    expect(rendered).to have_text("Actions")
  end

  it "displays a hookup event" do
    render

    expect(rendered).to have_text("Hookup 1")
    expect(rendered).to have_text("09:00-10:00")
    expect(rendered).not_to have_link("Create Hangout") # NOT LOGGED IN
  end
end


