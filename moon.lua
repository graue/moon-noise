package.path = package.path .. ';./luasynth/?.lua'
local units = require('units')

-- Use LuaJIT's FFI to handle reading and writing floats.
local ffi = require "ffi"

ffi.cdef[[
typedef struct { float f[2]; } sample_pair;
size_t fwrite(const void *ptr, size_t size, size_t nmemb, void *stream);
int isatty(int fd);
]]

if ffi.C.isatty(1) ~= 0 then
    error("Stdout should not be a terminal. Try redirecting to a file")
end

local samplePair = ffi.new("sample_pair[?]", 1)

function writeFloats(sampleLeft, sampleRight)
    samplePair[0].f[0] = sampleLeft
    samplePair[0].f[1] = sampleRight
    if ffi.C.fwrite(samplePair, 8, 1, io.stdout) < 1 then
        return false
    end
    return true
end






local rate = 44100 -- XXX: useless, effects assume this anyway

function generateChained(gen, effects, n)
    -- Generates `n` sample pairs by running the output of `gen`
    -- through each of the `effects` in turn.
    local samps = gen.generate(n)
    for _,effect in ipairs(effects) do
        effect.process(samps)
    end
    return samps
end

function randomBetween(m, n)
    -- Returns a pseudorandom real number in the range [m, n).
    return math.random() * (n - m) + m
end

function logRandomBetween(m, n)
    -- Like `randomBetween()`, but for logarithmic quantities like
    -- frequencies. The log of the return value will be equally
    -- likely to lie at any point between log(m) and log(n).
    return math.exp(randomBetween(math.log(m), math.log(n)))
end

function randomFrom(xs)
    -- Returns a random element of the array `xs`.
    return xs[math.random(#xs)]
end


math.randomseed(os.time())

local myGen = units.gens.osc.new({
    oscType = randomFrom({'Sine','Triangle','Square','Saw Up'}),
    gain = randomBetween(-14, -4),
    freq = logRandomBetween(200, 10000)
})

local myFx = {}
table.insert(myFx, units.effects.filter.new({
    center = logRandomBetween(200, 10000),
    q = logRandomBetween(0.5, 50),
    filtType = randomFrom({'Lowpass','Highpass','Bandpass','Notch'})
}))
table.insert(myFx, units.effects.power.new({
    exponent = 2 - logRandomBetween(1, 1.5)
}))
table.insert(myFx, units.effects.filter.new({
    center = logRandomBetween(200, 10000),
    q = logRandomBetween(0.5, 50),
    filtType = randomFrom({'Lowpass','Highpass','Bandpass','Notch'})
}))
table.insert(myFx, units.effects.pan.new({
    angle = randomBetween(-22, 22.05)
}))
table.insert(myFx, units.effects.delay.new({
    len = logRandomBetween(20, 10000),
    feedback = logRandomBetween(20, 80),
    wetOut = logRandomBetween(50, 99)
}))

local bufferSize = 1024
local lengthInSecs = 30
local lengthInBuffers = math.floor(lengthInSecs * rate / bufferSize)

for _ = 1, lengthInBuffers do
    local samps = generateChained(myGen, myFx, bufferSize)
    if #samps ~= 2*bufferSize then
        io.stderr:write('Wrong number of samps! '
                        .. 2*bufferSize .. ' expected, ' .. #samps .. ' found\n')
        os.exit(1)
    end
    for i = 1, bufferSize do
        -- write stereo sample pair
        writeFloats(samps[2*i-1], samps[2*i])
    end
end
