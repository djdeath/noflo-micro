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
    @dutyCycle = 0
    @period = 0

    @inPorts.pin.on 'data', (value) =>
      @stopGpio()
      @pinNumber = value
      @startGpio()
    @inPorts.dutycycle.on 'data', (value) =>
      @dutyCycle = value
      @pwm.setDutyCycle(@dutyCycle) if @ready
    @inPorts.period.on 'data', (value) =>
      @period = value
      @pwm.setPeriod(@period) if @ready

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
      @ready = true
      console.log('pwm ready')
      @pwm.setEnable(1, () =>
        @applyParameters()))

  applyParameters: () ->
    @pwm.setDutyCycle(0, () =>
      @pwm.setPeriod(0, () =>
        @pwm.setPeriod(@period, () =>
          @pwm.setDutyCycle(@dutyCycle))))

  shutdown: () ->
    @stopGpio()

exports.getComponent = -> new PwmWrite
