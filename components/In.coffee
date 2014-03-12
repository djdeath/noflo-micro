noflo = require 'noflo'
gpio = require 'gpio'

class In extends noflo.Component
  description: 'A GPIO input'
  icon: 'sign-in'
  constructor: ->
    @inPorts =
      port: new noflo.Port 'number'
      sampling: new noflo.Port 'number'
    @outPorts =
      value: new noflo.Port 'number'

    @sampling = 250

    @inPorts.sampling.on 'data', (portNumber) =>
      @stopGpio()
      @startGpio()

    @inPorts.port.on 'data', (portNumber) =>
      @stopGpio()
      @portNumber = portNumber
      @startGpio()

  stopGpio: () ->
    return unless @gpio
    @gpio.removeAllListeners('change')
    @gpio.unexport()
    delete @gpio

  startGpio: () ->
    return unless @portNumber
    @gpio = gpio.export(@portNumber, { direction: 'in', interval: @sampling })
    @gpio.on 'change', (val) =>
      return unless @outPorts.value.isAttached()
      @outPorts.value.send(val)
      @outPorts.value.disconnect()

  shutdown: () ->
    @stopGpio()

exports.getComponent = -> new In
