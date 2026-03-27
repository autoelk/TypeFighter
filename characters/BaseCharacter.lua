BaseCharacter = {}
BaseCharacter.__index = BaseCharacter

function BaseCharacter:new(name, health)
    local character = setmetatable({}, self)
    character.name = name
    character.description = nil

    character.health = health
    character.maxHealth = health

    character.idleSprite = nil
    character.castSprite = nil
    character.deathSprite = nil
    character.tint = COLORS.WHITE

    character.startingDeck = {}
    return character
end 
