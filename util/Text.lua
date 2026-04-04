local T = {}

-- Build colored-text table for love.graphics.print / printf (prefix match vs user input).
function T.colorizeText(text, input, normalColor, correctColor, remainingColor)
    local numCorrect = 0
    for i = 1, math.min(#text, #input) do
        if text:sub(i, i) == input:sub(i, i) then
            numCorrect = numCorrect + 1
        else
            break
        end
    end

    if numCorrect == 0 then
        return { normalColor, text }
    end
    return {
        correctColor, text:sub(1, numCorrect),
        remainingColor, text:sub(numCorrect + 1),
    }
end

-- Colored-text table for incantation typing (skips spaces in incantation, matches input char-by-char).
function T.colorizeIncantation(incantation, input)
    local text = {}
    local incantationIdx = 1
    local prevInterval = 1
    local curStreak = "correct"
    for inputIdx = 1, #input do
        local inputChar = string.sub(input, inputIdx, inputIdx)
        local incantationChar = string.sub(incantation, incantationIdx, incantationIdx)
        if inputChar == incantationChar then
            if curStreak == "incorrect" then
                table.insert(text, COLORS.RED)
                table.insert(text, string.sub(input, prevInterval, inputIdx - 1))
                prevInterval = inputIdx
            end
            curStreak = "correct"
            incantationIdx = incantationIdx + 1
        else
            if curStreak == "correct" then
                table.insert(text, COLORS.WHITE)
                table.insert(text, string.sub(input, prevInterval, inputIdx - 1))
                prevInterval = inputIdx
            end
            curStreak = "incorrect"
        end
    end
    if curStreak == "correct" then
        table.insert(text, COLORS.WHITE)
    else
        table.insert(text, COLORS.RED)
    end
    table.insert(text, string.sub(input, prevInterval, -1))
    table.insert(text, COLORS.GREY)
    table.insert(text, string.sub(incantation, incantationIdx, -1))

    return text
end

return T