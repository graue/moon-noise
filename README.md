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
If you install [SoX](http://sox.sourceforge.net/), a cross-platform audio
tool, you can do it like this:

    luajit moon.lua | sox -tf32 -c2 -r44100 -q - -d

SoX may print out a couple warning messages, but this is tested to work on
both Linux and Windows, and almost certainly works on OS X too (please file
an issue if it doesn't!).

An alternative method using my `fmt` program
[from here](https://github.com/graue/synth) is a bit nicer, but only
works on Linux:

    luajit moon.lua | fmt -16 | aplay -qfcd

## Colophon

I made this at [Hacker School](https://www.hackerschool.com/), which was an
awesome experience. If you're interested in leveling up as a programmer,
you should [apply](https://www.hackerschool.com/apply).

Thanks to [@Adhesion](https://github.com/Adhesion) for testing this on
Windows.
