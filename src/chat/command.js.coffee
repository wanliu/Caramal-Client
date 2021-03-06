define ['core', 'util'], (Caramal, Util) ->

  class CommandOption
    default_options: {
      maximum_reply: 0,         # 最大命令回复数
      alive_timeout: 5000,      # 等待时长
      default_action: null,     # 超过默认触发
      repeat_reply: false       # 可否重复回复
    }

    constructor: (@options) ->
      @options = {} unless Util.isObject(@options)
      @options['id'] ||= Util.generateId()

      Util.merge @options, @default_options
      @methodlizm(@options)

    methodlizm: (hash) ->
      for k,v of hash
        @[k] = v

  class Command

    constructor: (@channel, @name, @options = {}) ->

      @socket = @channel.socket
      @option = new CommandOption(@options)

    execute: (data, callback) ->
      data = value if value = @_doBeforeCallback(data)
      @doExecute(data, callback)

    doExecute: (data, callback) ->
      ;

    beforeExecute: (@before_callback) ->

    afterExecute: (@after_callback) ->

    onReturnExecute: (@return_callback) ->

    _doBeforeCallback: (args) ->
      if Util.isFunc(@before_callback)
        args = [args] unless Util.isArray(args)

        @before_callback.apply(@, args)

    _doAfterCallback: (args) ->

      if Util.isFunc(@after_callback)
        args = [args] unless Util.isArray(args)

        @after_callback.apply(@, args)

    _doReturnCallback: (args) ->
      if Util.isFunc(@return_callback)
        @return_callback(args)

        args = [args] unless Util.isArray(args)

        @return_callback.apply(@, args)

    sendCommand: (cmd, data = {}, callback ) ->
      send_data = Util.merge {
                    command_id: @option.id,
                  }, data

      @socket.emit cmd, send_data, (args...) =>
        first = args[0]
        if Util.isObject(first) and first.error?
          @onError(first)
        else
          @_doAfterCallback(args)
          args.unshift(@channel)
          callback.apply(@,args) if Util.isFunc(callback)

    onError: (msg) ->
      @channel.emit('error', msg)

  class OpenCommand extends Command

    doExecute: (data = {}, callback) ->
      @sendCommand 'open', data, callback

  class JoinCommand extends Command

    doExecute: (data, callback = null) ->
      unless data?
        data = {room: @channel.room }
      else
        data = {room: data}

      @sendCommand 'join', data, callback

  class CloseCommand extends Command

    doExecute: (data, callback = null) ->
      @sendCommand 'leave', data, callback
 
  class RecordCommand extends Command

    doExecute: (data, callback = null) ->
      unless data?
        data = { room: @channel.room }
      else
        room = if data.room then data.room else data
        data = { room: room }

      @sendCommand 'record', data, callback

  class StopRecordCommand extends Command

    doExecute: (data, callback = null) ->
      data = {room: @channel.room }
      @sendCommand 'stop_record', data, callback


  class HistoryCommand extends Command

    doExecute: (data, callback = null) ->
      data = { room: @channel.room , start: data.start, step: data.step || 10, type: 'index' }

      @sendCommand 'history', data, callback

  Caramal.Command = Command
  Caramal.OpenCommand = OpenCommand
  Caramal.JoinCommand = JoinCommand
  Caramal.CloseCommand = CloseCommand
  Caramal.RecordCommand = RecordCommand
  Caramal.HistoryCommand = HistoryCommand
  Caramal.StopRecordCommand = StopRecordCommand

