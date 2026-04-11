local T = {}

function T.trim(string)
    return string:match("^%s*(.-)%s*$")
end

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
-- progCurWord is the progress the user has made on the current word they are typing
-- remCurWord is the remaining letters of the current word the user is typing
-- modifiedInput is the input with the incorrect spaces replaced with currency symbols
function T.colorizeIncantation(incantation, input)
    local modifiedInput = "" -- used only for cursor positioning
    local text = {}
    local incantationIdx = 1
    local prevInterval = 1
    local curStreak = "correct"
    for inputIdx = 1, #input do
        local inputChar = string.sub(input, inputIdx, inputIdx)
        local incantationChar = string.sub(incantation, incantationIdx, incantationIdx)
        if inputChar == incantationChar then
            if curStreak == "incorrect" then
                -- use currency symbol to represent incorrect spaces
                -- we are using a custom font where the currency symbol looks 
                -- like the open box for a space whitespace character
                local incorrectPortion = string.sub(input, prevInterval, inputIdx - 1)
                incorrectPortion = string.gsub(incorrectPortion, " ", "¤")
                modifiedInput = modifiedInput .. incorrectPortion
                table.insert(text, COLORS.RED)
                table.insert(text, incorrectPortion)
                prevInterval = inputIdx
            end
            curStreak = "correct"
            incantationIdx = incantationIdx + 1
        else
            if curStreak == "correct" then
                local correctPortion = string.sub(input, prevInterval, inputIdx - 1)
                modifiedInput = modifiedInput .. correctPortion
                table.insert(text, COLORS.WHITE)
                table.insert(text, correctPortion)
                prevInterval = inputIdx
            end
            curStreak = "incorrect"
        end
    end
    local curPortion = string.sub(input, prevInterval, -1)
    if curStreak == "correct" then
        table.insert(text, COLORS.WHITE)
    else
        curPortion = string.gsub(curPortion, " ", "¤")
        table.insert(text, COLORS.RED)
    end
    table.insert(text, curPortion)
    modifiedInput = modifiedInput .. curPortion

    local remPortion = string.sub(incantation, incantationIdx, -1)
    table.insert(text, COLORS.GREY)
    table.insert(text, remPortion)

    local progCurWord = string.match(modifiedInput, "([^ ]+)$") or ""
    local remCurWord = string.match(remPortion, "^(%w+)") or ""

    return text, progCurWord, remCurWord, modifiedInput
end

return T