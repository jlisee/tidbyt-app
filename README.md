# Pixlet App Experiments

This contains programs in written in Starlark that generate 64x32
images which are displayed on Tidbyt v1 smart display.

The smart display just shows images and animations.  Everything local
is driven through the `pixlet` program.  The Tidbyt cloud runs the
apps and push new images to the device itself.

## Hacking

Learn about the API and publishing: https://tidbyt.dev/

Push to the device:

    make publish

View in browser:

    make serve

Pick a different program (works for `serve` and `publish`):

    make publish IMAGE=annimation

## Examples

Most of the official apps are open source:

https://github.com/tidbyt/community

Official examples:

https://github.com/tidbyt/pixlet/tree/main/examples


[starlark]: starlark
[tidbyt1]: https://tidbyt.com/products/tidbyt
