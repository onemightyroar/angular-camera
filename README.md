# Angular Camera Directive

An Angular directive for easily taking pictures from your webcam.

![ngCamera in action](http://onemightyroar.s3.amazonaws.com/github/dalek-camera-example.jpeg)

## Getting started

1. Install via Bower using `bower install angular-camera`
2. Load the `omr.directives` module in your application: `angular.module('app', ['omr.directives']);`

## Using ngCamera

```html
<ng-camera
  type="photo"
  enabled="cameraActive"
  width="640"
  height="480"
  countdown="3"
  ng-model="media"
  overlay-src="photoFrame"
  capture="publish()"
  capture-message="SMILE!"></ng-camera>
```

The captured photo will save a Base64 version of itself to the ng-model's definition. Overlay an optional picture frame via `overlay-src` to have it stitched onto the final image.

More extensive documentation to follow.

_Built by [Zach Dunn](https://github.com/zachdunn) from work on the [Robin Platform](http://getrobin)_
