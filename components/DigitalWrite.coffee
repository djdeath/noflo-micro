noflo = require 'noflo'
gpio = require 'gpio'

class DigitalWrite extends noflo.Component
  description: 'Write a boolean value to pin'
  icon: 'sign-out'
  constructor: ->
    @inPorts =
      pin: new noflo.Port 'number'
      in: new noflo.Port 'boolean'

    @value = null
    @inPorts.pin.on 'data', (pinNumber) =>
      @stopGpio()
      @pinNumber = pinNumber
      @startGpio()
    @inPorts.in.on 'data', (value) =>
      @setValue(value)

  setValue: (value) ->
    @value = value
    return unless @gpio
    @gpio.set(if @value then 1 else 0)

  stopGpio: () ->
    return unless @gpio
    @gpio.reset()
    @gpio.unexport()
    delete @gpio

  startGpio: () ->
    return unless @pinNumber
    @gpio = gpio.export(@pinNumber, { direction: 'out' })
    @gpio.on 'directionChange', () =>
      if @value != null
        @gpio.set(if @value then 1 else 0)

  shutdown: () ->
    @stopGpio()

exports.getComponent = -> new DigitalWrite
