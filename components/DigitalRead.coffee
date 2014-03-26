noflo = require 'noflo'
gpio = require 'gpio'

class DigitalRead extends noflo.Component
  description: 'Read a boolean value from pin. Value is read on @trigger'
  icon: 'sign-in'
  constructor: ->
    @inPorts =
      trigger: new noflo.Port 'bang'
      pin: new noflo.Port 'number'
    @outPorts =
      out: new noflo.Port 'boolean'

    @inPorts.trigger.on 'data', (value) =>
      return unless @gpio and @outPorts.out.isAttached()
      val = if @gpio.value != 0 then true else false
      @outPorts.out.send(val)
      @outPorts.out.disconnect()

    @inPorts.pin.on 'data', (portNumber) =>
      @stopGpio()
      @pinNumber = pinNumber
      @startGpio()

  stopGpio: () ->
    return unless @gpio
    @gpio.removeAllListeners('change')
    @gpio.unexport()
    delete @gpio

  startGpio: () ->
    return unless @pinNumber
    @gpio = gpio.export(@pinNumber, { direction: 'in', interval: @sampling })

  shutdown: () ->
    @stopGpio()

exports.getComponent = -> new DigitalRead
