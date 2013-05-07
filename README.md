# Moon Noise.

This is a quick-and-dirty noise generator built on, and demonstrating,
the [Luasynth](https://github.com/graue/luasynth) audio framework.
Chains of oscillators and effects are created, with random parameters,
and layered on top of one another.
It sounds kind of interesting for about 2 minutes.

## Running it

Get [LuaJIT](http://luajit.org/). Clone this repo, then, inside the repo,
run:

    git submodule init
    git submodule update

to fetch Luasynth.

Now, Moon Noise has no code for actually playing the audio. All it does is
*compute* the audio and output numbers (32-bit floating point numbers, to be
precise) that represent that audio. To save the audio to a file, which is the
simplest way to use Moon Noise, you can do this:

    luajit moon.lua >audio.f32

## Listening to the output

Some audio programs will let you open the `audio.f32` file you just created
above, so you can listen offline. Tell the program it's a 32-bit float,
2-channel, raw audio file with a sampling rate of 44100 Hz.

A more fun way to listen is to pipe the audio into a program that plays it.
My usual approach is this, but it requires `fmt` from my
[Synth package](https://github.com/graue/synth), and only works on Linux:

    luajit moon.lua | fmt -16 | aplay -qfcd

Here, `fmt` converts 32-bit float samples to 16-bit integer samples, and
`aplay` plays raw 16-bit integer samples (`-q` means don't print status
messages on the console, `-fcd` means expect raw CD-audio format, `-qfcd`
combines these two options).

Another solution which may work for OS X and Windows users, as well as Linux,
is to use [SoX](http://sox.sourceforge.net/), which is cross-platform.
SoX comes with a `play` command you can use like this:

    luajit moon.lua | play -tf32 -c2 -r44100 -q -

It's more to type, but it seems to do the trick. If you try this on OS X or
Windows, please let me know whether it works or not! I'll update the readme.

## Colophon

I made this at [Hacker School](https://www.hackerschool.com/), which was an
awesome experience. If you're interested in leveling up as a programmer,
you should [apply](https://www.hackerschool.com/apply).
