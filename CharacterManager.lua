require "characters.BaseCharacter"
require "characters.WizardCharacter"
require "characters.VampireCharacter"

CharacterManager = {}
CharacterManager.__index = CharacterManager

function CharacterManager:new()
    local manager = {
        charTypes = {
            ["wizard"] = WizardCharacter,
            ["vampire"] = VampireCharacter
        },
        charNames = {}
    }
    for charName, _ in pairs(manager.charTypes) do
        table.insert(manager.charNames, charName)
    end
    return setmetatable(manager, self)
end

function CharacterManager:createCharacter(charName)
    local CharClass = self.charTypes[string.lower(charName)]
    if CharClass then
        return CharClass:new()
    else
        error("Unknown character type: " .. charName)
    end
end

function CharacterManager:getAllCharNames()
    return self.charNames
end
