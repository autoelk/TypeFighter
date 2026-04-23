local Chars = require "definitions.Characters"
local Cards = require "definitions.Cards"

CharacterManager = {}
CharacterManager.__index = CharacterManager

function CharacterManager:new()
    local manager = {
        characters = Chars.characters,
        humanCharacters = Chars.humanCharacters,
        enemyCharacters = Chars.enemyCharacters,
        bossCharacters = Chars.bossCharacters,
        cardToCharacter = {}, -- Map of card name to character name
    }
    for cardName, def in pairs(Cards) do
        manager.cardToCharacter[cardName] = def.character
    end
    return setmetatable(manager, self)
end

function CharacterManager:getHumanCharacters()
    return self.humanCharacters
end

function CharacterManager:getEnemyCharacters()
    return self.enemyCharacters
end

function CharacterManager:createPlayer(ctx, characterName)
    local def = self.characters[characterName]
    if not def then
        error("Unknown character: " .. tostring(characterName))
    end
    return BasePlayer:new(ctx, def)
end
