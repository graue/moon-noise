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

Now there's a catch. The way this works is it outputs raw samples in 32-bit
float format, which is handy for modifying further with the commands in, e.g.,
Luasynth, but may not be easy to actually listen to. Some audio programs may
be able to open files in raw, 32-bit float format, so you can try saving
output to a file, say `audio.f32`:

    luajit moon.lua >audio.f32

But what I do, on Linux, is this:

    luajit moon.lua | fmt -16 | aplay -qfcd

where `fmt` is from my [Synth kit](https://github.com/graue/synth), and
`aplay` is a command that comes with Ubuntu (and possibly other
distributions). If you're on Linux, this lets you listen in realtime (ish)
to the sound it's generating, while also seeing the corresponding status
messages, like:

    New chain created. Square
    New chain created. Square
    Next chain in 3.6455328798186
    New chain created. Sine
    Next chain in 4.6904308390023
    New chain created. Saw Up
    Next chain in 6.7570068027211

I don't know if there's a command like `aplay` for OS X or Windows.
I'd be happy to consider a patch for more convenient listening.

## Colophon

I made this at [Hacker School](https://www.hackerschool.com/), which was an
awesome experience. If you're interested in leveling up as a programmer,
you should [apply](https://www.hackerschool.com/apply).
