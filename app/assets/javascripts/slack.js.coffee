class Slack
  constructor: ->
    @users = []
    @channels = []
    @messages = []
    @API_TOKEN = "xoxp-2277434945-2277434949-2353959489-01c0c6"

  fetch_channels: ->
    channels = SlackAPI.get SlackAPI.parseURL('channels.list', token: @API_TOKEN, exclude_archived: 1)
    return unless channels
    @channels = (Channel.parse(channel) for channel in channels)

  fetch_users: ->
    users = SlackAPI.get SlackAPI.parseURL('users.list', token: @API_TOKEN, exclude_archived: 1)
    return unless users
    @users = (Channel.parse(channel) for channel in users)


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
  constructor: (@id, @name, @purpose) ->

  @parse: (json) ->
    @new(json.id, json.name, json.purpose.value)

slack = new Slack
slack.fetch_channels
slack.fetch_users
slack.fetch_messages(10)

window.setInterval ->
  slack.fetch_messages(1)
, 1000
