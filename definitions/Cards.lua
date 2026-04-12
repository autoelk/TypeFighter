local wizardCards = require "definitions.WizardCards"
local vampireCards = require "definitions.VampireCards"

local function merge(into, chunk)
    for name, def in pairs(chunk) do
        if into[name] then
            error("Duplicate card name: " .. tostring(name))
        end
        into[name] = def
    end
end

local M = {}
merge(M, wizardCards)
merge(M, vampireCards)

return M
