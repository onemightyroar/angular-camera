'use strict';

angular.module('omr.directives', [])
  .directive 'ngCamera', ($timeout, $sce) ->
    require: 'ngModel'
    template: '<div class="ng-camera clearfix">
        <p ng-hide="isLoaded">Loading Camera...</p>
        <p ng-show="noCamera">Couldn\'t find a camera to use</p>
        <div class="ng-camera-stack" ng-hide="!isLoaded">
          <div class="ng-camera-countdown" ng-show="activeCountdown">
            <p class="tick">{{countdownText}}</p>
          </div>
          <img class="ng-camera-overlay" ng-hide="!overlaySrc" ng-src="{{overlaySrc}}" width="{{width}}" height="{{height}}">
          <video id="ng-camera-feed" autoplay width="{{width}}" height="{{height}}" src="{{videoStream}}">Install Browser\'s latest version</video>
          <canvas id="ng-photo-canvas" width="{{width}}" height="{{height}}" style="display:none;"></canvas>
        </div>
        <div class="ng-camera-controls" ng-hide="hideUI">
          <button class="btn ng-camera-take-btn" ng-click="takePicture()">Take Picture</button>
        </div>
      </div>'
    replace: false
    transclude: true
    restrict: 'E'
    scope:
      type: '@'
      media: '=ngModel'
      width: '@'
      height: '@'
      overlaySrc: '='
      countdown: '@'
      captureCallback: '&capture'
      enabled: '='
      captureMessage: "@"
    link: (scope, element, attrs, ngModel) ->

      scope.activeCountdown = false

      # Remap common references
      navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia
      window.URL = window.URL || window.webkitURL || window.mozURL || window.msURL
      scope.$on('$destroy', () ->
        if scope.stream and typeof scope.stream.stop == 'function'
          scope.stream.stop()
          return
      )
      ###*
      * @description Set mediastream source and notify camera
      ###
      scope.enableCamera = ->
        navigator.getUserMedia
          audio: false
          video: true
        , (stream) ->
          scope.$apply ->
            scope.stream = stream
            scope.isLoaded = true
            scope.videoStream = $sce.trustAsResourceUrl(window.URL.createObjectURL(stream))
        , (error) ->
          scope.$apply ->
            scope.isLoaded = true
            scope.noCamera = true

      ###*
      * @description Disable mediastream source and notify camera
      ###
      scope.disableCamera = ->
        navigator.getUserMedia
          audio: false
          video: true
        , (stream) ->
          scope.$apply ->
            scope.videoStream = ""

      ###*
      * @description Capture current state of video stream as photo
      ###
      scope.takePicture = ->
        canvas = window.document.getElementById('ng-photo-canvas')

        # Get countdown time in seconds from attribute
        countdownTime = if scope.countdown? then parseInt(scope.countdown) * 1000 else 0

        # Make sure there's a canvas to work with
        if canvas?

          # Hide UI if countdown occurs
          if countdownTime > 0
            scope.activeCountdown = true
            scope.hideUI = true

          context = canvas.getContext('2d')

          $timeout.cancel scope.countdownTimer if scope.countdownTimer

          # Start timer to photo shot
          scope.countdownTimer = $timeout ->
            scope.activeCountdown = false

            # Draw current video feed to canvas (photo source)
            cameraFeed = window.document.getElementById('ng-camera-feed')
            context.drawImage cameraFeed, 0, 0, scope.width, scope.height

            # Add overlay if present
            if scope.overlaySrc?
              scope.addFrame context, scope.overlaySrc, (image) ->
                # Wait for overlay image to load before making dataURL
                scope.$apply ->
                  scope.media = canvas.toDataURL('image/jpeg')
                scope.captureCallback(scope.media) if scope.captureCallback?
            else
              scope.media = canvas.toDataURL('image/jpeg') # Assign to ngModel
              scope.captureCallback(scope.media) if scope.captureCallback?

            scope.hideUI = false
          , countdownTime + 1000 # Add extra second for final message

          scope.countdownText = parseInt(scope.countdown)

          # Countdown ticker until photo
          countdownTick = setInterval ->
            scope.$apply ->
              nextTick = parseInt(scope.countdownText) - 1
              if nextTick is 0
                # Replace zero with better copy
                scope.countdownText = if scope.captureMessage? then scope.captureMessage else 'GO!'
                clearInterval countdownTick # End countdown on last tick
              else
                scope.countdownText = nextTick
          , 1000
        else
          # We have no canvas to work with
        return false

      ###*
      * @description Add overlay frame to canvas render
      * @param {Object} context Reference to target canvas context
      ###
      scope.addFrame = (context, url, callback = false) ->
        # Load returned overlay image and draw onto photo canvas
        overlay = new Image()
        overlay.onload = ->
          context.drawImage overlay, 0, 0, scope.width, scope.height
          callback(context) if callback
        overlay.crossOrigin = ''
        overlay.src = url

      ###*
      * @description Keeps a packaged version of media ready
      * @param {Base64} newVal Prefix-stripped Base64 of of canvas image
      ###
      scope.$watch 'media', (newVal) ->
        # Strip the Base64 prefix
        scope.packagedMedia = scope.media.replace /^data:image\/\w+;base64,/, "" if newVal?

      ###*
      * @description Preloader for overlay image
      ###
      scope.$watch 'overlaySrc', (newVal, oldVal) ->
        # If an overlay was provided
        if scope.overlaySrc?
          # We're waiting on this to load
          scope.isLoaded = false
          preloader = new Image()
          preloader.crossOrigin = ''
          preloader.src = newVal
          preloader.onload = ->
            scope.$apply ->
              scope.isLoaded = true
        else
          # No frame. Skip it.
          scope.isLoaded = true

      ###*
      * @description Watch for when to turn on/off camera feed
      ###
      scope.$watch 'enabled', (newVal, oldVal) ->
        if newVal
          scope.enableCamera() if !oldVal # Turn on feed if actual change
        else
          scope.disableCamera() if oldVal? # Turn off feed if actual change

      ###*
      * @description Check format type of camera.
      * @todo Future support for different media types (GIF, Video)
      ###
      scope.$watch 'type', ->
        switch scope.type
          when 'photo'
          # Photo
            scope.enableCamera() if scope.enabled
          else
          # Defaulting to photo
            scope.enableCamera() if scope.enabled
