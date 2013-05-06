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

function createChain()
    local myGen = units.gens.osc.new({
        oscType = randomFrom({'Sine','Triangle','Square','Saw Up'}),
        gain = randomBetween(-24, -14),
        freq = logRandomBetween(200, 1500)
    })

    local myFx = {}
    table.insert(myFx, units.effects.filter.new({
        center = logRandomBetween(200, 10000),
        q = logRandomBetween(0.5, 20),
        filtType = randomFrom({'Lowpass','Highpass','Bandpass','Notch'})
    }))
    table.insert(myFx, units.effects.adsr.new({
        decay = randomBetween(100, 1000),
        attack = logRandomBetween(5, 200),
        sustainLen = randomBetween(2000, 9000),
        release = logRandomBetween(2000, 9000),
        sustainLevel = randomBetween(-20, -5)
    }))
    table.insert(myFx, units.effects.power.new({
        exponent = 2 - logRandomBetween(1, 1.5)
    }))
    table.insert(myFx, units.effects.filter.new({
        center = logRandomBetween(200, 10000),
        q = logRandomBetween(0.5, 20),
        filtType = randomFrom({'Lowpass','Highpass','Bandpass','Notch'})
    }))
    table.insert(myFx, units.effects.pan.new({
        angle = randomBetween(-22, 22.05)
    }))
    table.insert(myFx, units.effects.delay.new({
        len = logRandomBetween(20, 10000),
        feedback = logRandomBetween(20, 80),
        wetOut = randomBetween(50, 99)
    }))
    io.stderr:write("New chain created. " .. myGen.oscType .. "\n")
    return {gen = myGen, fx = myFx, sampsLeft = 30 * rate}
end

local bufferSize = 1024
local lengthInSecs = 120
local lengthInBuffers = math.floor(lengthInSecs * rate / bufferSize)
local chains = {createChain()}
local timeToNextChain = math.floor(2 * rate / bufferSize)

for _ = 1, lengthInBuffers do
    local samps = generateChained(chains[1].gen, chains[1].fx, bufferSize)
    for i = 2, #chains do
        local moreSamps = generateChained(chains[i].gen, chains[i].fx,
            bufferSize)
        for j = 1, 2*bufferSize do
            samps[j] = samps[j] + moreSamps[j]
        end
    end
    for i = 1, bufferSize do
        -- write stereo sample pair
        writeFloats(samps[2*i-1], samps[2*i])
    end
    for i = 1, #chains do
        chains[i].sampsLeft = chains[i].sampsLeft - bufferSize
        if chains[i].sampsLeft == 0 then
            chains[i] = createChain()
        end
    end
    timeToNextChain = timeToNextChain - 1
    if timeToNextChain <= 0 then
        table.insert(chains, createChain())
        timeToNextChain = math.floor((0.5*(#chains-1) + randomBetween(3, 6))
                                     * rate / bufferSize)
        io.stderr:write('Next chain in ' ..
                        (timeToNextChain * bufferSize / rate) .. "\n")
    end
end
