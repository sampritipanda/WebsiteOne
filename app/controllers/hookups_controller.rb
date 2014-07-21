class HookupsController < ApplicationController
  def index
    @pending_hookups = Event.pending_hookups
    @active_hookups = Event.active_hookups
  end
end
