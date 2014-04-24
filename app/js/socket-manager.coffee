App = require("./app.coffee")
Cookies = require("../../bower_components/cookies-js/src/cookies.js")

class SocketManager

  Socket: null

  constructor: (data) ->
    @Socket = io.connect "http://localhost:3002/"
    @Socket.emit 'HANDSHAKE', sid: Cookies.get("sid")
    @createListeners()


  createListeners: ->
    @Socket.on "MESSAGE", (data) ->
      console.log "MESSAGE: ", data
      App.chats.addMessage(data, "message")

    @Socket.on "NICK", (data) ->
      console.log "NICK: ", data

      oldnick = data.oldnick
      newnick = data.newnick
      channels = data.channels

      if oldnick == App.serverData.nick
        oldnick = "You are"
        App.setNick = newnick
      else
        oldnick = "#{oldnick} is"
      data.message = "#{oldnick} now known as #{newnick}"

      for channel in channels
        data.channel = channel
        App.chats.addMessage(data, "nick")

    @Socket.on "NAMES", (data) ->
      payload =
        channel: data.channel
        members: []
      for nick, attributes of data.nicks
        payload.members.push {nick: nick, attributes: attributes}
      console.log "payload", payload
      App.chats.addMembers(payload)

    @Socket.on "YOUARE", (data) ->
      App.chats.addMessage(message: JSON.stringify(data), "system")
      console.log "<< YOUARE", data


  connect: (data) -> @Socket.emit "CONNECT", data

  disconnect: -> console.log "SocketManager::disconnect()"

module.exports = new SocketManager()