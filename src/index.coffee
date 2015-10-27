View = require './view'

init = ->
  window.addEventListener 'cortex-ready', ->
    window.Cortex.app.getConfig()
      .then (config) ->
        duration = config['cortex.html5-test.duration']
        duration ?= 7500
        urls = config['cortex.html5-test.urls']
        curls = []
        for url in urls?.split(' ')
          url = url.trim()
          if not not url
            curls.push url

        if curls.length == 0
          throw new Error('No HTML5 app urls provided. Application cannot run.')

        window.CortexView = new View curls, duration
        window.Cortex.scheduler.onPrepare window.CortexView.prepare

      .catch (e) ->
        console.error 'Failed to initialize the application.', e
        throw e

module.exports = init()
