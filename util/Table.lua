local T = {}

function T.indexOf(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil
end

-- Fisher-Yates shuffle
function T.shuffle(t)
    local n = #t
    for i = n, 2, -1 do
        local j = love.math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

return T