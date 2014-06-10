API_TOKEN = "xoxp-2277434945-2277434949-2353959489-01c0c6"

class Slack
  constructor: ->
    @users = []
    @channels = []

  fetch_channels: ->
    SlackAPI.get SlackAPI.parseURL('channels.list', token: API_TOKEN, exclude_archived: 1), "channels"
    channels = window.WebsiteOne.temp_ajax_response
    return unless channels
    @channels = (Channel.parse(channel) for channel in channels)

  fetch_users: ->
    SlackAPI.get SlackAPI.parseURL('users.list', token: API_TOKEN, exclude_archived: 1), "members"
    users = window.WebsiteOne.temp_ajax_response
    return unless users
    @users = (User.parse(user) for user in users)

  #fetch_messages: ->
  #  channel.fetch_messages() for channel in @channels

  clear_channel_messages: ->
    (channel.messages = []) for channel in @channels

  find_channel: (id) ->
    return channel for channel in @channels when channel.id == id

  find_user: (id) ->
    return user for user in @users when user.id == id

class SlackAPI
  @parseURL: (method, params) ->
    url = "https://slack.com/api/#{method}?" 
    for key in Object.keys(params)
      url += "#{key}=#{params[key]}&"
    url[0...-1] 

  @get: (url, key) ->
    $.ajax
      dataType: "json",
      url: url,
      async: false,
      success: (response) ->
        if not response.ok 
          alert response.error
          false
        else
          window.WebsiteOne.temp_ajax_response = response[key]

class Channel
  constructor: (@id, @name, @purpose) ->
    @messages = []
    $('#chat #channels').append("<li><a id='#{@id}'>#{@name}</li></a>")

  @parse: (json) ->
    new Channel(json.id, json.name, json.purpose.value)

  fetch_messages: (method) ->
    timestamp = if @messages.length >= 1 then @messages[0].timestamp else 0
    message_count = 10
    SlackAPI.get SlackAPI.parseURL('channels.history', token: API_TOKEN, channel: @id, oldest: timestamp.toString(), count: message_count), "messages"
    messages = window.WebsiteOne.temp_ajax_response
    @messages.unshift((Message.parse(message, method) for message in messages)...)

class User
  constructor: (@id, @name, @photo) ->

  @parse: (json) ->
    new User(json.id, json.real_name || json.name, json.profile.image_48)

class Message
  constructor: (@text, @type, @timestamp, @user, @hidden, @method) ->
    $('#chat #messages')[@method]("<li>#{@user}: #{@text}</li>") unless @hidden

  @parse: (json, method) ->
    new Message(json.text, json.type, json.ts, json.user, (json.hidden? and json.hidden), method)

$ ->
  slack = new Slack()
  slack.fetch_channels()
  slack.fetch_users()
  $("#chat #channels li a").on "click", ->
    $("#chat #messages").text("")
    channel = slack.find_channel(this.id)
    slack.clear_channel_messages()
    for i in [1..99999] 
      window.clearInterval(i)
      window.clearTimeout(i)
    channel.fetch_messages("prepend")
    window.setInterval ->
      channel.fetch_messages("append")
    , 3000
