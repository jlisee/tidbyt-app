Notes
======

## Architecture of Tidbyt

- 64x32 pixel display in an attractive case
- Device displays pushed images or short animations
- Central renders these images and pushes them out
- Default rotation speed is 15
- Apps written in Starlark

## Limitations

Things I have hit so far while working on various apps:

- Cloud apps have 500ms runtime limit
- Your app must be in a single file
- Only HTTP APIs are supported
- Schedules only support a single period of on per day

## Alternative Platforms

These are other ways to push content to the Tidbyt:

Small single person flask app:
https://github.com/tavdog/tidbyt-manager

Fixes basically all the platform limitations (runtime limit, single
file, limited API support), but uses a lot more moving parts:
https://github.com/DouweM/pixbyt


## Worries

- The main developer to the platform has left to go back into big tech
