local S = {}

function S.playSound(sound)
    local pitchMod = 0.8 + love.math.random(0, 10) / 25
    sound:setPitch(pitchMod)
    sound:play()
end

return S