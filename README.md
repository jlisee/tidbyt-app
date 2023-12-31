# Tidbyt App Experiments

This contains programs in written in Starlark that generate 64x32
images which are displayed on a Tidbyt v1 smart display.

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

## Image Notes

They are generally embedded in programs themselves. 16x16 pixels is
good for making them small and able to use multiple.

The typical conversion change:

    convert input.png -colors 256 output.gif

If that doesn't work this site provides higher quality converison:
https://cloudconvert.com/png-to-gif

To optimize the resulting gif:

    gifsicle -i input.gif -O3 --colors 16 -o output.gif

You can count the colors to compare here:

    convert output.gif -format %c histogram:info:- | sort | uniq | wc -l

[starlark]: starlark
[tidbyt1]: https://tidbyt.com/products/tidbyt
