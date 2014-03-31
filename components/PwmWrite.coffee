noflo = require 'noflo'
pwm = require 'pwm'

class PwmWrite extends noflo.Component
  description: 'Write a boolean value to pin'
  icon: 'sign-out'
  constructor: ->
    @inPorts =
      pin: new noflo.Port 'number'
      dutycycle: new noflo.Port 'number'
      period: new noflo.Port 'number'

    @chipNumber = 0
    @dutyCycle = null
    @period = null

    @inPorts.pin.on 'data', (value) =>
      @stopGpio()
      @pinNumber = value
      @startGpio()
    @inPorts.dutycycle.on 'data', (value) =>
      @dutyCycle = value
      @applyParameters()
    @inPorts.period.on 'data', (value) =>
      @period = value
      @applyParameters()

  stopGpio: () ->
    return unless @pwm
    @pwm.reset()
    @pwm.unexport()
    delete @pwm
    delete @dutyCycle
    delete @period

  startGpio: () ->
    return unless @pinNumber != null
    @pwm = pwm.export(@chipNumber, @pinNumber, () =>
      @pwm.setEnable(1)
      @applyParameters())

  applyParameters: () ->
    return unless @pwm
    @pwm.setDutyCycle(@dutyCycle) if @dutyCycle != null
    @pwm.setPeriod(@period) if @period != null

  shutdown: () ->
    @stopGpio()

exports.getComponent = -> new PwmWrite
