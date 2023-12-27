# Pixlet App Experiments

This contains programs in written in Starlark that generate 64x32
images which are displayed on Tidbyt v1 smart display.

The smart display just shows images and animations.  Everything local
is driven through the `pixlet` program.  The Tidbyt cloud runs the
apps and push new images to the device itself.

## Hacking

Learn about the API and publishing: https://tidbyt.dev/


View in browser:

    make serve

Push to the device once:

    make push

Deploy to the device so it stays in the rotation (note: you cannot
schedule this image):

    make push

Pick a different program (works for `serve` and `publish`):

    make push IMAGE=annimation

## Examples

Most of the official apps are open source:

https://github.com/tidbyt/community

Official examples:

https://github.com/tidbyt/pixlet/tree/main/examples


[starlark]: starlark
[tidbyt1]: https://tidbyt.com/products/tidbyt
