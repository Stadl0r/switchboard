# class Participant(
#   id,
#   displayIndex,
#   hasMicrophone,
#   hasCamera,
#   hasAppEnabled,
#   isBroadcaster,
#   isInBroadcast,
#   locale,
#   person,
#   person.id,
#   person.displayName,
#   person.image,
#   person.image.url )

socket = './socket.coffee'
main = require './main.coffee'

class EventHandler
  logging: true
  main: null

  constructor: ->
    @setupEvents()
    @getConnectionData()

  setupEvents: ->
    socket.on 'message', (data) =>
      main.addMessage({from: data.from, message: data.message})

    socket.on 'setConnectionData', (data) =>
      console.log data
      main.setUser(data)

    # {channel, nick, message}
    socket.on 'PART', (data) =>
      console.log data.channel, data.nick, data.message
      main.addPart(data)

    # {channel, nick, message}
    socket.on 'JOIN', (data) =>
      console.log data.channel, data.nick, data.message
      main.addJoin(data)

    # {oldnick, newnick, channels, message}
    socket.on 'NICK', (data) =>
      console.log data.oldnick, data.newnick, data.channels
      main.setNick(data)
    # });

    # # onApiReady
    # gapi.hangout.onApiReady.add (event) =>
    #   ####################################
    #   # @clearState() # THIS IS FOR DEV ONLY
    #   ####################################

    #   window.main.setUser @getUserData([gapi.hangout.getLocalParticipant()])[0]
    #   participants = #gapi.hangout.getParticipants()
    #   @log "onApiReady", participants
    #   window.main.addUsers @getUserData(participants)

    # # onParticipantsAdded
    # gapi.hangout.onParticipantsAdded.add (event) =>
    #   @log "onParticipantsAdded", event.addedParticipants
    #   window.main.addUsers @getUserData(event.addedParticipants)

    # # onParticipantsRemoved
    # gapi.hangout.onParticipantsRemoved.add (event) =>
    #   @log "onParticipantsRemoved", event.removedParticipants
    #   window.main.removeUsers @getUserData(event.removedParticipants)

    # # onStateChanged
    # gapi.hangout.data.onStateChanged.add (event) =>
    #   @log "onStateChanged", event.state
    #   window.main.updateState event.state

    # # onMessageReveived
    # gapi.hangout.data.onMessageReceived.add (event) =>
    #   @log "onMessageReceived", event
    #   @log "getParticipantById", @getMessageData(event)
    #   window.main.addMessage(@getMessageData(event))

  getConnectionData: ->
    console.log "getConnectionData"
    socket.emit("getConnectionData")


  setNick: (nick) ->
    console.log "setNick", nick
    socket.emit("setNick", {nick: nick})

  # THIS IS FOR DEV ONLY
  clearState: ->
    keys = gapi.hangout.data.getKeys()
    for key in keys
      @sendState(key, 1)
      gapi.hangout.data.clearValue(key)

  getMessageData: (event) ->
    # sid = data["sid"]
    # msg = @toLink(data["data"])
    # who = @getAvatar(sid)

    # # data{sid: sid, name: dude, data: msg}
    p = gapi.hangout.getParticipantById(event.senderId)
    return msg =
      sid: p.id
      name: p.person.displayName
      data: event.message

  getUserData: (persons) ->
    data = persons.map (p) ->
      sid: p.id
      name: p.person.displayName
      image: p.person.image.url
    return data

  sendState: (sid, state) ->
    gapi.hangout.data.setValue("#{sid}", "#{state}")

  sendMessage: (message) ->
    socket.emit("message", {message: message});

  log: (params...) ->
    console.log(params) if @logging


  module.exports = EventHandler



