noflo = require 'noflo'
gpio = require 'gpio'

class MonitorPin extends noflo.Component
  description: 'Emit a boolean value each time a pin changes state.'
  icon: 'sign-in'
  constructor: ->
    @inPorts =
      pin: new noflo.Port 'number'
      sampling: new noflo.Port 'number'
    @outPorts =
      out: new noflo.Port 'boolean'

    @sampling = 250

    @inPorts.sampling.on 'data', (value) =>
      @stopGpio()
      @sampling = value
      @startGpio()

    @inPorts.pin.on 'data', (value) =>
      @stopGpio()
      @pinNumber = value
      @startGpio()

  stopGpio: () ->
    return unless @gpio
    @gpio.removeAllListeners('change')
    @gpio.reset()
    @gpio.unexport()
    delete @gpio

  startGpio: () ->
    return unless @pinNumber
    @gpio = gpio.export(@pinNumber, { direction: 'in', interval: @sampling })
    @gpio.on 'change', (val) =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(val != 0)
      @outPorts.out.disconnect()

  shutdown: () ->
    @stopGpio()

exports.getComponent = -> new MonitorPin
