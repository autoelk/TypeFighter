local C = require "Characters"

CharacterManager = {}
CharacterManager.__index = CharacterManager

function CharacterManager:new()
    local manager = {
        characters = C.characters,
        humanCharacters = C.humanCharacters,
        enemyCharacters = C.enemyCharacters,
        bossCharacters = C.bossCharacters,
        cardToCharacter = {}, -- Map of card name to character name
    }
    for charName, def in pairs(manager.characters) do
        for _, cardName in ipairs(def.cardPool) do
            if manager.cardToCharacter[cardName] and manager.cardToCharacter[cardName] ~= charName then
                error("Card '" .. cardName .. "' appears in more than one character cardPool")
            end
            manager.cardToCharacter[cardName] = charName
        end
    end
    return setmetatable(manager, self)
end

function CharacterManager:getHumanCharacters()
    return self.humanCharacters
end

function CharacterManager:createPlayer(ctx, characterName)
    local def = self.characters[characterName]
    if not def then
        error("Unknown character: " .. tostring(characterName))
    end
    return BasePlayer:new(ctx, def)
end
