require 'spec_helper'

describe HookupsController, type: :controller do
  it 'assigns a pending hookup to the view' do
    event = FactoryGirl.create Event, category: "PairProgramming"
    allow_any_instance_of(Event).to receive(:pending?).and_return(true)
    get :index
    expect(assigns(:pending_hookups)[0]).to eq(event)
  end

  it 'assigns an active hookup for the view' do
    event = FactoryGirl.create Event, category: "PairProgramming"
    allow_any_instance_of(Event).to receive(:active?).and_return(true)
    get :index
    expect(assigns(:active_hookups)[0]).to eq(event)
  end
end
