class ChatController < ApplicationController
  include Tubesock::Hijack

  def chat
    hijack do |tubesock|
      # Listen on its own thread
      thread = Thread.new do
        # Needs its own redis connection to pub
        # and sub at the same time
        EventBus.subscribe(:chat) do |payload|
          tubesock.send_data payload[:message]
        end
      end

      tubesock.onmessage do |m|
        # pub the message when we get one
        # note: this echoes through the sub above
        EventBus.announce(:chat, message: m)
      end

      tubesock.onclose do
        # stop listening when client leaves
        thread.kill
      end
    end
  end
end
