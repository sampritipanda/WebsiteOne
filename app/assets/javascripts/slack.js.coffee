API_TOKEN = "xoxp-2277434945-2277434949-2353959489-01c0c6"

class Slack
  constructor: ->
    @users = []
    @channels = []

  fetch_channels: ->
    channels = SlackAPI.get SlackAPI.parseURL('channels.list', token: API_TOKEN, exclude_archived: 1)
    return unless channels
    @channels = (Channel.parse(channel) for channel in channels)

  fetch_users: ->
    users = SlackAPI.get SlackAPI.parseURL('users.list', token: API_TOKEN, exclude_archived: 1)
    return unless users
    @users = (User.parse(user) for user in users)

  fetch_messages: ->
    channel.fetch_messages for channel in @channels

class SlackAPI
  @parseURL: (method, params) ->
    url = "https://api.slack.com/#{method}?" 
    for key in Object.keys(params)
      url += "#{key}=#{params[key]}&"
    url[0...-1] 

  @get: (url) ->
    $.getJSON url, (response) ->
      if not response.ok 
        alert response.error
        false
      else
        delete response.ok
        return response[Object.keys(response)[0]]

class Channel
  constructor: (@id, @name, @photo) ->
    @messages = []

  @parse: (json) ->
    @new(json.id, json.real_name || json.name, json.profile.image_48)

  fetch_messages: ->
    timestamp = if @messages.length is 1 then @messages.slice(-1).timestamp else 0
    message_count = 10
    messages = SlackAPI.get SlackAPI.parseURL('channels.history', token: API_TOKEN, channel: @id, oldest: timestamp.toString(), count: message_count)
    @messages.push (Message.parse(message) for message in messages)...

class User
  constructor: (@id, @name, @purpose) ->

  @parse: (json) ->
    @new(json.id, json.name, json.purpose.value)

class Message
  constructor: (@text, @type, @subtype, @timestamp, @user) ->

  @parse: (json) ->
    @new(json.text, json.type, json.subtype, json.timestamp, json.user)

slack = new Slack()
slack.fetch_channels
slack.fetch_users
window.setInterval ->
  slack.fetch_messages
, 1000
