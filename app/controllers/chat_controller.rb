require 'open-uri'

class ChatController < ApplicationController
  include Tubesock::Hijack

  def chat
    hijack do |tubesock|
      # Listen on its own thread
      thread = Thread.new do
        # Needs its own redis connection to pub
        # and sub at the same time
        EventBus.subscribe(:chat) do |message|
          tubesock.send_data message[:message]
        end
        @timestamp = 1
        while(true)
          @json = JSON.parse(open('https://slack.com/api/channels.history?token=xoxp-2277434945-2277434949-2353959489-01c0c6&channel=C0285CSUH&count=1&pretty=1').read)
          if @json["messages"][0]["ts"].to_f > @timestamp
            EventBus.publish(:chat, message: @json["messages"][0]["text"])
            @timestamp = @json["messages"][0]["ts"].to_f
          end
        end
      end

      tubesock.onmessage do |m|
        # pub the message when we get one
        # note: this echoes through the sub above
        debugger
        EventBus.announce(:chat, message: m)
      end

      tubesock.onclose do
        # stop listening when client leaves
        thread.kill
      end
    end
  end
end
