promise = require 'promise'

class View
  constructor: (@_urls, @_duration) ->
    @_idx = 0
    @_prev = undefined
    @_transitionEndCallback = undefined
    @_callbacks = {}

  prepare: (offer) =>
    container = document.getElementById('container')
    if @_idx >= @_urls.length
      @_idx = 0

    url = @_urls[@_idx]
    if not url
      return offer()
    @_idx += 1

    @_initLiteApp url
      .then (index) =>
        @_getOrCreateNode url, index
          .then (iframeId) =>
            offer (done) =>
              if @_prev?
                prev = document.getElementById @_prev
                if prev?
                  prev.style.setProperty 'visibility', 'hidden'
                @_prev = undefined

              iframe = document.getElementById iframeId
              if iframe?
                iframe.style.setProperty 'visibility', 'visible'
                end = =>
                  @_prev = iframeId
                  done()
                setTimeout end, @_duration
              else
                done()
          .catch (e) ->
            console.error e
            offer()
      .catch (e) ->
        console.error e
        offer()


  _initLiteApp: (url) ->
    window.Cortex.app.initLiteApp url

  _getOrCreateNode: (id, index) ->
    new promise (resolve, reject) =>
      nid = "iframe-#{id}"
      iframe = document.getElementById nid
      if iframe?
        return resolve nid

      iframe = document.createElement 'iframe'
      iframe.style.setProperty 'visibility', 'hidden'
      iframe.setAttribute 'id', nid
      iframe.onload = =>
        iframe.contentWindow.onerror = (msg, url, line, col, error) ->
          console.error "#{url}:#{line}:#{col} - #{msg}", error
        resolve nid
      iframe.onerror = reject
      iframe.setAttribute 'src', "file://#{index}"
      container.appendChild iframe

module.exports = View
