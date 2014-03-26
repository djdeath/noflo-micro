noflo = require 'noflo'
gpio = require 'gpio'

class DigitalWrite extends noflo.Component
  description: 'Write a boolean value to pin'
  icon: 'sign-out'
  constructor: ->
    @inPorts =
      pin: new noflo.Port 'number'
      in: new noflo.Port 'boolean'

    @inPorts.pin.on 'data', (pinNumber) =>
      @stopGpio()
      @pinNumber = pinNumber
      @startGpio()
    @inPorts.in.on 'data', (value) =>
      @setValue(value)

  setValue: (value) ->
    return unless @gpio
    @gpio.set(if value then 0 else 1)

  stopGpio: () ->
    return unless @gpio
    @gpio.reset()
    @gpio.unexport()
    delete @gpio

  startGpio: () ->
    return unless @pinNumber
    @gpio = gpio.export(@pinNumber, { direction: 'out' })

  shutdown: () ->
    @stopGpio()

exports.getComponent = -> new DigitalWrite
